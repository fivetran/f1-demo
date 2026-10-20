# F1 project guide

Keep this project small. The user explicitly requested a minimalist implementation on 2026-10-12: prefer direct SQL and a few meaningful checks; do not add exhaustive assertions, fingerprint frameworks, duplicate inspectors or tests for every column. Keep operational instructions here and reader guidance in model schema YAML and [ROOT](dbt/macros/publish_agents_schema.sql).

## Architecture and boundaries

- Two Fivetran SDK connectors load typed OpenF1 endpoint tables and readable document tables. No generic payload/snapshot architecture.
- dbt builds the approved [normalized models](dbt/models/openf1/) in `f1`, preserving `f1_openf1` and `f1_documents` as ingestion-owned sources. Driver/team identities are computed models, not seeds.
- Document models preserve each source collection one-to-one in `f1`. dbt-computed embeddings and BigQuery hybrid indexes live on the three dbt passage tables; parent metadata remains separate. An on-run-end macro builds exactly `agents.root`, `dbt_tables`, `dbt_columns`, `dbt_joins`.
- OpenF1 covers 2025 and completed 2026 races; document coverage remains 2025. The authorized season replacement already completed; it is not permission for future truncations. No recurring schedule exists.
- Connector declarations and [dbt sources](dbt/models/sources.yml) describe ingestion. Maintain source YAML directly when connector schemas change; there is no source generator. Model schema YAML and [ROOT](dbt/macros/publish_agents_schema.sql) document finished table grains, joins and limitations.

## Accounts and tools

- Account IDs, billing IDs, connection IDs, service-account emails and the private agent URL belong in the ignored root `.env`. Start from [.env.example](.env.example). Never copy actual values into tracked files. Historical deployment details are retained locally in ignored `infra/deployment.json`.
- Python operational scripts load `.env` automatically; exported variables take precedence. Run Fusion through `../scripts/with_config.py` from `dbt`, or export the settings first. Local Fusion is the supported execution path.
- Use the configured project in US and the existing GCP Direct billing account; never switch to Searce. The dbt identity reads sources and writes `f1` and `agents`; ingestion owns source datasets. Never add generated embedding columns to Fivetran-owned tables: its BigQuery schema migration rejects STRUCT columns.
- Credentials stay outside the repository in `~/.config/f1-demo/credentials.json` (0600). BigQuery/Fusion use Google application-default credentials. Named gcloud login is separate. Never print tokens, full credential responses or credential-bearing subprocess arguments.
- Python 3.12.8, Connector SDK 2.12.1, Fivetran CLI 1.0.0, dbt Fusion 2.0.8. Use the pinned requirements and `.venv` (create it with Python 3.12.8 if absent); do not replace Fusion with Python dbt-core 1.x. CLIs are also in `~/.local/bin`.
- Remote: [fivetran/f1-demo](https://github.com/fivetran/f1-demo), dbt subdirectory `dbt`. `/tmp/f1-demo-publish` is a publishing checkout. Publish only nonignored files; exclude caches, environments, debugger files and credentials.

## Routine work

SQL style: use lowercase keywords, four-space indentation, and one projected column per line. Models without joins must not define table aliases or qualify column references. Use explicit `as` for aliases in models with joins. Quote column names only when SQL syntax requires it. Keep complex expressions readable and avoid redundant blank lines. Preserve SQL examples and literal catalog content when formatting model code. Project only columns with a plausible query use or a required model function; omit ingestion metadata otherwise. The passage models retain `_fivetran_synced` because their incremental watermark depends on it.

Run Fusion from the `dbt` directory, with four threads:

```sh
(cd dbt && python3 ../scripts/with_config.py dbt build --profiles-dir . --threads 4 --no-manage-state)
```

Use `--select tag:document_search` for focused document work or `dbt run-operation publish_agents_schema` for catalog-only publication. `dbt parse` checks project parsing without rebuilding tables. There are no dbt tests; retained Python tests cover connector behavior. Investigate identity collisions rather than choosing arbitrary MAX/latest values. Connector behavior tests are in [tests/test_connectors.py](tests/test_connectors.py); run them when changing connectors.

[run_pipeline.py](scripts/run_pipeline.py) uses [.env.example](.env.example) variables to force Fivetran syncs, wait for success, then run local Fusion. `--wait-existing` waits for an already-started sync.

There is no target-validation or retention-reset hook. Historical expiration settings were cleared previously: a former 60-day dataset default immediately expired the 2025 data. Do not reintroduce retention or change source dataset retention.

## Connector and model semantics

- OpenF1 accepts comma-separated `years` (legacy `year` still works); production uses `2025,2026`. Calendar metadata refreshes each sync. Detail checkpoints retain their generation across season additions, and only noncancelled Race sessions ending at least 30 minutes ago are eligible. **Starting grids use main Qualifying session keys**; associate them with Race through the meeting, without fabricating Qualifying driver entries. Sprint Qualifying is excluded.
- Presentation metadata uses the latest non-null driver headshot by session time and the latest calendar meeting for circuit URLs/locality. Other conflicting identity attributes require investigation.
- Driver numbers identify entries within a session, not permanent people. Computed IDs use normalized source names and season mappings; spelling changes/cross-season continuity need deliberate reconciliation. Team colours belong in `team_sessions`. Source driver country codes are all null.
- Normalization keeps one concept and grain per table. Driver standings may lack same-session entries and join people directly; no Qualifying entries are fabricated. Facts preserve source values without rounding, clamping or inferred lap associations. Model-derived fields decode documented brake states, validate throttle, parse numeric gaps, and calculate stint spans and checkpoint point changes; raw fields remain available. Overtakes include pit-stop/penalty exchanges and may be incomplete; race-control driver references are optional.
- Preserve all telemetry samples, including pre/post-race timestamps. Fetch car/location data per driver/session; pace OpenF1 calls at least 2.1 seconds apart and do not run competing crawlers. Retry 429/5xx/transient failures.
- `sync_status` records completed scopes and source availability. `unavailable_404` means unavailable, not zero events. Query completed syncs for consistency.
- Gaps such as `+1 LAP` remain strings; sector segments remain JSON arrays. Race result duration is scalar. Fivetran renames speed fields to `i_1_speed` and `i_2_speed`. In models with joins, qualify projected source columns. In models without joins, leave column references unqualified and verify that `position` resolves to the scalar source column.
- A refresh generation refetches/upserts OpenF1; it does not remove disappeared rows. An authorized season replacement requires pausing, full resync/empty state, explicit table truncation and resumption. Do not infer deletion reconciliation from an SDK resync alone.
- Documents have parent and ordered section tables. Changed documents remove obsolete sections; static manifest removals and document-fetch 404/410 remove current documents. Sitemap absence never deletes transcripts, including legacy manifest checkpoints. Download/parse/discovery failures retain previous good documents and fail the sync for retry.
- The checked [document manifest](connectors/documents/manifest.full.json) contains fixed regulation and glossary URLs. Production `transcript_years` is `2025`: transcripts are discovered from the FIA sitemap every sync, with publication dates resolving yearless URLs and a unique Race session window (four days before through one day after) supplying meeting associations. Discovery metadata persists in SDK state; sitemap lastmod changes trigger reprocessing. Missing/ambiguous race associations fail discovery. Omit `transcript_years` for manifest-only SDK debugging. FIA requests follow robots.txt and a ten-second interval; do not overlap crawlers.
- Speaker labels come from markup, not person resolution. Publication dates are not event/effective dates. Unknown regulation effective dates remain null, and current glossary pages are not historical 2025 law.
- Do not advertise inclusive lap/stint ranges as many-one: observed overlaps make them ambiguous. Independent telemetry feeds need explicit time alignment. Preserve unexpected telemetry codes rather than clamping them. Championship checkpoints are source snapshots, not reconciled race-point facts. Detailed query limitations are in model schema YAML and [ROOT](dbt/macros/publish_agents_schema.sql).

For SDK debugging, use the Singapore example before a full backfill. Config paths resolve from the connector directory; stop the debugger before reading its DuckDB file. Local document caches use `../../.cache/sources`; hosted checkpoints, not caches, prevent repeat downloads.

Deploy from the connector directory with the SDK environment on PATH. OpenF1 uses `configuration.season.json`; documents use `configuration.production.json`. `fivetran deploy --yes` accepts an existing connection update but may update dependencies; keep hosted/local pins aligned. SDK 2.12.1's `--force` skips dependency upgrades and accepts deployment prompts; use it alone, not together with `--yes`. Keep the base64 API key/secret deploy credential out of logs.

## Minimal Agents Schema

AGENTS is **reader guidance for query tables**: meanings, grain, joins, aggregate expressions, query syntax and interpretive limits. It covers 24 finished OpenF1 tables and the six native document tables in `f1` (30 tables). Document parent tables hold metadata and passage tables hold text. Exclude identity lookup models and connector/dbt implementation details. All models include source rows marked `_fivetran_deleted`; do not filter on this flag.


Edit [OpenF1 schema.yml](dbt/models/openf1/schema.yml) and [document schema.yml](dbt/models/documents/schema.yml) for table and column descriptions. Models with `config.meta.agent_catalog` are published: this metadata contains `primary_key`, `row_filter` and optional `joins`. Each join is declared on its source model with `name`, `to` (target model name), `relationship`, `sql_expression` (complete predicate using `l` and `r`) and `description`. Retain full predicates, including role filters. Identity lookup models have no catalog metadata and are excluded. Only columns with descriptions are published.

The [publish_agents_schema macro](dbt/macros/publish_agents_schema.sql) reads the dbt graph and creates `dbt_tables`, `dbt_columns` and `dbt_joins` in `agents` from this YAML, and ROOT from its inline Markdown block. It runs once at the end of nonempty successful `dbt run` and `dbt build` commands, including focused selections, and publishes all catalog-marked models. It skips parsing, compilation and runs with failed/skipped results. Explicit `dbt run-operation publish_agents_schema` executes the same publication SQL without rebuilding query models. It describes project metadata; it does not prove that every referenced query table was rebuilt by the current selection. COLUMNS contains only table_name, column_name and description; types come from the physical schema. TABLES.primary_key remains a native ARRAY<STRING>. Cleanup belongs in query models, with interpretation and aggregation caveats in column descriptions.

The `root_content` Jinja block inside [publish_agents_schema.sql](dbt/macros/publish_agents_schema.sql) is the source of truth for ROOT Markdown. The macro publishes one row with provider `dbt` and an empty key with that content; there is no ROOT model. Keep ROOT concise: dataset overview and unstructured retrieval guidance only. Table, column and join details belong in schema YAML. The search inspector owns its standalone smoke queries; the analyst context has no example queries.

Build the catalog:

```sh
(cd dbt && python3 ../scripts/with_config.py dbt run-operation publish_agents_schema --profiles-dir . --no-manage-state)
```

Catalog table references come from model database/schema/alias metadata. Use `{{ target.database }}` in ROOT Markdown. Never put account IDs in tracked SQL. The Jinja text block preserves Markdown and renders project references; `tojson` escapes the content as a BigQuery string literal. The [schema naming macro](dbt/macros/generate_schema_name.sql) maps the custom schema `agents` directly to the `agents` dataset. Other models use dbt's default schema naming. Table names follow lowercase model filenames without alias overrides.

There are no catalog seeds, external generator or staging dependency. The end-of-run hook (or explicit run-operation) replaces all four tables individually. Publication is not atomic across the four tables: a hook failure can leave a partially updated catalog. Refresh the data agent only after the complete catalog publication succeeds. The obsolete `f1_agents_seed` dataset and its five historical seed tables were deleted on 2026-10-19. No automatic whole-warehouse validation runs. [configure_agents_access.py](scripts/configure_agents_access.py) grants `agents` dataset WRITER access when bootstrapping.

No BI Engine capacity is required. Queries use the configured billing project and US location.

## Browser analytics agent

[scripts/configure_data_agent.py](scripts/configure_data_agent.py) creates or refreshes `projects/__F1_GCP_PROJECT__/locations/us/dataAgents/f1-analyst` from the live four-table AGENTS catalog using ADC. Run it after publishing catalog changes; the agent context is a snapshot, while data queries remain live. Use the US endpoint `geminidataanalytics.us.rep.googleapis.com`; the global endpoint rejects this regional resource. The agent has a 10 GB per-query billed-bytes limit and runs with caller permissions. Its read-only instruction is guidance, not an IAM restriction.

[F1 Analyst in Gemini Enterprise](https://vertexaisearch.cloud.google.com/) is published in the US `f1-demo` application (collection `default_collection`, assistant `default_assistant`, agent ID stored in the local `F1_GEMINI_URL`) using Google Identity. Register it as a custom A2A agent with the card returned by `https://geminidataanalytics.us.rep.googleapis.com/v1beta/a2a/projects/__F1_GCP_PROJECT__/locations/us/dataAgents/f1-analyst/v1/card` and **Default Google-managed credentials**; no gateway or custom OAuth client is needed. The `free_trial_gemini` license configuration expires **2026-11-12**; no paid subscription was created and existing company license allocations were not changed.

## Managed document search

The connector declares collection-specific schemas: `transcripts` / `transcript_passages`, `regulations` / `regulation_sections`, and `glossary` / `glossary_sections`. Parent rows contain metadata and citation URLs; children contain complete ordered text. Transcript children have speaker/question context; regulation children have section/page; glossary children group prose under HTML headings. There are no exported hashes, parser versions, full-text duplicates or section counts. Internal SDK checkpoints retain processing revisions and previous passage counts for incremental updates and obsolete-row deletion.

[Document models](dbt/models/documents/) copy source rows one-to-one into identically named `f1` tables with each collection's own fields. They do not flatten parents into passages, combine collections, split text or truncate text. Parent tables rebuild; passage tables merge by `(document_id, position)` using `_fivetran_synced > max(_fivetran_synced)` as the incremental watermark, retaining that timestamp in each passage table. The first build loads all source rows; an empty watermark falls back to 1970-01-01. Run after a successful Fivetran sync. There is no deletion reconciliation: previously loaded passages remain if their source rows are deleted. Keep `on_schema_change='append_new_columns'` and `full_refresh=false` so incremental writes preserve embeddings and indexes.

Fivetran's BigQuery schema handling rejects STRUCT columns, including generated embeddings: a live sync confirmed this on 2026-10-19. Embeddings must live on the dbt copies, never the ingestion-owned source tables. The failed source-index experiment was removed; SDK discovery checkpoints survived the failed destination load.

Regulations group PDF text at numbered headings through level three (1.1.1), retaining deeper clauses and page continuations. Gemini Embedding 2 truncates embedding inputs at 8,192 tokens while the entire passage remains available for RAG.

Passage SELECT queries call the dbt-managed [embed_text UDF](dbt/functions/embed_text.sql) through `function('embed_text')`. dbt builds this tagged function before dependent passage models. The UDF calls `AI.EMBED` with `gemini-embedding-2` and returns a normal `ARRAY<FLOAT64>` embedding (3072 dimensions). An unsuccessful status or invalid dimension raises a SQL error before the merge, so the watermark does not advance and a rerun retries the batch. [Idempotent post-hooks](dbt/macros/document_search.sql) only create indexes. At 5,000 rows they create an IVF/COSINE hybrid index with `lexical_search_columns=['text']`. Small tables support hybrid search without index acceleration. Changing embedding models requires deliberately regenerating stored vectors and updating query embeddings; a watermark-only run does not recompute old vectors.

```sh
(cd dbt && python3 ../scripts/with_config.py dbt build --profiles-dir . --select tag:document_search --threads 4 --no-manage-state)
.venv/bin/python scripts/inspect_document_search.py --query
```

The US `f1_document_embeddings` connection service account needs `roles/aiplatform.user`; dbt needs connection-scoped `roles/bigquery.connectionUser`. The SQL `on-run-start` hook creates the connection with `CREATE CONNECTION IF NOT EXISTS` before models run. For a new environment, run [configure_embedding_access.py](scripts/configure_embedding_access.py) after connection creation to grant IAM access; the SQL hook does not grant Vertex AI permissions. Credentials remain outside the repository.

Embeddings are computed during the dbt run; index maintenance remains asynchronous. The inspector reports embedding validity and index coverage. The analyst chooses VECTOR_SEARCH for semantic retrieval, SEARCH(text, terms) for keyword matching, or hybrid VECTOR_SEARCH for both. Query embeddings must use gemini-embedding-2. Do not use AI.SEARCH, which requires autonomous embeddings. Join parent metadata by document_id and cite source_url. Matches are evidence, not exhaustive counts. ACTIVE does not establish acceleration; check query statistics.

Refresh the data agent only after the complete catalog publication succeeds. No document search input views or flattened search tables are maintained.

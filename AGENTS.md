# F1 project guide

Keep this project small. The user explicitly requested a minimalist implementation on 2026-10-12: prefer direct SQL and a few meaningful checks; do not add exhaustive assertions, fingerprint frameworks, duplicate inspectors or tests for every column. Keep operational instructions here and reader guidance in the [catalog models](dbt/models/agents/).

## Architecture and boundaries

- Two Fivetran SDK connectors load typed OpenF1 endpoint tables and readable document tables. No generic payload/snapshot architecture.
- dbt builds the approved [normalized models](dbt/models/openf1/) in `f1`, preserving `f1_openf1` and `f1_documents` as ingestion-owned sources. Driver/team identities are computed models, not seeds.
- Document search uses BigQuery-managed embeddings and a hybrid index, maintained by dbt. Five inline SQL models build exactly `AGENTS.ROOT`, `TABLES`, `DIMENSIONS`, `MEASURES`, `JOINS`.
- OpenF1 covers 2025 and completed 2026 races; document coverage remains 2025. The authorized season replacement already completed; it is not permission for future truncations. No recurring schedule exists.
- Connector declarations and [dbt sources](dbt/models/sources.yml) describe ingestion. [The catalog models](dbt/models/agents/) documents finished table grains, joins and limitations.

## Accounts and tools

- Account IDs, billing IDs, connection IDs, service-account emails and the private agent URL belong in the ignored root `.env`. Start from [.env.example](.env.example). Never copy actual values into tracked files. Historical deployment details are retained locally in ignored `infra/deployment.json`.
- Python operational scripts load `.env` automatically; exported variables take precedence. Run Fusion through `../scripts/with_config.py` from `dbt`, or export the settings first. Local Fusion is the supported execution path.
- Use the configured project in US and the existing GCP Direct billing account; never switch to Searce. The dbt identity reads sources and writes `f1` and `AGENTS`; ingestion identities own the source datasets.
- Credentials stay outside the repository in `~/.config/f1-demo/credentials.json` (0600). BigQuery/Fusion use Google application-default credentials. Named gcloud login is separate. Never print tokens, full credential responses or credential-bearing subprocess arguments.
- Python 3.12.8, Connector SDK 2.12.1, Fivetran CLI 1.0.0, dbt Fusion 2.0.8. Use the pinned requirements and `.venv` (create it with Python 3.12.8 if absent); do not replace Fusion with Python dbt-core 1.x. CLIs are also in `~/.local/bin`.
- Remote: [fivetran/f1-demo](https://github.com/fivetran/f1-demo), dbt subdirectory `dbt`. `/tmp/f1-demo-publish` is a publishing checkout. Publish only nonignored files; exclude caches, environments, debugger files and credentials.

## Routine work

Run Fusion from the `dbt` directory, with four threads:

```sh
(cd dbt && python3 ../scripts/with_config.py dbt build --profiles-dir . --threads 4 --no-manage-state)
```

Use `--select tag:document_search` or `--select tag:agents_schema` for focused work. `dbt parse` checks project parsing without rebuilding tables. Retained tests cover shared keys/identity coverage and document chunk reconstruction. Investigate identity collisions rather than choosing arbitrary MAX/latest values. Connector behavior tests are in [tests/test_connectors.py](tests/test_connectors.py); run them when changing connectors.

[run_pipeline.py](scripts/run_pipeline.py) uses [.env.example](.env.example) variables to force Fivetran syncs, wait for success, then run local Fusion. `--wait-existing` waits for an already-started sync.

A small run-start hook restricts dbt to this project's `f1` target. It clears historical partition expiration only when time-series models are selected: a former 60-day dataset default immediately expired the 2025 data. Do not reintroduce retention or change source dataset retention.

## Connector and model semantics

- OpenF1 accepts comma-separated `years` (legacy `year` still works); production uses `2025,2026`. Calendar metadata refreshes each sync. Detail checkpoints retain their generation across season additions, and only noncancelled Race sessions ending at least 30 minutes ago are eligible. **Starting grids use main Qualifying session keys**; associate them with Race through the meeting, without fabricating Qualifying driver entries. Sprint Qualifying is excluded.
- Presentation metadata uses the latest non-null driver headshot by session time and the latest calendar meeting for circuit URLs/locality. Other conflicting identity attributes still fail key tests.
- Driver numbers identify entries within a session, not permanent people. Computed IDs use normalized source names and season mappings; spelling changes/cross-season continuity need deliberate reconciliation. Team colours belong in `team_sessions`. Source driver country codes are all null.
- Normalization keeps one concept and grain per table. Driver standings may lack same-session entries and join people directly; no Qualifying entries are fabricated. Facts preserve source values without rounding, clamping or inferred lap associations. Overtakes include pit-stop/penalty exchanges and may be incomplete; race-control driver references are optional.
- Preserve all telemetry samples, including pre/post-race timestamps. Fetch car/location data per driver/session; pace OpenF1 calls at least 2.1 seconds apart and do not run competing crawlers. Retry 429/5xx/transient failures.
- `sync_status` records completed scopes and source availability. `unavailable_404` means unavailable, not zero events. Query completed syncs for consistency.
- Gaps such as `+1 LAP` remain strings; sector segments remain JSON arrays. Race result duration is scalar. Fivetran renames speed fields to `i_1_speed` and `i_2_speed`. Always qualify projected source columns: bare `position` can resolve to a whole-row STRUCT in BigQuery.
- A refresh generation refetches/upserts OpenF1; it does not remove disappeared rows. An authorized season replacement requires pausing, full resync/empty state, explicit table truncation and resumption. Do not infer deletion reconciliation from an SDK resync alone.
- Documents have parent and ordered section tables. Changed documents remove obsolete sections; removed manifests/404/410 remove current documents. Download/parse failures retain the previous good document and fail the sync for retry.
- Reuse the checked [document manifest](connectors/documents/manifest.full.json). FIA requests follow robots.txt and a ten-second interval; do not overlap crawlers.
- Speaker labels come from markup, not person resolution. Publication dates are not event/effective dates. Unknown regulation effective dates remain null, and current glossary pages are not historical 2025 law.
- Do not advertise inclusive lap/stint ranges as many-one: observed overlaps make them ambiguous. Independent telemetry feeds need explicit time alignment. Preserve unexpected telemetry codes rather than clamping them. Championship checkpoints are source snapshots, not reconciled race-point facts. Detailed query limitations are in [the catalog models](dbt/models/agents/).

For SDK debugging, use the Singapore example before a full backfill. Config paths resolve from the connector directory; stop the debugger before reading its DuckDB file. Local document caches use `../../.cache/sources`; hosted checkpoints, not caches, prevent repeat downloads.

Deploy from the connector directory with the SDK environment on PATH. OpenF1 uses `configuration.season.json`; documents use `configuration.production.json`. `fivetran deploy --yes` accepts an existing connection update but may update dependencies; keep hosted/local pins aligned. SDK 2.12.1's `--force` skips dependency upgrades and accepts deployment prompts; use it alone, not together with `--yes`. Keep the base64 API key/secret deploy credential out of logs.

## Minimal Agents Schema

AGENTS is **reader guidance for finished tables only**: meanings, grain, joins, aggregate expressions, query syntax and interpretive limits. Exclude source datasets, identity lookup models, `document_search_input`, and connector/dbt implementation details. The catalog covers 24 finished OpenF1 tables and `f1.document_passages_search`.

Edit the five [SQL models](dbt/models/agents/) directly; they are the source of truth. [root.sql](dbt/models/agents/root.sql) selects one `user`/`user` row with the complete Markdown document in a raw triple-quoted SQL string. The other four models use typed inline rows; TABLES.primary_key is a native ARRAY<STRING>. Keep query examples in ROOT in the `## name`, `Question: ...`, fenced SQL format used by the agent configuration and search inspector.

Build the catalog:

```sh
(cd dbt && python3 ../scripts/with_config.py dbt build --profiles-dir . --select tag:agents_schema --threads 4 --no-manage-state)
```

Use `{{ target.database }}` in inline table references and Markdown examples. Never put account IDs in tracked SQL. Raw triple-double-quoted strings preserve newlines, single/double quotes and backslashes; do not embed a triple-double-quote delimiter without changing the SQL quoting. The [schema naming macro](dbt/macros/generate_schema_name.sql) maps the models' AGENTS schema directly to the canonical dataset; ordinary models keep the normal target schema behavior. Each model explicitly aliases its uppercase table name.

There are no catalog seeds, generator, staging dependency, or publication hook. Models rebuild as tables and update individually; a failed build can leave a partially updated catalog. Refresh the data agent only after all five models succeed. The old `f1_agents_seed` dataset is no longer used; historical staging tables have not been deleted. No automatic whole-warehouse validation runs. [configure_agents_access.py](scripts/configure_agents_access.py) grants AGENTS dataset WRITER access when bootstrapping.

No BI Engine capacity is required. Queries use the configured billing project and US location.

## Browser analytics agent

[scripts/configure_data_agent.py](scripts/configure_data_agent.py) creates or refreshes `projects/__F1_GCP_PROJECT__/locations/us/dataAgents/f1-analyst` from the live five-table AGENTS catalog using ADC. Run it after publishing catalog changes; the agent context is a snapshot, while data queries remain live. Use the US endpoint `geminidataanalytics.us.rep.googleapis.com`; the global endpoint rejects this regional resource. The agent has a 10 GB per-query billed-bytes limit and runs with caller permissions. Its read-only instruction is guidance, not an IAM restriction.

[F1 Analyst in Gemini Enterprise](https://vertexaisearch.cloud.google.com/) is published in the US `f1-demo` application (collection `default_collection`, assistant `default_assistant`, agent ID stored in the local `F1_GEMINI_URL`) using Google Identity. Register it as a custom A2A agent with the card returned by `https://geminidataanalytics.us.rep.googleapis.com/v1beta/a2a/projects/__F1_GCP_PROJECT__/locations/us/dataAgents/f1-analyst/v1/card` and **Default Google-managed credentials**; no gateway or custom OAuth client is needed. The `free_trial_gemini` license configuration expires **2026-11-12**; no paid subscription was created and existing company license allocations were not changed.

## Managed document search

[Search models](dbt/models/search/) merge changed chunks into `f1.document_passages_search` and delete obsolete chunks. Each chunk has at most 120 whitespace-delimited words; concatenation preserves every original character. `embedding_text` adds bounded title/heading/speaker/question and neighboring glossary context. The original text remains available; read each block once with `chunk_index = 0`, ordered by `source_position` within document type/id.

[Search hooks](dbt/macros/document_search.sql) create an asynchronous AI.EMBED column using `text-embedding-005` (768 dimensions), plus `document_passages_hybrid` (IVF/COSINE, lexical_search_columns=['embedding_text']). Hybrid search is Preview. No standalone search index is used.

One-time setup:

```sh
(cd dbt && python3 ../scripts/with_config.py dbt run-operation create_document_embedding_connection --profiles-dir .)
.venv/bin/python scripts/configure_embedding_access.py
```

The US `f1_document_embeddings` connection's service account needs `roles/aiplatform.user`; dbt needs connection-scoped `roles/bigquery.connectionUser`. Vertex AI and BigQuery Connection APIs must be enabled. A fresh IAM grant can lag; the creation hook probes the connection before adding the generated column. Background failures also appear in `INFORMATION_SCHEMA.COLUMNS.async_generation_status`.

Routine refresh/status:

```sh
(cd dbt && python3 ../scripts/with_config.py dbt build --profiles-dir . --select tag:document_search --threads 4 --no-manage-state)
.venv/bin/python scripts/inspect_document_search.py --query
```

Build completion does not mean embedding/index maintenance is complete. The status script reports pending/errors, index coverage and optional uncached hybrid query index usage. Missing embeddings are omitted from AI.SEARCH. Use explicit `mode => 'HYBRID'`; results are relevant evidence, not exhaustive counts. ACTIVE alone does not prove acceleration; check coverage and query statistics.

Keep `on_schema_change='append_new_columns'` so merge leaves the generated embedding intact. `ignore` tries to write it and `sync_all_columns` drops it. Full refresh is disabled to avoid unnecessary regeneration. `content_hash` excludes embeddings and prevents updates to unchanged rows. Model/index migrations must be deliberate. Use whitespace tokenization for chunks; large bounded RE2 repetitions were slow or rejected.

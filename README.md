# F1 data in BigQuery

Two Fivetran Connector SDK connections load 2025 and completed 2026 OpenF1 races, plus 2025 documents, into your configured GCP project (US, Fivetran organization, GCP Direct billing). dbt Fusion 2 builds the approved normalized OpenF1 schema in **`f1`**, preserving the ingestion datasets.

The [Agents Schema catalog](agents/README.md) adds exactly five metadata tables in **`AGENTS`**: `ROOT`, `TABLES`, `DIMENSIONS`, `MEASURES`, and `JOINS`. It documents the 25 finished query tables, column meanings, aggregate SQL and validated relationships. Five dbt seeds and a transactional hook publish it; source and internal tables are excluded.

The [dbt search models](dbt/models/search) maintain **`f1.document_passages_search`**, a shared transcript/regulation/glossary search corpus with original source keys and text. BigQuery generates embeddings and maintains a hybrid keyword/vector index. Refreshes merge changed chunks and remove obsolete ones. See [operations](AGENTS.md#managed-document-search), [query examples](agents/queries/search_transcripts.sql), and the [search status command](scripts/inspect_document_search.py).

**[F1 Analyst in Gemini Enterprise](https://vertexaisearch.cloud.google.com/)** is the browser conversational analytics agent. It uses the 25 finished tables, descriptions, measures, joins and eight query examples from the published AGENTS catalog. Run `.venv/bin/python scripts/configure_data_agent.py` with Google application-default credentials to create or refresh its configuration after catalog changes. This copies metadata into the agent; its answers query live BigQuery data. Browser verification covered a Race-points chart against independent SQL and a conversational follow-up using `AI.SEARCH` in `HYBRID` mode for Hungarian GP tyre-management quotes. The Gemini Enterprise trial expires November 12, 2026; no paid subscription was created.

| Piece | Schema |
|---|---|
| OpenF1 metadata | `f1_openf1.meetings`, `sessions`: one row per meeting/session, keyed by `meeting_key` / `session_key`. |
| Drivers and results | `drivers`, `session_result`, `starting_grid`, `championship_drivers`: one row per session and driver. `championship_teams`: session and team. |
| Laps and tyres | `laps`: session, driver, lap number; timing, sectors, speeds. `stints`: session, driver, stint number; compound and lap range. |
| Telemetry | `car_data`: timestamped speed, RPM, gear, throttle, brake and DRS. `location`: timestamped x/y/z. Both keyed by session, driver and timestamp. |
| Race observations | `position`, `intervals`, `pit`, `overtakes`, `race_control`, `weather`, `team_radio`: source fields in separate typed tables. `sync_status` records each completed request scope and source availability. |
| Official documents | `f1_documents.transcripts`, `regulations`, `glossary`: readable text and typed provenance, keyed by `document_id`. `transcript_passages`, `regulation_sections`, `glossary_sections`: ordered text blocks keyed by document and position. `fetch_status` records retrieval outcomes. |
| dbt | [26 normalized models](dbt/models/openf1), including two source-derived identity lookups, built in `f1`. Shared driver/team identities, session entries, session-specific team colours, country/circuit geography, and typed facts at their original grains. |

OpenF1 table names match its 18 endpoint names. The verified 2025 load contains 26,265 laps and 33.24 million car/location samples across all 24 Grand Prix Race sessions. `starting_grid` contains 480 rows requested from each meeting's main qualifying session, preserving its source session key; associate with the race through `meeting_key`. Meeting/session metadata covers all of 2025. Telemetry preserves every sample returned for each selected race session, including samples outside scheduled race times. The document corpus contains 102 transcripts, eight sporting/technical regulation editions and five current glossary pages, with no gaps in the expected conference types. Those 2025 backfills and repeat syncs succeeded. OpenF1 now accepts multiple seasons and refreshes calendar metadata on every sync; completed-scope checkpoints preserve previous data when adding a season.

The 2026 expansion synced successfully on October 13, 2026 (UTC): 17 completed Grands Prix through Singapore, 374 race entries, 19,645 laps and 26,929,532 car/location samples. Every 2025 source-table count was preserved. Team radio is unavailable (404) for Australia, China, Japan and Miami; other requested 2026 endpoint scopes returned data. The normalized models, identity checks and five metadata seeds were rebuilt successfully.

See [the delivered source schema](SCHEMA.md) for ingestion columns, keys and row counts; [the approved normalized model](PROPOSED_MODEL.md) for the analytical ERD and query examples; and [AGENTS.md](AGENTS.md) for operations. Array-valued lap sector segments remain JSON arrays; all ordinary fields are individual typed columns. There are no generic record/payload tables.

For routine work, run `(cd dbt && python3 ../scripts/with_config.py dbt build --profiles-dir . --threads 4 --no-manage-state)`. The project keeps a small set of key/identity and text-preservation checks; historical profiling reports are reference material, not a mandatory validation pipeline. Catalog-only edits need just the two commands in [agents/README.md](agents/README.md).

## Local configuration

Copy [.env.example](.env.example) to `.env`, fill in your account settings, and restrict it with `chmod 600 .env`. The root `.env` is the central, ignored configuration file. Operational Python scripts load it automatically; exported environment variables take precedence. Keep credentials in your existing external credential store or exported environment. Do not commit live account IDs, emails, credential files, deployment reports, or screenshots of authenticated applications.

Run Fusion with local settings from its project directory:

```sh
(cd dbt && python3 ../scripts/with_config.py dbt parse --profiles-dir . --threads 4 --no-manage-state)
(cd dbt && python3 ../scripts/with_config.py dbt build --profiles-dir . --threads 4 --no-manage-state)
```

SQL examples and catalog seeds use `__F1_GCP_PROJECT__`. The dbt publication hook resolves that placeholder when publishing the five AGENTS tables. To use a standalone SQL example, render it without modifying the tracked file:

```sh
python3 scripts/with_config.py --render agents/queries/grid_to_finish.sql
```

The same command renders [BI Engine setup SQL](infra/agents_bi_engine.sql). Review its output before applying it. Hosted dbt must supply `F1_GCP_PROJECT` and `DBT_CLOUD_PROJECT_ID` in its environment; it does not receive your local `.env`.

Deployment reports, the PowerPoint deck and Gemini screenshots are local-only, ignored artifacts. Their original copies are preserved locally; fresh clones contain the reusable sources and presentation notes instead.

## License

The project code is licensed under the [MIT License](LICENSE). Third-party logos, source documents and other third-party content retain their respective owners' rights.

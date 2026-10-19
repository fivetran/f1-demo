# F1: from API to agent

Two Fivetran connectors load OpenF1 race data and official documents into BigQuery. dbt builds normalized tables, incremental document passages, managed embeddings and hybrid indexes for larger document sources, and publishes the AGENTS context used by F1 Analyst in Gemini Enterprise.

```mermaid
flowchart LR
    O[OpenF1 APIs] --> F[OpenF1 connector]
    D[Rules, glossary, transcripts] --> C[Documents connector]
    F --> S[Source tables]
    C --> S
    subgraph dbt [dbt data workflow]
        S --> N[Normalized models]
        N --> A[AGENTS context]
        S --> P[Incremental passages]
        P --> E[Embeddings + hybrid index]
    end
    A --> G[F1 Analyst + system prompt]
    E --> G
```

| Component | Implementation |
|---|---|
| Ingestion | [OpenF1 connector](connectors/openf1/) and [documents connector](connectors/documents/); sources stay in `f1_openf1` and `f1_documents`. |
| Normalization | [dbt models](dbt/models/openf1/) in `f1`: people, teams, session entries, geography and facts at their original grains. |
| Document search | [Search models](dbt/models/search/) and [hooks](dbt/macros/document_search.sql): changed passages merge; obsolete passages are deleted; BigQuery maintains separate transcript, regulation, and glossary search tables, with indexes for sources of at least 5,000 passages. The agent chooses which to search. |
| Agent context | [Five inline SQL models](dbt/models/agents/) build `AGENTS.ROOT`, `TABLES`, `DIMENSIONS`, `MEASURES`, `JOINS`. |
| Experience | [Agent configuration and system prompt](scripts/configure_data_agent.py), published to [Gemini Enterprise](https://vertexaisearch.cloud.google.com/). |

OpenF1 covers 2025 and completed 2026 races; documents cover 2025 regulations and transcripts plus current glossary pages. Driver numbers identify session entries, not permanent people. Starting grids use Qualifying session keys and join Race sessions through the meeting. [ROOT guidance](dbt/models/agents/root.sql) explains the other query limitations.

## Setup and operation

Use Python 3.12.8 and dbt Fusion 2.0.8. Create `.venv` with `python3.12 -m venv .venv` and install the pinned dependencies with `.venv/bin/python -m pip install -r requirements-dev.txt`. Copy [.env.example](.env.example) to `.env`, supply local settings, and restrict it with `chmod 600 .env`. Use Google application-default credentials; keep credentials outside the repository. See [operations](AGENTS.md) for connector deployment and one-time IAM/embedding setup.

Run the complete ingestion/build workflow on demand:

```sh
.venv/bin/python scripts/run_pipeline.py
```

Or build from already-synced sources with local Fusion:

```sh
(cd dbt && python3 ../scripts/with_config.py dbt build --profiles-dir . --threads 4 --no-manage-state)
```

Edit the five [catalog SQL models](dbt/models/agents/) directly. ROOT selects one `user`/`user` row with a multiline Markdown string; the other models contain inline metadata rows and native primary-key arrays. Build them directly in AGENTS:

```sh
(cd dbt && python3 ../scripts/with_config.py dbt build --profiles-dir . --select tag:agents_schema --threads 4 --no-manage-state)
```

No seeds, generator, or publication hook are needed. Tables update individually, so refresh the agent context only after the complete catalog build succeeds. Check search readiness separately because embeddings and indexing are asynchronous:

```sh
.venv/bin/python scripts/configure_data_agent.py
.venv/bin/python scripts/inspect_document_search.py --query
```

Run connector behavior checks with `.venv/bin/python -m pytest`. Use `dbt parse` with the same profile flags for a parse-only check. There is no recurring schedule; local Fusion is the execution path. The Gemini Enterprise trial expires November 12, 2026.

## License

Project code is licensed under the [MIT License](LICENSE). Third-party content retains its owners' rights.

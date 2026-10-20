# F1: from API to agent

Two Fivetran connectors load OpenF1 race data and official documents into BigQuery. dbt builds normalized racing tables and one-to-one document tables with embeddings computed in dbt and hybrid indexes, and publishes the AGENTS context used by F1 Analyst in Gemini Enterprise.

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
| Normalization | [dbt models](models/openf1/) in `f1`: people, teams, session entries, geography and facts at their original grains. |
| Document search | [Native document models](models/documents/) preserve each collection's schema one-to-one. The three passage models compute embeddings in their SELECT queries; [idempotent hooks](macros/document_search.sql) create hybrid indexes. Parent metadata stays separate and is joined for citations. |
| Agent context | The [publication macro](macros/publish_agents_schema.sql) builds `agents.root`, `dbt_tables`, `dbt_columns`, `dbt_joins`. |
| Experience | [Agent configuration and system prompt](scripts/configure_data_agent.py), published to [Gemini Enterprise](https://vertexaisearch.cloud.google.com/). |

OpenF1 covers 2025 and completed 2026 races; documents cover 2025 regulations and transcripts plus current glossary pages. Driver numbers identify session entries, not permanent people. Starting grids use Qualifying session keys and join Race sessions through the meeting. [ROOT guidance](macros/publish_agents_schema.sql) explains the other query limitations.

The document connector discovers transcripts from the FIA sitemap from `transcript_start_year` (currently `2025`) through the current UTC year, inclusive. Each sync automatically includes new years. Legacy `transcript_years` configurations use their earliest year as the start. Publication dates associate transcripts with race weekends using the OpenF1 calendar. Regulations and glossary pages use fixed URLs in the [document manifest](connectors/documents/manifest.full.json). A transcript disappearing from the sitemap does not delete previously ingested text.

## Setup and operation

Use Python 3.12.8 and dbt Fusion 2.0.8. Create `.venv` with `python3.12 -m venv .venv`. Install connector and test dependencies with `.venv/bin/python -m pip install -r connectors/tests/requirements.txt`, and analyst deployment dependencies with `.venv/bin/python -m pip install -r scripts/requirements.txt`. Each connector retains its own deployment requirements. Use Google application-default credentials; keep credentials outside the repository. See [operations](AGENTS.md) for connector deployment and one-time IAM/embedding setup.

Add the following named profile to `~/.dbt/profiles.yml`, preserving any other profiles. Replace the project placeholder with your GCP project ID. dbt uses this local profile directly. Keep the project ID in `scripts/configure_data_agent.py` aligned with this profile; no `.env` file is required.

```yaml
f1_demo:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: your-gcp-project
      dataset: f1
      location: US
      threads: 4
```

Deploy connectors with the Fivetran Connector SDK and trigger syncs in Fivetran. After successful syncs, build with local Fusion from the repository root:

```sh
dbt build --threads 4
```

Edit table and column descriptions in [OpenF1 schema.yml](models/openf1/schema.yml) and [document schema.yml](models/documents/schema.yml). Model `config.meta.agent_catalog` holds primary keys, row filters and joins, and opts models into the catalog. The [on-run-end macro](macros/publish_agents_schema.sql) publishes all four catalog tables after successful nonempty `run`/`build` commands, including focused selections. ROOT dataset overview and unstructured retrieval guidance live in the macro’s `root_content` block. Refresh all four catalog tables in `agents`:

```sh
dbt run-operation publish_agents_schema
```

No seeds or external generator are needed. The hook publishes metadata for all catalog-marked models, not just the selected models. Tables update individually, so refresh the agent context only after the complete catalog publication succeeds. Embedding failures fail the model load; index maintenance is asynchronous. Deploy or refresh the analyst from the successfully published catalog using ADC:

```sh
.venv/bin/python scripts/configure_data_agent.py
```

Run connector behavior checks with `.venv/bin/python -m pytest`. Use `dbt parse` with the same profile flags for a parse-only check. There is no recurring schedule; local Fusion is the execution path. The Gemini Enterprise trial expires November 12, 2026.

## License

Project code is licensed under the [MIT License](LICENSE). Third-party content retains its owners' rights.

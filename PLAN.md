# Current implementation plan

The endpoint-table reset requested on 2026-10-08 replaced the original generic-record and embedding design. The user authorized a truncated 2025 replacement backfill on 2026-10-11.

1. Keep the dedicated Fivetran GCP project and existing new Fivetran/dbt accounts, using GCP Direct billing.
2. Deliver one typed table for each of OpenF1's 18 endpoints. Preserve source names and fields; declare stable upsert keys. Cover 2025 metadata and all 24 Grand Prix Race sessions; fetch starting grids through the matching qualifying sessions.
3. Deliver official documents as readable transcript, regulation and glossary tables, with typed provenance and ordered sections.
4. Replace the previous connections and destination data. Remove old transformations, generic raw tables, embedding tables/models and obsolete validation datasets.
5. Validate with unit tests, the Connector SDK debugger, hosted Fivetran syncs, and direct BigQuery schema/count/key checks.
6. Implement the normalized OpenF1 model approved on 2026-10-11 with dbt Fusion 2 in `f1`, preserving source data. Separate people, teams, session entries and session-specific team colours; normalize geography and preserve fact grains.
7. Validate keys, relationships, identity mappings, row/value preservation and unchanged source tables. Record the approved design in [PROPOSED_MODEL.md](PROPOSED_MODEL.md), source schemas in [SCHEMA.md](SCHEMA.md), and normalized build evidence in [inventory/normalized_schema.json](inventory/normalized_schema.json).

Operational details belong in [AGENTS.md](AGENTS.md); [README.md](README.md) is the short project overview.

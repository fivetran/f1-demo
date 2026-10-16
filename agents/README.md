# Minimal F1 Agents Schema

The BigQuery dataset `__F1_GCP_PROJECT__.AGENTS` implements the [Agents Schema ROOT contract](https://github.com/dbt-labs/agents_schema/blob/a0bc90498302c8abb15a5e98a54c8c94df5a52f8/SPEC.md) plus four custom dimensional metadata tables. It describes the existing data without creating a new fact model or copying measurements.

| Table | Columns | Grain |
|---|---|---|
| `ROOT` | `provider`, `key`, `content` | One discovery/guidance document per provider/key. |
| `TABLES` | `table_name`, `description`, `primary_key ARRAY<STRING>`, `row_filter` | One fully qualified data relation. |
| `DIMENSIONS` | `table_name`, `column_name`, `data_type`, `description` | One physical column, including raw numeric observations usable as filters. |
| `MEASURES` | `table_name`, `measure_name`, `sql_expression`, `description` | One named aggregate with aggregation restrictions. |
| `JOINS` | `join_name`, `from_table`, `to_table`, `join_type`, `sql_expression`, `description` | One directed relationship, including role-specific joins. |

`ROOT` uses provider `f1`. The custom tables are documented by the unprefixed ROOT keys `tables`, `dimensions`, `measures`, `joins`. Other ROOT rows contain the overview, twenty question patterns, and tested SQL recipes. There are no embeddings or additional semantic tables inside AGENTS; the search corpus lives in f1.

Published AGENTS content is reader guidance: query syntax, grain, joins, filters, meanings and limitations. Connector/dbt implementation, maintenance and deployment instructions belong only in this repository. Coverage and embedding availability remain documented because they affect query results.

Start here:

```sql
SELECT key, content
FROM `__F1_GCP_PROJECT__.AGENTS.ROOT`
WHERE provider = 'f1';

SELECT measure_name, sql_expression, description
FROM `__F1_GCP_PROJECT__.AGENTS.MEASURES`
WHERE table_name = '__F1_GCP_PROJECT__.f1.laps';
```

Measures use `t` for the base relation; join predicates use `l` for `from_table` and `r` for `to_table`. `join_type` is maximum cardinality (`one-one`, `one-many`, `many-one`), not SQL INNER/LEFT. Optional references require LEFT JOIN. Apply each relation's `row_filter` before an outer join. A column appearing in DIMENSIONS does not mean its numbers can be summed. MEASURES contains complete aggregate SQL, with units, denominators, exclusions and non-additivity explained in descriptions.

The [catalog](catalog.yml) covers 24 finished OpenF1 tables and the document-search table, all in `f1`. Source document tables, the two internal identity lookups and the search preparation view are excluded from query discovery. Document examples read full blocks and adjacent context directly from the search table. The [ROOT guidance](ROOT.md) contains the scope, aggregation and hybrid-retrieval rules; [twenty motivating questions](QUESTIONS.md) describe coverage; [query examples](queries/) also demonstrate hybrid retrieval of transcripts, regulations and glossary passages.

The schema deliberately omits unsafe relationships: inclusive lap/stint matching is ambiguous on 80 laps; independent sampled feeds require explicit time alignment; textual speaker labels do not establish person identity. The catalog also records observed telemetry codes outside documented ranges and the difference between source championship snapshots and classified results. Historical profiling evidence is retained locally in ignored inventory reports. OpenF1 units and documented codes were checked against its [API reference](https://openf1.org/docs/); observations of actual values take precedence over assumed ranges.

Publication is owned by dbt. Five [CSV seeds](../dbt/seeds/agents) load into `f1_agents_seed`, then a small [transactional hook](../dbt/macros/publish_agents.sql) updates the five public tables. It resolves `__F1_GCP_PROJECT__` to the configured target project, decodes ROOT text and primary-key arrays, preserves other ROOT providers and retains table identity/BI Engine preferences.

After editing the authoring inputs, run from the repository root:

```sh
.venv/bin/python scripts/render_agents_seeds.py
(cd dbt && python3 ../scripts/with_config.py dbt seed --profiles-dir . --select tag:agents_schema --threads 4 --no-manage-state)
```

Commit the generated seeds with the catalog changes. A full `dbt build` also publishes after all selected nodes succeed; partial seed batches fail and failed invocations skip publication. Production dbt reads committed seeds without Python. Publication does not revalidate the racing data or execute every example query.

The project's US BI Engine reservation has 1 GiB and prefers exactly the five AGENTS tables. It is configured outside dbt by [infrastructure SQL](../infra/agents_bi_engine.sql). Queries must run in billing project `__F1_GCP_PROJECT__`, location US. Reservation membership does not guarantee acceleration for every query; use job statistics to check. See [operations](../AGENTS.md) for access and setup.

# Schema renders for slide 15

Rendered with Mermaid 12.2.0 in headless Chrome, at two raster pixels per CSS pixel. Each `.mmd` file is the complete table-name-only ER diagram; `.svg` and `-full.png` are the rendered diagram; `-crop.png` is the actual crop used in the presentation. `crops.json` records crop coordinates.

Sources: `SCHEMA.md`, `PROPOSED_MODEL.md`, `dbt/models/openf1/`, `dbt/macros/document_search.sql`, and `dbt/seeds/agents/schema.yml`.

The source crop focuses on OpenF1 driver-entry records and endpoint tables. The full source render also includes all seven document-source tables. The normalized crop focuses on session entries and related fact tables. The full normalized render includes the 26 approved normalized tables plus document search. The AGENTS crop shows TABLES, DIMENSIONS, MEASURES, and JOINS; ROOT is beyond the left crop edge.

Crow’s feet represent logical join cardinalities, not enforced BigQuery foreign keys. Dashed AGENTS lines represent catalog and navigation references. ROOT-to-TABLES is navigation rather than a relational foreign-key join. No column detail is rendered.

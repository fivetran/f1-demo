"""Read actual BigQuery schemas and verify row counts, keys and source completeness."""

import importlib.util
import json
import os
from datetime import datetime, timezone
from pathlib import Path

from google.cloud import bigquery
from local_config import load_config

load_config()

ROOT = Path(__file__).resolve().parents[1]
PROJECT = os.environ["F1_GCP_PROJECT"]
client = bigquery.Client(project=PROJECT)
report = {"project": PROJECT, "observed_at": datetime.now(timezone.utc).isoformat(), "tables": []}
errors = []
for kind in ("openf1", "documents"):
    spec = importlib.util.spec_from_file_location(kind, ROOT / "connectors" / kind / "connector.py")
    connector = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(connector)
    dataset = os.getenv(f"F1_{kind.upper()}_DATASET", f"f1_{kind}")
    expected = {t["table"]: dict(t) for t in connector.schema({})}
    # Standard Fivetran naming separates letters and digits in these source names.
    for definition in expected.values():
        definition["columns"] = {
            {"i1_speed": "i_1_speed", "i2_speed": "i_2_speed"}.get(k, k): v
            for k, v in definition["columns"].items()
        }
    observed = {t.table_id: t for t in client.list_tables(dataset)}
    for name in observed.keys() - expected.keys():
        errors.append(f"Unexpected table: {dataset}.{name}")
    for name, definition in expected.items():
        if name not in observed:
            errors.append(f"Missing table: {dataset}.{name}")
            continue
        table = client.get_table(observed[name].reference)
        columns = {c.name: c for c in table.schema}
        missing = definition["columns"].keys() - columns.keys()
        if missing:
            errors.append(f"Missing columns: {dataset}.{name}: {sorted(missing)}")
        type_names = {
            "STRING": "STRING",
            "LONG": "INTEGER",
            "DOUBLE": "FLOAT",
            "BOOLEAN": "BOOLEAN",
            "JSON": "JSON",
            "UTC_DATETIME": "TIMESTAMP",
        }
        for column, kind_type in definition["columns"].items():
            if column in columns and columns[column].field_type != type_names[kind_type]:
                errors.append(
                    f"Type mismatch: {dataset}.{name}.{column}: "
                    f"expected {type_names[kind_type]}, got {columns[column].field_type}"
                )
        keys = definition["primary_key"]
        where = (
            "WHERE NOT COALESCE(_fivetran_deleted, FALSE)" if "_fivetran_deleted" in columns else ""
        )
        quoted_keys = ", ".join(f"`{k}`" for k in keys)
        nulls = " OR ".join(f"`{k}` IS NULL" for k in keys)
        sql = f"""SELECT COUNT(*) row_count,
          COUNTIF({nulls}) null_keys,
          COUNT(*) - COUNT(DISTINCT TO_JSON_STRING(STRUCT({quoted_keys}))) duplicate_keys
          FROM `{PROJECT}.{dataset}.{name}` {where}"""
        counts = dict(next(iter(client.query(sql).result())))
        if counts["null_keys"] or counts["duplicate_keys"]:
            errors.append(f"Invalid primary keys: {dataset}.{name}: {counts}")
        report["tables"].append(
            {
                "dataset": dataset,
                "table": name,
                "primary_key": keys,
                **counts,
                "columns": [
                    {"name": c.name, "type": c.field_type, "mode": c.mode} for c in table.schema
                ],
            }
        )
        print(f"{dataset}.{name}: {counts['row_count']:,} rows", flush=True)
    if kind == "openf1" and "sync_status" in observed:
        statuses = [
            dict(r)
            for r in client.query(f"""
            SELECT endpoint, status, COUNT(*) scopes, SUM(row_count) row_count
            FROM `{PROJECT}.{dataset}.sync_status` WHERE NOT _fivetran_deleted
            GROUP BY endpoint, status ORDER BY endpoint, status""").result()
        ]
        report["endpoint_status"] = statuses
        config = json.loads((ROOT / "connectors/openf1/configuration.season.json").read_text())
        selection = config.get("meeting_keys", "all")
        meeting_keys = None if selection == "all" else {int(k) for k in selection.split(",")}
        sessions = [
            dict(r)
            for r in client.query(
                f"SELECT session_key, meeting_key, year "
                f"FROM `{PROJECT}.{dataset}.sessions` WHERE session_name='Race' "
                "AND NOT COALESCE(is_cancelled,FALSE) AND NOT _fivetran_deleted"
            ).result()
        ]
        races = {
            r["session_key"]
            for r in sessions
            if r["year"] == int(config["year"])
            and (meeting_keys is None or r["meeting_key"] in meeting_keys)
        }
        endpoints = config.get("endpoints", ",".join(connector.ENDPOINTS)).split(",")
        expected_scopes = {
            (e, str(key))
            for key in races
            for e in endpoints
            if e not in connector.TELEMETRY and e != "starting_grid"
        }
        if "starting_grid" in endpoints:
            all_sessions = [
                dict(r)
                for r in client.query(
                    f"SELECT session_key, meeting_key, session_name, is_cancelled "
                    f"FROM `{PROJECT}.{dataset}.sessions` WHERE NOT _fivetran_deleted"
                ).result()
            ]
            expected_scopes.update(
                (
                    "starting_grid",
                    str(connector.starting_grid_session(all_sessions, r)["session_key"]),
                )
                for r in all_sessions
                if r["session_key"] in races
            )
        expected_scopes.update((e, config["year"]) for e in ("meetings", "sessions"))
        for row in client.query(
            f"SELECT session_key, driver_number FROM `{PROJECT}.{dataset}.drivers` "
            "WHERE NOT _fivetran_deleted"
        ).result():
            if row.session_key in races:
                expected_scopes.update(
                    (e, f"{row.session_key}:{row.driver_number}")
                    for e in endpoints
                    if e in connector.TELEMETRY
                )
        actual_scopes = {
            (r.endpoint, r.scope)
            for r in client.query(
                f"SELECT endpoint, scope FROM `{PROJECT}.{dataset}.sync_status` WHERE NOT _fivetran_deleted"
            ).result()
        }
        report["race_sessions"] = len(races)
        report["expected_scopes"] = len(expected_scopes)
        if expected_scopes - actual_scopes:
            errors.append(
                f"Incomplete endpoint coverage: {len(expected_scopes - actual_scopes)} missing scopes"
            )
        if actual_scopes - expected_scopes:
            errors.append(
                f"Unexpected endpoint coverage: {len(actual_scopes - expected_scopes)} extra scopes"
            )
        for metadata_table in ("meetings", "sessions"):
            unexpected_years = next(
                iter(
                    client.query(
                        f"SELECT COUNTIF(year IS NULL OR year != {int(config['year'])}) n "
                        f"FROM `{PROJECT}.{dataset}.{metadata_table}`"
                    ).result()
                )
            ).n
            if unexpected_years:
                errors.append(f"Unexpected season remains in {metadata_table}")
        for table in report["tables"]:
            if table["dataset"] != dataset or table["table"] == "sync_status":
                continue
            source_count = sum(s["row_count"] for s in statuses if s["endpoint"] == table["table"])
            if source_count != table["row_count"]:
                errors.append(
                    f"Count mismatch: {table['table']} source {source_count}, delivered {table['row_count']}"
                )
    if kind == "documents" and "fetch_status" in observed:
        report["document_status"] = [
            dict(r)
            for r in client.query(f"""
            SELECT status, COUNT(*) documents FROM `{PROJECT}.{dataset}.fetch_status`
            WHERE NOT _fivetran_deleted GROUP BY status""").result()
        ]
        for status in report["document_status"]:
            if status["status"] not in ("parsed", "deleted", "unavailable"):
                errors.append(f"Document failure: {status}")
        manifest = json.loads((ROOT / "connectors/documents/manifest.full.json").read_text())
        expected_urls = {item["url"] for item in manifest}
        actual_urls = {
            r.source_url
            for r in client.query(
                f"SELECT source_url FROM `{PROJECT}.{dataset}.fetch_status` WHERE NOT _fivetran_deleted"
            ).result()
        }
        if expected_urls != actual_urls:
            errors.append("Document manifest/fetch-status URL mismatch")
        for document_type, (parent, child) in connector.KINDS.items():
            if parent not in observed or child not in observed:
                continue
            expected_parent_urls = {
                item["url"] for item in manifest if item["document_type"] == document_type
            }
            actual_parent_urls = {
                row.source_url
                for row in client.query(
                    f"SELECT source_url FROM `{PROJECT}.{dataset}.{parent}` "
                    "WHERE NOT _fivetran_deleted"
                ).result()
            }
            if expected_parent_urls != actual_parent_urls:
                errors.append(f"Document manifest/parent URL mismatch: {parent}")
            count = next(
                iter(
                    client.query(f"""SELECT COUNT(*) n FROM
                (SELECT document_id, section_count FROM `{PROJECT}.{dataset}.{parent}` WHERE NOT _fivetran_deleted) p
                FULL JOIN (SELECT document_id, COUNT(*) actual FROM `{PROJECT}.{dataset}.{child}`
                           WHERE NOT _fivetran_deleted GROUP BY document_id) c USING(document_id)
                WHERE p.document_id IS NULL OR section_count != COALESCE(actual,0)""").result()
                )
            ).n
            if count:
                errors.append(f"Section count mismatch/orphan: {parent}/{child}: {count}")
report["errors"] = errors
(ROOT / "inventory/delivered_schema.json").write_text(json.dumps(report, indent=2) + "\n")
lines = [
    "# Delivered BigQuery schema",
    "",
    f"Project: `{PROJECT}`. Observed: {report['observed_at']}.",
    "",
    "Schemas and counts below are read from BigQuery. Keys are connector upsert keys; BigQuery does not enforce them.",
    "",
    "Fivetran adds `_fivetran_synced` and `_fivetran_deleted`. Filter deleted rows in downstream queries.",
    "",
    "Validation: " + ("FAILED — " + "; ".join(errors) if errors else "passed"),
    "",
]
if report.get("endpoint_status"):
    lines += [
        "## Endpoint coverage",
        "",
        "HTTP 404 means source data is unavailable; it does not mean no activity occurred.",
        "",
        "| Endpoint | Availability | Request scopes | Source rows |",
        "|---|---|---:|---:|",
    ]
    lines += [
        f"| `{r['endpoint']}` | {r['status']} | {r['scopes']} | {r['row_count']:,} |"
        for r in report["endpoint_status"]
    ]
    lines.append("")
for table in report["tables"]:
    lines += [
        f"## {table['dataset']}.{table['table']}",
        "",
        f"{table['row_count']:,} active rows. Key: `{'`, `'.join(table['primary_key'])}`.",
        "",
        "| Column | BigQuery type |",
        "|---|---|",
    ]
    lines += [f"| `{c['name']}` | {c['type']} |" for c in table["columns"]]
    lines.append("")
(ROOT / "SCHEMA.md").write_text("\n".join(lines))
if errors:
    raise RuntimeError("; ".join(errors))
print("Verified source counts, unique non-null keys, document sections, and expected tables.")

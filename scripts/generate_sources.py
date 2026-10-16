"""Regenerate sources-only dbt YAML from the connector schema declarations."""

import importlib.util
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
TYPES = {
    "STRING": "STRING",
    "LONG": "INT64",
    "DOUBLE": "FLOAT64",
    "BOOLEAN": "BOOL",
    "JSON": "JSON",
    "UTC_DATETIME": "TIMESTAMP",
}
sources = []
for name in ("openf1", "documents"):
    spec = importlib.util.spec_from_file_location(name, ROOT / "connectors" / name / "connector.py")
    connector = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(connector)
    tables = []
    for table in connector.schema({}):
        description = "Connector primary key: " + ", ".join(table["primary_key"]) + "."
        if name == "openf1" and table["table"] == "starting_grid":
            description += (
                " session_key is the Grand Prix qualifying session; associate with the race"
                " through meeting_key. This is the grid published by OpenF1 for qualifying."
            )
        tables.append(
            {
                "name": table["table"],
                "description": description,
                "columns": [
                    {
                        "name": {"i1_speed": "i_1_speed", "i2_speed": "i_2_speed"}.get(key, key),
                        "data_type": TYPES[kind],
                    }
                    for key, kind in table["columns"].items()
                ],
            }
        )
    sources.append(
        {
            "name": name,
            "database": "{{ env_var('F1_GCP_PROJECT') }}",
            "schema": "{{ env_var('F1_" + name.upper() + "_DATASET', 'f1_" + name + "') }}",
            "tables": tables,
        }
    )
(ROOT / "dbt/models/sources.yml").write_text(
    yaml.safe_dump({"version": 2, "sources": sources}, sort_keys=False)
)

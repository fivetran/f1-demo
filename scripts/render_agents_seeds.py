"""Render the reader catalog as five dbt CSV seeds. No warehouse writes."""

import csv
import io
import json
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
PROJECT = "__F1_GCP_PROJECT__"


def payload(catalog):
    docs = {
        "overview": (ROOT / "agents/ROOT.md").read_text(),
        "tables": "TABLES: one physical relation per row. table_name is fully qualified; primary_key is the grain. Apply row_filter with alias t before joins. Descriptions explain scope and limitations.",
        "dimensions": "DIMENSIONS: one physical column per row, including identifiers, categories, text, timestamps and raw numeric observations. Numeric columns are not automatically additive. column_name is literal; data_type matches BigQuery.",
        "measures": "MEASURES: one named aggregate per table. sql_expression is a complete BigQuery aggregate using table alias t. Apply TABLES.row_filter and description constraints first. Recompute averages/ratios from base rows; do not sum averages. Snapshot measures require one checkpoint. All aggregates must preserve the base table grain.",
        "joins": "JOINS: one named directed relationship. from_table uses alias l, to_table uses r. sql_expression is the ON predicate, not a full SELECT. join_type means maximum cardinality (one-one, one-many, many-one), not INNER/LEFT. Optional relationships require LEFT JOIN. Filter both inputs before joining. Reverse joins invert cardinality. Never infer a safe fact-to-fact join from a shared dimension.",
        "example_questions": (ROOT / "agents/QUESTIONS.md").read_text(),
    }
    docs["query_recipes"] = "\n\n".join(
        f"## {path.stem}\n```sql\n{path.read_text().strip()}\n```"
        for path in sorted((ROOT / "agents/queries").glob("*.sql"))
    )
    result = {name: [] for name in ["ROOT", "TABLES", "DIMENSIONS", "MEASURES", "JOINS"]}
    result["ROOT"] = [dict(provider="f1", key=key, content=value) for key, value in docs.items()]
    for t in catalog["tables"]:
        full_name = f"{PROJECT}.{t['table_name']}"
        result["TABLES"].append(
            dict(
                table_name=full_name,
                description=t["description"],
                primary_key=t["primary_key"],
                row_filter=t["row_filter"],
            )
        )
        result["DIMENSIONS"] += [dict(table_name=full_name, **d) for d in t["dimensions"]]
        result["MEASURES"] += [dict(table_name=full_name, **m) for m in t["measures"]]
    result["JOINS"] = [
        dict(j, from_table=f"{PROJECT}.{j['from_table']}", to_table=f"{PROJECT}.{j['to_table']}")
        for j in catalog["joins"]
    ]
    return result


def main():
    catalog = yaml.safe_load((ROOT / "agents/catalog.yml").read_text())
    for name, rows in payload(catalog).items():
        stream = io.StringIO(newline="")
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]), lineterminator="\n")
        writer.writeheader()
        for row in rows:
            # Fusion's seed loader needs ROOT's multiline text encoded on one line.
            writer.writerow({
                key: json.dumps(value, ensure_ascii=False)
                if isinstance(value, list) or (name == "ROOT" and key == "content")
                else value for key, value in row.items()
            })
        (ROOT / f"dbt/seeds/agents/agents_{name.lower()}.csv").write_text(stream.getvalue())
    print("Rendered five dbt seeds")


if __name__ == "__main__":
    main()

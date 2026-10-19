"""Show asynchronous embedding/index readiness and optionally try a hybrid query."""

import argparse
import json
import os
import re

from google.cloud import bigquery
from local_config import load_config

load_config()

PROJECT = os.environ["F1_GCP_PROJECT"]
COLLECTIONS = {"transcript": "transcript_passages", "regulation": "regulation_sections", "glossary": "glossary_sections"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--query", action="store_true", help="Run each source hybrid example and show index usage")
    args = parser.parse_args()
    client = bigquery.Client(project=PROJECT, location="US")
    tables = ", ".join(f"'{table}'" for table in COLLECTIONS.values())
    queries = {
        "embeddings": " UNION ALL ".join(f"""
            SELECT '{kind}' AS source, COUNT(*) AS passages,
              COUNTIF(embedding.status = '' AND ARRAY_LENGTH(embedding.result) = 3072) AS ready,
              COUNTIF(embedding IS NULL OR embedding.status IS NULL) AS pending,
              COUNTIF(embedding.status != '') AS errors
            FROM `{PROJECT}.f1_documents.{table}`
            WHERE NOT COALESCE(_fivetran_deleted, FALSE)
        """ for kind, table in COLLECTIONS.items()),
        "generation": f"""
            SELECT table_name, async_generation_status
            FROM `{PROJECT}.f1_documents.INFORMATION_SCHEMA.COLUMNS`
            WHERE table_name IN ({tables}) AND column_name = 'embedding'
        """,
        "index": f"""
            SELECT table_name, index_name, index_status, coverage_percentage, last_refresh_time
            FROM `{PROJECT}.f1_documents.INFORMATION_SCHEMA.VECTOR_INDEXES`
            WHERE table_name IN ({tables})
        """,
    }
    for name, sql in queries.items():
        print(name + ": " + json.dumps([dict(r) for r in client.query(sql).result()], default=str))
    if args.query:
        guidance = next(iter(client.query(
            f"SELECT content FROM `{PROJECT}.AGENTS.ROOT` WHERE provider = 'user' AND key = 'user'"
        ).result()))["content"]
        for example in ("search_transcripts", "search_regulations", "search_glossary"):
            sql = re.search(rf"^## {example}\n.*?```sql\n(.*?)\n```", guidance, re.M | re.S).group(1)
            job = client.query(sql, job_config=bigquery.QueryJobConfig(use_query_cache=False))
            rows = [dict(row) for row in job.result()]
            job.reload()
            print(json.dumps({
                "example": example,
                "matches": rows,
                "index_usage": job._properties["statistics"]["query"].get("vectorSearchStatistics"),
            }, indent=2, default=str))



if __name__ == "__main__":
    main()

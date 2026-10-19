"""Show asynchronous embedding/index readiness and optionally try a hybrid query."""

import argparse
import json
import os
import re

from google.cloud import bigquery
from local_config import load_config

load_config()

PROJECT = os.environ["F1_GCP_PROJECT"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--query", action="store_true", help="Run the transcript hybrid example and show index usage")
    args = parser.parse_args()
    client = bigquery.Client(project=PROJECT, location="US")
    queries = {
        "embeddings": f"""
            SELECT document_type, COUNT(*) AS chunks,
              COUNTIF(embedding.status = '' AND ARRAY_LENGTH(embedding.result) = 768) AS ready,
              COUNTIF(embedding IS NULL OR embedding.status IS NULL) AS pending,
              COUNTIF(embedding.status != '') AS errors
            FROM `{PROJECT}.f1.document_passages_search`
            GROUP BY document_type ORDER BY document_type
        """,
        "generation": f"""
            SELECT async_generation_status
            FROM `{PROJECT}.f1.INFORMATION_SCHEMA.COLUMNS`
            WHERE table_name = 'document_passages_search' AND column_name = 'embedding'
        """,
        "index": f"""
            SELECT index_name, index_status, coverage_percentage, last_refresh_time
            FROM `{PROJECT}.f1.INFORMATION_SCHEMA.VECTOR_INDEXES`
            WHERE table_name = 'document_passages_search'
        """,
    }
    for name, sql in queries.items():
        print(name + ": " + json.dumps([dict(r) for r in client.query(sql).result()], default=str))
    if args.query:
        guidance = next(iter(client.query(
            f"SELECT content FROM `{PROJECT}.AGENTS.ROOT` WHERE provider = 'user' AND key = 'user'"
        ).result()))["content"]
        sql = re.search(r"^## search_transcripts\n.*?```sql\n(.*?)\n```", guidance, re.M | re.S).group(1)
        job = client.query(
            sql.replace("__F1_GCP_PROJECT__", PROJECT),
            job_config=bigquery.QueryJobConfig(use_query_cache=False),
        )
        rows = [dict(row) for row in job.result()]
        job.reload()
        print(json.dumps({
            "matches": rows,
            "index_usage": job._properties["statistics"]["query"].get("vectorSearchStatistics"),
        }, indent=2, default=str))


if __name__ == "__main__":
    main()

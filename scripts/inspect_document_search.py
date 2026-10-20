"""Show embedding/index readiness and optionally try vector, keyword and hybrid queries."""

import argparse
import json
import os

from google.cloud import bigquery
from local_config import load_config

load_config()

PROJECT = os.environ["F1_GCP_PROJECT"]
COLLECTIONS = {"transcript": "transcript_passages", "regulation": "regulation_sections", "glossary": "glossary_sections"}


# Standalone smoke queries; ROOT contains only reader guidance.
SEARCH_QUERIES = {
    "search_transcripts": f"""
select hits.base.document_id, hits.base.position, d.title,
       hits.base.text, d.source_url, hits.base.speaker, hits.base.question, hits.distance
from vector_search(
    (select p.* from `{PROJECT}.f1.transcript_passages` p
     where p.document_id in (
         select d.document_id from `{PROJECT}.f1.transcripts` d where d.conference_type = 'post-race')),
    'embedding',
    query_value => ai.embed('tyre degradation and managing the tyres during the race',
        endpoint => 'gemini-embedding-2').result,
    lexical_search_columns => ['text'],
    lexical_search_query_value => 'tyre degradation and managing the tyres during the race',
    distance_type => 'COSINE', top_k => 5
) hits
join `{PROJECT}.f1.transcripts` d
  on hits.base.document_id = d.document_id
""",
    "search_regulations": f"""
select p.document_id, p.position, d.title, p.section,
       p.text, d.source_url, d.rule_family, d.effective_from, d.effective_to
from `{PROJECT}.f1.regulation_sections` p
join `{PROJECT}.f1.regulations` d on p.document_id = d.document_id
where search(p.text, 'lasting advantage')
order by p.document_id, p.position
limit 20
""",
    "search_glossary": f"""
select hits.base.document_id, hits.base.position, d.title,
       hits.base.text, d.source_url, hits.distance
from vector_search(
    (select p.* from `{PROJECT}.f1.glossary_sections` p
     where p.document_id in (
         select d.document_id from `{PROJECT}.f1.glossary` d)),
    'embedding',
    query_value => ai.embed('dirty air and loss of downforce when following another car',
        endpoint => 'gemini-embedding-2').result,
    distance_type => 'COSINE', top_k => 5
) hits
join `{PROJECT}.f1.glossary` d
  on hits.base.document_id = d.document_id
""",
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--query", action="store_true", help="Run the vector, keyword and hybrid examples and show index usage")
    args = parser.parse_args()
    client = bigquery.Client(project=PROJECT, location="US")
    tables = ", ".join(f"'{table}'" for table in COLLECTIONS.values())
    queries = {
        "embeddings": " UNION ALL ".join(f"""
            SELECT '{kind}' AS source, COUNT(*) AS passages,
              COUNTIF(ARRAY_LENGTH(embedding) = 3072) AS ready,
              COUNTIF(embedding IS NULL OR ARRAY_LENGTH(embedding) != 3072) AS invalid
            FROM `{PROJECT}.f1.{table}`
        """ for kind, table in COLLECTIONS.items()),
        "index": f"""
            SELECT table_name, index_name, index_status, coverage_percentage, last_refresh_time
            FROM `{PROJECT}.f1.INFORMATION_SCHEMA.VECTOR_INDEXES`
            WHERE table_name IN ({tables})
        """,
    }
    for name, sql in queries.items():
        print(name + ": " + json.dumps([dict(r) for r in client.query(sql).result()], default=str))
    if args.query:
        for example, sql in SEARCH_QUERIES.items():
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

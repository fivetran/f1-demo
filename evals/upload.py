"""Load an eval JSONL report into BigQuery, including failed/partial runs."""

import argparse
from collections import Counter
import json
import os
from pathlib import Path
import re
import sys

from google.api_core.exceptions import Conflict
from google.cloud import bigquery

from questions import QUESTIONS

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'agents'))
from configure_data_agent import PROJECT


def upload(client, report, run_id, commit_sha, run_url, expected_count):
    rows = [json.loads(line) for line in report.read_text().splitlines() if line.strip()]
    if not rows:
        raise ValueError('No completed questions to upload')
    run_started_at = min(row['started_at'] for row in rows)
    for row in rows:
        row.update(run_id=run_id, commit_sha=commit_sha, run_url=run_url,
                   run_started_at=run_started_at, expected_count=expected_count,
                   completed_count=len(rows))
    schema = [bigquery.SchemaField(name, kind) for name, kind in [
        ('run_id', 'STRING'), ('commit_sha', 'STRING'), ('run_url', 'STRING'),
        ('run_started_at', 'TIMESTAMP'), ('expected_count', 'INTEGER'),
        ('completed_count', 'INTEGER'), ('id', 'STRING'), ('category', 'STRING'),
        ('question', 'STRING'), ('expected', 'STRING'), ('answer', 'STRING'),
        ('seed', 'INTEGER'), ('agent', 'STRING'), ('started_at', 'TIMESTAMP'),
        ('response', 'STRING'), ('messages', 'JSON'), ('status', 'STRING'),
        ('error_type', 'STRING'), ('seconds', 'FLOAT'),
    ]] + [bigquery.SchemaField('choices', 'STRING', mode='REPEATED')]
    config = bigquery.LoadJobConfig(
        schema=schema, write_disposition='WRITE_APPEND',
        time_partitioning=bigquery.TimePartitioning(field='run_started_at'),
        clustering_fields=['id', 'category'],
    )
    # Re-uploading the same immutable report reuses its job rather than appending twice.
    job_id = f'f1_evals_{run_id}'
    try:
        job = client.load_table_from_json(
            rows, f'{PROJECT}.f1_evals.results', job_config=config,
            job_id=job_id, location='US',
        )
    except Conflict:
        job = client.get_job(job_id, location='US')
    job.result()
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('report', type=Path)
    parser.add_argument('--run-id', required=True)
    parser.add_argument('--commit-sha', required=True)
    parser.add_argument('--run-url', default='')
    parser.add_argument('--expected-count', type=int, default=len(QUESTIONS))
    args = parser.parse_args()
    if not re.fullmatch(r'[A-Za-z0-9_-]{1,200}', args.run_id):
        parser.error('--run-id must contain 1–200 letters, digits, underscores or hyphens')
    if args.expected_count < 1:
        parser.error('--expected-count must be positive')
    try:
        rows = upload(bigquery.Client(project=PROJECT, location='US'), args.report,
                      args.run_id, args.commit_sha, args.run_url, args.expected_count)
    except Exception as error:
        # Auth exception strings can contain credential material.
        raise SystemExit(f'Eval upload failed ({type(error).__name__})') from None
    counts = Counter(row['status'] for row in rows)
    summary = (f'Evaluations: {counts["pass"]}/{args.expected_count} correct; '
               f'{len(rows)}/{args.expected_count} completed. {dict(counts)}\n'
               f'BigQuery: {PROJECT}.f1_evals.results; run ID: {args.run_id}\n')
    print(summary)
    if os.environ.get('GITHUB_STEP_SUMMARY'):
        with open(os.environ['GITHUB_STEP_SUMMARY'], 'a') as handle:
            handle.write(summary)
    return 0 if len(rows) == args.expected_count else 1


if __name__ == '__main__':
    raise SystemExit(main())

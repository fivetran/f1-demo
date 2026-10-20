"""Trigger the warehouse job at the CI commit and wait for dbt Cloud success."""

import os
import time
from urllib.parse import urlsplit

import requests


def request(session, method, url, **kwargs):
    response = session.request(method, url, timeout=30, allow_redirects=False, **kwargs)
    if not 200 <= response.status_code < 300:
        raise RuntimeError(f'dbt Cloud HTTP {response.status_code}')
    return response.json()['data']


def run_job(session, base, job_id, sha, timeout=3600):
    # Do not retry this POST: an uncertain response may already have started a run.
    run = request(session, 'POST', f'{base}/jobs/{job_id}/run/', json={
        'cause': f'GitHub Actions commit {sha}', 'git_sha': sha,
    })
    run_id = int(run['id'])
    print(f'dbt Cloud run ID: {run_id}', flush=True)
    if os.environ.get('GITHUB_STEP_SUMMARY'):
        with open(os.environ['GITHUB_STEP_SUMMARY'], 'a') as handle:
            handle.write(f'dbt Cloud run ID: {run_id}; commit: {sha}\n')
    run_url = f'{base}/runs/{run_id}/'
    deadline = time.monotonic() + timeout
    try:
        while time.monotonic() < deadline:
            run = request(session, 'GET', run_url)
            status = run['status']
            if status == 10:
                if run.get('git_sha') != sha:
                    raise RuntimeError('dbt Cloud built a different commit')
                print('dbt Cloud build succeeded', flush=True)
                return
            if status in (20, 30):
                raise RuntimeError(f'dbt Cloud run ended with status {status}')
            if status not in (1, 2, 3):
                raise RuntimeError(f'Unexpected dbt Cloud run status: {status}')
            time.sleep(20)
        raise TimeoutError('Timed out waiting for dbt Cloud')
    except BaseException:
        # Best effort; hard runner cancellation can bypass this cleanup.
        try:
            request(session, 'POST', f'{run_url}cancel/')
        except Exception:
            print(f'Could not confirm cancellation of dbt Cloud run {run_id}', flush=True)
        raise


def main():
    try:
        host = os.environ['DBT_CLOUD_HOST'].rstrip('/')
        parsed = urlsplit(host)
        if parsed.scheme != 'https' or not parsed.netloc or parsed.path or parsed.query or parsed.fragment or parsed.username:
            raise ValueError('DBT_CLOUD_HOST must be an HTTPS origin')
        account_id = int(os.environ['DBT_CLOUD_ACCOUNT_ID'])
        job_id = int(os.environ['DBT_CLOUD_JOB_ID'])
        token = os.environ['DBT_CLOUD_TOKEN']
        sha = os.environ['GITHUB_SHA']
        if not token or not sha:
            raise ValueError('Missing token or commit SHA')
        with requests.Session() as session:
            session.headers['Authorization'] = f'Token {token}'
            run_job(session, f'{host}/api/v2/accounts/{account_id}', job_id, sha)
    except Exception as error:
        # Never print request/auth objects or API response bodies.
        raise SystemExit(f'dbt Cloud build failed ({type(error).__name__}); inspect the dbt Cloud run.') from None


if __name__ == '__main__':
    main()

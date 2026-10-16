---
description: F1 cloud API contracts, credential handling, and endpoint-table validation
applyTo: "infra/**,scripts/**,connectors/**"
---

# Cloud deployment learnings

- Prefer vendor CLI and public APIs. Keep credentials outside the repository with owner-only permissions and print only allowlisted response fields. Credential validation errors can echo private keys. Never call `check_returncode()` or use `check=True` for a subprocess whose arguments contain secrets: its exception includes the full command. Check the exit code manually and raise a sanitized message. SDK updates require `--yes`; `--non-interactive` accepts the default No for an existing connection.
- For dbt BigQuery v1, account connections use `adapter_version: bigquery_v1`. Deployment credentials use `type: adapter` and `credential_details`, not the legacy BigQuery payload. Read the current adapter schema before changing credentials. Environment updates use POST, not PATCH. The current job is sources-only: `dbt parse`.
- Hosted SDK storage is temporary. Persist completion in checkpoint state, not only a local cache. Document signatures include manifest and parser versions. Do not swallow SDK write errors as extraction failures.
- Explicit SDK JSON columns accept JSON strings. Use JSON only for genuinely array-valued sector segments, never as a whole-row payload. Source scalar fields belong in individual typed columns.
- OpenF1 telemetry has samples before/after scheduled race times. Partition large endpoints by driver/session, not by scheduled race bounds. Source 404 is unavailable, not evidence of zero activity. Retry transient errors with pacing.
- Direct endpoint upserts are idempotent but cannot remove source-deleted rows by changing a generation alone. A clean replacement requires fresh state and clearing old destination tables. Checkpoints expose partial backfill progress; confirm full hosted sync success before claiming completeness.
- Use BigQuery table metadata and dataset-level queries. Region-level TABLE_STORAGE may require broader permissions. Verify observed schemas, declared-key uniqueness, source/destination counts, and document section counts. Do not confuse local debugger success with hosted destination verification.
- The user replaced the old generic snapshot/mart/vector design. Do not bring back embedding SQL, generic records/payload tables, or dbt models without a new request.

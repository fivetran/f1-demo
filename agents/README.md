# Analyst deployment and CI

[The workflow](../.github/workflows/analyst.yml) validates questions on pull requests.
Every push to `main` (or manual run on `main`) triggers a dbt Cloud job at the GitHub
commit and waits for success. dbt Cloud builds models and publishes the catalog;
GitHub then updates the analyst, runs all 100 evaluations,
and uploads results to BigQuery even if answers fail. Deployment stops if dbt fails;
evaluations stop if deployment fails. Live jobs are serialized without cancelling the
active job. There is no recurring schedule or connector deployment/sync in CI.
Do not run another warehouse build, agent refresh or catalog publication during CI evaluation.
GitHub concurrency does not serialize independently triggered dbt Cloud jobs.

## Configured resources

Provisioned on 2026-10-20: service account `f1-github-ci`, Workload Identity pool
`f1-github` with provider `github`, US dataset `f1_evals`, and GitHub environment
`production` restricted to `main`. All five workflow variables and the
`DBT_CLOUD_TOKEN` secret are installed in that environment. No service-account key
was created.

The production dbt Cloud job is `F1 production build` (1150541), in project 594426
and environment 491123. The dbt project subdirectory is empty (repository root).
Its repository connection now uses `fivetran/f1-demo` with
a read-only GitHub deploy key. Its sole command is `dbt build --threads 4`, with
independent triggers disabled and a 3,300-second execution timeout. The environment
uses `fusion-stable`. The original parse-only validation job remains available.

Verified end to end on 2026-10-20 in [GitHub run 39510070555, attempt 6](https://github.com/fivetran/f1-demo/actions/runs/39510070555/attempts/6):
dbt Cloud run 520694522 built the warehouse and published the catalog; GitHub deployed
the analyst with 30 tables; all 100 evaluations passed (67 structured, 33 unstructured).
BigQuery contains 100 distinct question results for `github_39510070555_6` at commit
`3283eb5d4023720627c2b077b4eb03e5b16592bf`. IAM changes needed propagation time before
the service-account credential exchange succeeded.

## One-time dbt Cloud setup

1. Connect `fivetran/f1-demo` and create a production deployment environment using the
   existing BigQuery project, dataset `f1`, and US location. Keep dbt State enabled and
   use a Fusion release compatible with this project's functions and hybrid indexes
   (local version: 2.0.8). GitHub no longer installs or runs dbt.
2. Configure dbt Cloud's warehouse identity to read `f1_openf1` and `f1_documents`,
   write `f1` and `agents`, create query jobs, and use the existing embedding connection.
   The dbt identity also has project-level `bigquery.connections.create` and
   `bigquery.datasets.create` for the existing-object setup hooks, plus
   `bigquery.tables.get` and `bigquery.tables.list` for catalog inspection, through
   the custom `f1ConnectionCreator` role. Keep Vertex AI access on the connection's
   service account. Configure these credentials
   in dbt Cloud, separately from GitHub's Google identity.
3. Create a deploy job with command `dbt build --threads 4`. The existing on-run-end
   hook publishes all four catalog tables. Leave schedules and independent Git triggers
   disabled for this job: GitHub triggers it through the API. Set a job execution timeout
   below one hour. The script also limits total polling, including queue time, to one hour.
4. Create a dbt API service token scoped to this project with permission to trigger,
   inspect and cancel runs (Job Admin; use Job Runner if available and sufficient).
   [Token permissions and availability](https://docs.getdbt.com/docs/dbt-apis/service-tokens)
   depend on your plan. If your plan does not support deployment API service tokens,
   use a permitted personal access token or arrange the required plan/access first.
5. Copy your account ID, job ID, and account's API host from dbt Cloud. Use the actual
   deployment host, such as `https://cloud.getdbt.com` or your account-specific URL;
   do not include `/api/v2` in the host variable.

[The API runner](run_dbt_cloud.py) sends `git_sha` and checks the completed run's SHA
before allowing deployment. It does not override the job's commands, so keep the job
configured as above. It prints the run ID in GitHub logs and the job summary. An uncertain
trigger response is not retried automatically because the run might already exist.
Timeout/polling failure requests cancellation; hard GitHub cancellation can bypass cleanup.
Check dbt Cloud for an active run before manually retrying after either case.

## One-time Google Cloud setup

Use the existing project from [configure_data_agent.py](configure_data_agent.py), US
location, and existing billing account. An administrator should:

1. Create a dedicated service account, for example `f1-github-ci`, in that project.
2. Enable IAM, IAM Service Account Credentials, Security Token Service, BigQuery,
   BigQuery Connection, Vertex AI and Gemini Data Analytics APIs if not already enabled.
3. Create the `f1_evals` BigQuery dataset in US. The uploader creates `results` on its
   first successful load. Do not change ingestion dataset retention.
4. Grant the service account the following access:

| Scope | Role |
| --- | --- |
| Project | `roles/bigquery.jobUser`, `roles/serviceusage.serviceUsageConsumer` |
| `f1`, `agents` datasets | `roles/bigquery.dataViewer` |
| `f1_evals` dataset | `roles/bigquery.dataEditor` |
| Existing `us.f1_document_embeddings` connection | `roles/bigquery.connectionUser` |
| Existing `f1-analyst` agent | `roles/geminidataanalytics.dataAgentEditor` |
| Project | `roles/geminidataanalytics.dataAgentStatelessUser` |

Keep `roles/aiplatform.user` on the existing embedding connection's service account.
The connection and analyst already exist; creating a fresh environment additionally
requires connection creation and `roles/geminidataanalytics.dataAgentCreator`.
GitHub does not need ingestion access or write access to `f1` or `agents`. If already
granted, remove those grants from the GitHub identity; keep them on the dbt Cloud identity.

5. Create a Workload Identity Pool and GitHub OIDC provider following
   [Google's deployment pipeline guide](https://docs.cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines).
   Use issuer `https://token.actions.githubusercontent.com` and map:

```text
google.subject=assertion.sub
attribute.repository_id=assertion.repository_id
attribute.repository_owner_id=assertion.repository_owner_id
```

Restrict the provider with this attribute condition, replacing both numeric IDs with
those of `fivetran/f1-demo` and its owner (available from `gh api repos/fivetran/f1-demo`):

```text
assertion.repository_owner_id == 'OWNER_ID' &&
assertion.repository_id == 'REPOSITORY_ID' &&
assertion.ref == 'refs/heads/main' &&
assertion.workflow_ref == 'fivetran/f1-demo/.github/workflows/analyst.yml@refs/heads/main'
```

6. Grant `roles/iam.workloadIdentityUser` on the CI service account to this principal
   (replace project number and pool ID):

```text
principal://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/subject/repo:fivetran@2722259/f1-demo@1416303040:environment:production
```

This repository uses GitHub immutable OIDC subjects. Confirm the subject prefix with
`gh api repos/fivetran/f1-demo/actions/oidc/customization/sub`; the repository and owner
IDs above are part of the subject, not just the provider condition.

This permits impersonation only from the production environment; the provider
condition also limits it to this repository, workflow, and `main`.

## GitHub configuration

Create a GitHub environment named **production** in repository Settings → Environments.
Restrict deployment branches to `main`. Under that environment's **Variables**, add:

| Variable | Value |
| --- | --- |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | `projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID` |
| `GCP_SERVICE_ACCOUNT` | `f1-github-ci@PROJECT_ID.iam.gserviceaccount.com` |
| `DBT_CLOUD_HOST` | Your dbt Cloud HTTPS origin |
| `DBT_CLOUD_ACCOUNT_ID` | Numeric account ID |
| `DBT_CLOUD_JOB_ID` | Numeric production deploy job ID |

Under production environment **Secrets**, add `DBT_CLOUD_TOKEN` with the dbt API token.
No Google service-account JSON key is needed: the
[Google authentication action](https://github.com/google-github-actions/auth) supplies
short-lived ADC credentials through OIDC. No Fivetran credentials are needed.
Allow GitHub Actions and the referenced checkout, setup-python, and Google auth actions
under the repository/organization Actions policy. Required environment reviewers are
optional; enabling them makes each deployment wait for approval.

After merging the workflow, select **Deploy analyst and evaluate → Run workflow → main**
to verify authentication, the dbt Cloud build, deployment, evaluation and the BigQuery load.
A wrong answer, invalid output, or request error currently fails CI; this preserves the
runner's existing 100% pass gate. Review the job summary and BigQuery rows to distinguish
answer failures from infrastructure failures. Deployment happens before evaluation;
a failed evaluation does not roll back the analyst.

Raw responses are not published as GitHub artifacts. They stay in the private warehouse
and ephemeral runner report. If a job is forcibly stopped before upload, that report can
be lost; this is a batch uploader, not durable per-question streaming.

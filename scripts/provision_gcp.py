"""Create a dedicated project only in the explicitly selected Fivetran org."""

import json
import os
import re
import subprocess

from local_config import load_config

load_config()


def run(*args, json_output=False):
    p = subprocess.run(
        list(args) + (["--format=json"] if json_output else []),
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(p.stdout) if json_output else p.stdout


project = os.environ["F1_GCP_PROJECT"]
org = os.environ["F1_GCP_ORG"]
billing = os.environ["F1_BILLING_ACCOUNT"]
location = os.getenv("F1_BQ_LOCATION", "US")
if not re.fullmatch(r"[a-z][a-z0-9-]{4,28}[a-z0-9]", project):
    raise ValueError("Invalid project ID")
organization = run("gcloud", "organizations", "describe", org, json_output=True)
if "fivetran" not in organization.get("displayName", "").lower():
    raise ValueError("Selected organization is not Fivetran")
projects = run("gcloud", "projects", "list", "--filter=projectId=" + project, json_output=True)
if not projects:
    run(
        "gcloud",
        "projects",
        "create",
        project,
        "--organization=" + org,
        "--name=F1 Demo 2023",
    )
else:
    actual = run("gcloud", "projects", "describe", project, json_output=True)
    if actual.get("parent") != {"id": org, "type": "organization"}:
        raise ValueError("Existing project has unexpected parent")
run("gcloud", "billing", "projects", "link", project, "--billing-account=" + billing)
run(
    "gcloud",
    "services",
    "enable",
    "bigquery.googleapis.com",
    "iam.googleapis.com",
    "--project=" + project,
)
for dataset in ["f1_openf1", "f1_documents", "f1"]:
    check = subprocess.run(
        ["bq", "show", "--format=prettyjson", project + ":" + dataset],
        capture_output=True,
        text=True,
    )
    if check.returncode:
        run("bq", "--location=" + location, "mk", "--dataset", project + ":" + dataset)
    else:
        if json.loads(check.stdout)["location"].lower() != location.lower():
            raise ValueError("Dataset location mismatch")
print(json.dumps(dict(project=project, organization=org, location=location), indent=2))

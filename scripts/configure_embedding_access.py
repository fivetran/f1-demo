"""One-time IAM setup for the dbt-created F1 BigQuery embedding connection."""

import os

import google.auth
from google.auth.transport.requests import AuthorizedSession
from local_config import load_config

load_config()

PROJECT = os.environ["F1_GCP_PROJECT"]
CONNECTION = f"projects/{PROJECT}/locations/us/connections/f1_document_embeddings"


def add_member(session, resource, role, member):
    response = session.post(
        resource + ":getIamPolicy", json={"options": {"requestedPolicyVersion": 3}}
    )
    response.raise_for_status()
    policy = response.json()
    for binding in policy.setdefault("bindings", []):
        if binding["role"] == role and "condition" not in binding:
            if member in binding["members"]:
                print(f"Already configured: {role} for {member}")
                return
            binding["members"].append(member)
            break
    else:
        policy["bindings"].append({"role": role, "members": [member]})
    response = session.post(resource + ":setIamPolicy", json={"policy": policy})
    response.raise_for_status()
    print(f"Configured: {role} for {member}")


def main():
    credentials, _ = google.auth.default(scopes=["https://www.googleapis.com/auth/cloud-platform"])
    session = AuthorizedSession(credentials)
    resource = "https://bigqueryconnection.googleapis.com/v1/" + CONNECTION
    response = session.get(resource)
    response.raise_for_status()
    service_account = response.json()["cloudResource"]["serviceAccountId"]
    assert service_account.endswith("@gcp-sa-bigquery-condel.iam.gserviceaccount.com")
    add_member(
        session,
        f"https://cloudresourcemanager.googleapis.com/v1/projects/{PROJECT}",
        "roles/aiplatform.user",
        "serviceAccount:" + service_account,
    )
    add_member(
        session,
        resource,
        "roles/bigquery.connectionUser",
        "serviceAccount:" + os.environ["F1_DBT_SERVICE_ACCOUNT"],
    )


if __name__ == "__main__":
    main()

"""Grant the existing dbt service account access to only the two metadata datasets."""

import os

from google.cloud import bigquery
from local_config import load_config

load_config()

PROJECT = os.environ["F1_GCP_PROJECT"]
ACCOUNT = os.environ["F1_DBT_SERVICE_ACCOUNT"]


def main():
    client = bigquery.Client(project=PROJECT, location="US")
    for name in ["AGENTS", "f1_agents_seed"]:
        dataset = client.get_dataset(f"{PROJECT}.{name}")
        assert dataset.location == "US"
        entries = list(dataset.access_entries)
        authorized = any(e.entity_type == "userByEmail" and e.entity_id == ACCOUNT
                         and e.role in {"WRITER", "OWNER", "roles/bigquery.dataEditor", "roles/bigquery.dataOwner"}
                         for e in entries)
        if not authorized:
            entries.append(bigquery.AccessEntry("WRITER", "userByEmail", ACCOUNT))
            dataset.access_entries = entries
            # update_dataset sends If-Match with this dataset's etag.
            client.update_dataset(dataset, ["access_entries"])
        print(f"Verified dbt metadata write access: {PROJECT}.{name}")


if __name__ == "__main__":
    main()

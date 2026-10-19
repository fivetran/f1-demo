"""On-demand orchestration: successful Fivetran syncs -> dbt.
Local Fusion builds the models and publishes the AGENTS catalog.
Configure this entrypoint in the desired scheduler only when scheduling is requested.
"""

import argparse
import os
import subprocess
import time
from pathlib import Path

import requests
from local_config import load_config

load_config()

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument(
    "--wait-existing",
    action="store_true",
    help="Wait for already-started initial syncs instead of forcing another sync",
)
args = parser.parse_args()
s = requests.Session()
s.auth = (os.environ["FIVETRAN_API_KEY"], os.environ["FIVETRAN_API_SECRET"])
s.headers["Content-Type"] = "application/json"


def api(method, path, **kwargs):
    r = s.request(method, "https://api.fivetran.com/v1/" + path, timeout=60, **kwargs)
    r.raise_for_status()
    return r.json().get("data", {})


def sync(connection):
    initial = api("GET", "connections/" + connection)
    baseline = initial.get("succeeded_at")
    failed_before = initial.get("failed_at")
    already_finished = initial.get("status", {}).get("sync_state") != "syncing"
    if (
        args.wait_existing
        and already_finished
        and failed_before
        and (not baseline or failed_before > baseline)
    ):
        raise RuntimeError("Existing Fivetran sync failed: " + connection)
    if not args.wait_existing:
        api("POST", f"connections/{connection}/force", json={})
    deadline = time.monotonic() + 7200
    while time.monotonic() < deadline:
        status = api("GET", "connections/" + connection)
        if status.get("succeeded_at") and (
            (args.wait_existing and already_finished) or status["succeeded_at"] != baseline
        ):
            print("Fivetran sync succeeded:", connection, status["succeeded_at"], flush=True)
            return
        if status.get("failed_at") and status["failed_at"] != failed_before:
            raise RuntimeError("Fivetran sync failed: " + connection)
        time.sleep(30)
    raise TimeoutError("Fivetran sync timeout: " + connection)


for name in ["F1_OPENF1_CONNECTION_ID", "F1_DOCUMENTS_CONNECTION_ID"]:
    sync(os.environ[name])
subprocess.run(
    [
        "dbt",
        "build",
        "--project-dir",
        str(ROOT / "dbt"),
        "--profiles-dir",
        str(ROOT / "dbt"),
        "--threads",
        "4",
        "--no-manage-state",
    ],
    cwd=ROOT / "dbt",
    check=True,
)

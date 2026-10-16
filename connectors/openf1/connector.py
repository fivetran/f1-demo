"""One typed destination table per OpenF1 endpoint; resumable historical backfill."""

import hashlib
import json
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path

import requests
from fivetran_connector_sdk import Connector
from fivetran_connector_sdk import Logging as log
from fivetran_connector_sdk import Operations as op

TABLES = json.loads(Path(__file__).with_name("tables.json").read_text())
DEFINITIONS = {t["table"]: t for t in TABLES}
ENDPOINTS = tuple(t for t in DEFINITIONS if t not in ("meetings", "sessions"))
TELEMETRY = {"car_data", "location"}


class Client:
    def __init__(self, delay=2.1):
        self.delay = max(2.1, float(delay))
        self.last = 0
        self.http = requests.Session()

    def get(self, endpoint, **params):
        for attempt in range(8):
            time.sleep(max(0, self.delay - (time.monotonic() - self.last)))
            self.last = time.monotonic()
            try:
                r = self.http.get(
                    "https://api.openf1.org/v1/" + endpoint, params=params, timeout=180
                )
                if r.status_code == 429 or r.status_code >= 500:
                    time.sleep(max(float(r.headers.get("Retry-After", 0)), min(120, 2**attempt)))
                    continue
                r.raise_for_status()
                rows = r.json()
                if not isinstance(rows, list):
                    raise ValueError(f"Expected list for {endpoint}")
                return rows
            except (requests.Timeout, requests.ConnectionError):
                if attempt == 7:
                    raise
                time.sleep(min(120, 2**attempt))
        raise RuntimeError(f"API retries exhausted: {endpoint} {params}")


def schema(configuration):
    return TABLES + [
        dict(
            table="sync_status",
            primary_key=["endpoint", "scope"],
            columns={
                "endpoint": "STRING",
                "scope": "STRING",
                "session_key": "LONG",
                "driver_number": "LONG",
                "status": "STRING",
                "row_count": "LONG",
                "completed_at": "UTC_DATETIME",
            },
        )
    ]


def typed_row(endpoint, row):
    definition = DEFINITIONS[endpoint]
    unknown = row.keys() - definition["columns"].keys()
    if unknown:
        raise ValueError(f"Undeclared source fields in {endpoint}: {sorted(unknown)}")
    result = dict(row)
    if endpoint == "race_control":
        result["message_id"] = hashlib.sha256(
            json.dumps(row, sort_keys=True, separators=(",", ":")).encode()
        ).hexdigest()
    for name, kind in definition["columns"].items():
        value = result.get(name)
        if value is not None:
            if kind == "STRING" and not isinstance(value, str):
                value = str(value)
            elif kind == "JSON":
                value = json.dumps(value, separators=(",", ":"))
            elif kind == "LONG" and not isinstance(value, int):
                if not isinstance(value, (float, int)) or int(value) != value:
                    raise ValueError(f"Non-integral {endpoint}.{name}: {value}")
                value = int(value)
        result[name] = value
    if any(result.get(k) is None for k in definition["primary_key"]):
        raise ValueError(f"Missing primary key in {endpoint}")
    return result


def ingest(client, endpoint, scope, params, state, generation, rows=None, refresh=False):
    token = f"{endpoint}:{scope}"
    if not refresh and state["completed"].get(token) == generation:
        return
    try:
        rows = client.get(endpoint, **params) if rows is None else rows
        status = "available" if rows else "empty"
    except requests.HTTPError as exc:
        if exc.response.status_code != 404:
            raise
        rows, status = [], "unavailable_404"
    seen = {}
    for raw in rows:
        row = typed_row(endpoint, raw)
        key = tuple(row[k] for k in DEFINITIONS[endpoint]["primary_key"])
        if key in seen:
            if seen[key] != row:
                raise ValueError(f"Conflicting primary key in {endpoint}: {key}")
            continue
        seen[key] = row
        op.upsert(table=endpoint, data=row)
    op.upsert(
        table="sync_status",
        data=dict(
            endpoint=endpoint,
            scope=str(scope),
            session_key=params.get("session_key"),
            driver_number=params.get("driver_number"),
            status=status,
            row_count=len(seen),
            completed_at=datetime.now(timezone.utc),
        ),
    )
    state["completed"][token] = generation
    op.checkpoint(state)
    log.info(f"{endpoint} {scope}: {status}, {len(seen)} rows")


def update(configuration, state):
    if state.get("schema_version") not in (None, 2):
        raise ValueError("New table layout requires a fresh connection/state")
    state["schema_version"] = 2
    state.setdefault("completed", {})
    client = Client(configuration.get("request_interval_seconds", 2.1))
    years = sorted({int(y) for y in str(configuration.get("years", configuration.get("year", 2025))).split(",")})
    selection = configuration.get("meeting_keys", "all")
    selected = None if selection == "all" else {int(k) for k in selection.split(",")}
    generation = str(configuration.get("refresh_generation", "initial"))
    endpoints = configuration.get("endpoints", ",".join(ENDPOINTS)).split(",")
    if set(endpoints) - set(ENDPOINTS):
        raise ValueError("Unknown endpoint configuration")
    sessions = []
    for year in years:
        meetings = client.get("meetings", year=year)
        year_sessions = client.get("sessions", year=year)
        # Calendar metadata changes during an ongoing season. Detail checkpoints
        # remain intact, so adding a year does not refetch previous seasons.
        ingest(client, "meetings", year, {}, state, generation, meetings, refresh=True)
        ingest(client, "sessions", year, {}, state, generation, year_sessions, refresh=True)
        sessions.extend(year_sessions)
    # OpenF1 treats sessions as live until 30 minutes after their scheduled end.
    cutoff = datetime.now(timezone.utc) - timedelta(minutes=30)
    races = sorted(
        (
            s
            for s in sessions
            if s["session_name"] == "Race"
            and not s.get("is_cancelled")
            and s.get("date_end")
            and datetime.fromisoformat(s["date_end"].replace("Z", "+00:00")) <= cutoff
            and (selected is None or s["meeting_key"] in selected)
        ),
        key=lambda s: s["date_start"],
    )
    # OpenF1 keys starting_grid by the qualifying session that produced it,
    # not by the subsequent Race session. Preserve that source session_key.
    grid_sessions = (
        {race["session_key"]: starting_grid_session(sessions, race) for race in races}
        if "starting_grid" in endpoints
        else {}
    )
    # Finish ordinary endpoints first so useful race data is delivered before telemetry.
    for high_volume in (False, True):
        for session in races:
            key = session["session_key"]
            for endpoint in endpoints:
                if (endpoint in TELEMETRY) != high_volume:
                    continue
                if high_volume:
                    # Partition by driver, preserving ALL samples belonging to the session,
                    # including the source's pre/post-race samples outside scheduled times.
                    drivers = state.setdefault("session_drivers", {}).get(str(key))
                    if drivers is None:
                        drivers = sorted(
                            {r["driver_number"] for r in client.get("drivers", session_key=key)}
                        )
                        state["session_drivers"][str(key)] = drivers
                        op.checkpoint(state)
                    for driver in drivers:
                        ingest(
                            client,
                            endpoint,
                            f"{key}:{driver}",
                            {"session_key": key, "driver_number": driver},
                            state,
                            generation,
                        )
                else:
                    source_key = (
                        grid_sessions[key]["session_key"] if endpoint == "starting_grid" else key
                    )
                    ingest(
                        client, endpoint, source_key, {"session_key": source_key}, state, generation
                    )


def starting_grid_session(sessions, race):
    candidates = [
        session
        for session in sessions
        if session["meeting_key"] == race["meeting_key"]
        and session["session_name"] == "Qualifying"
        and not session.get("is_cancelled")
    ]
    if len(candidates) != 1:
        raise ValueError(f"Expected one qualifying session for meeting {race['meeting_key']}")
    return candidates[0]


connector = Connector(update=update, schema=schema)
if __name__ == "__main__":
    connector.debug()

"""Reparse cached discoveries, match actual publication dates, and produce race coverage."""

import argparse
import json
import sys
from datetime import datetime, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "connectors/documents"))
from connector import Fetcher, extract  # noqa: E402

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("meetings", help="OpenF1 season meetings JSON")
parser.add_argument("sessions", help="OpenF1 season sessions JSON")
args = parser.parse_args()
meetings = json.loads(Path(args.meetings).read_text())
sessions = json.loads(Path(args.sessions).read_text())
sprint_meetings = {
    session["meeting_key"]
    for session in sessions
    if session["session_name"] == "Sprint" and not session.get("is_cancelled")
}
f = Fetcher(str(ROOT / ".cache/sources"))
results = json.loads((ROOT / "inventory/transcripts.json").read_text())
manifest = []
for item in results:
    if item["status"] != "parsed":
        continue
    raw, _ = f.fetch(item["url"])
    title, date, blocks = extract(raw, {"document_type": "transcript"})
    kind = next(
        (
            k
            for k in [
                "post-race",
                "post-qualifying",
                "post-sprint",
                "thursday",
                "friday",
                "wednesday",
            ]
            if k in title.lower()
        ),
        "unresolved",
    )
    if item["url"].endswith("f1-2023-sao-paulo-grand-prix-post-press-conference-transcript"):
        kind = "post-qualifying"
        item["classification_evidence"] = (
            "Opening question explicitly congratulates Verstappen on pole and discusses Q3; subsequent question looks ahead to Sunday Grand Prix."
        )
    item.update(title=title, published_at=date, conference_type=kind, blocks=len(blocks))
    candidates = []
    if date:
        pub = datetime.fromisoformat(date)
        for race in meetings:
            start = datetime.fromisoformat(race["date_start"])
            end = datetime.fromisoformat(race["date_end"])
            if start - timedelta(days=3) <= pub <= end + timedelta(days=2):
                candidates.append(race)
    if len(candidates) == 1:
        race = candidates[0]
        item.update(
            meeting_key=race["meeting_key"],
            race_name=race["meeting_name"],
            association_method="unique weekend publication window; content title retained for audit",
        )
    manifest.append(
        dict(
            url=item["url"],
            document_type="transcript",
            **{
                k: item[k]
                for k in [
                    "title",
                    "published_at",
                    "conference_type",
                    "meeting_key",
                    "race_name",
                    "association_method",
                ]
                if k in item
            },
        )
    )
(ROOT / "inventory/transcripts.json").write_text(json.dumps(results, indent=2))
(ROOT / "connectors/documents/manifest.json").write_text(json.dumps(manifest, indent=2))
coverage = []
for race in meetings:
    if "Grand Prix" not in race["meeting_name"]:
        continue
    docs = [x for x in results if x.get("meeting_key") == race["meeting_key"]]
    expected = (
        ["wednesday", "thursday", "post-qualifying", "post-race"]
        if race["location"] == "Las Vegas"
        else ["thursday", "friday", "post-qualifying", "post-race"]
    )
    if race.get("is_cancelled"):
        expected = []
    if race["meeting_key"] in sprint_meetings:
        expected.append("post-sprint")
    coverage.append(
        dict(
            meeting_key=race["meeting_key"],
            race=race["meeting_name"],
            cancelled=race.get("is_cancelled", False),
            documents=len(docs),
            conference_types=sorted(set(d["conference_type"] for d in docs)),
            gaps=[
                dict(
                    conference_type=k,
                    status="not_discovered",
                    note="Not evidence of non-existence; inspect alternate official sources",
                )
                for k in expected
                if not any(d["conference_type"] == k for d in docs)
            ],
        )
    )
(ROOT / "inventory/season_coverage.json").write_text(json.dumps(coverage, indent=2))
print(
    "Parsed",
    len(manifest),
    "documents; gaps:",
    [(r["race"], r["gaps"]) for r in coverage if r["gaps"]],
)

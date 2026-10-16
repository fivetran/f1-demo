"""Inspect every discovered transcript's content; URLs only nominate candidates."""

import argparse
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "connectors" / "documents"))
from connector import Fetcher, extract

ROOT = Path(__file__).resolve().parents[1]
f = Fetcher(str(ROOT / ".cache" / "sources"))
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--year", type=int, default=2025)
parser.add_argument(
    "--additional-urls", help="JSON list of official URLs without season in their path"
)
parser.add_argument("sitemaps", nargs="+")
args = parser.parse_args()
urls = []
for path in args.sitemaps:
    urls += [n.text for n in ET.parse(path).findall(".//{*}loc")]
urls = sorted(
    set(
        u
        for u in urls
        if "/news/" in u
        and str(args.year) in u
        and ("transcript" in u or "conference" in u)
        and "/f1-" in u
        and "schedule" not in u
    ),
    key=lambda u: ("singapore" not in u, u),
)
if args.additional_urls:
    urls = list(dict.fromkeys(urls + json.loads(Path(args.additional_urls).read_text())))
manifest = []
results = []
for url in urls:
    item = dict(url=url, document_type="transcript")
    try:
        raw, _ = f.fetch(url)
        title, date, blocks = extract(raw, item)
        if not date or not date.startswith(str(args.year)):
            raise ValueError(f"Publication date does not match {args.year}: {date}")
        content = title + "\n" + "\n".join(b["text"] for b in blocks[:10])
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
                if k in content.lower()
            ),
            "unresolved",
        )
        item.update(title=title, published_at=date, conference_type=kind)
        results.append(
            dict(
                url=url,
                status="parsed",
                title=title,
                published_at=date,
                conference_type=kind,
                blocks=len(blocks),
            )
        )
        manifest.append(item)
    except Exception as e:
        results.append(dict(url=url, status="discovery_fetch_or_parse_failed", detail=str(e)))
    (ROOT / "inventory" / "transcripts.json").write_text(json.dumps(results, indent=2))
    (ROOT / "connectors" / "documents" / "manifest.json").write_text(json.dumps(manifest, indent=2))
    print(len(results), len(urls), results[-1]["status"], url, flush=True)

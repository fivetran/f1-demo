"""Build reference manifest from previously downloaded official landing pages."""

import json
import re
import sys
from datetime import datetime
from pathlib import Path
from urllib.parse import urljoin

from bs4 import BeautifulSoup

ROOT = Path(__file__).resolve().parents[1]
year = int(sys.argv[3]) if len(sys.argv) > 3 else 2025
s = BeautifulSoup(Path(sys.argv[1]).read_text(), "html.parser")
items = {}
for a in s.select("a[href]"):
    title = a.get_text(" ", strip=True)
    url = urljoin("https://www.fia.com", a["href"])
    if ".pdf" not in url or not re.search(
        rf"(?:FIA {year} Formula 1|Formula 1 - Technical Regulations - {year})", title
    ):
        continue
    match = re.search(r"Published on\s+(\d{2}\.\d{2}\.\d{2,4})", title)
    published_at = None
    if match:
        value = match.group(1)
        published_at = (
            datetime.strptime(value, "%d.%m.%Y" if len(value) == 10 else "%d.%m.%y")
            .date()
            .isoformat()
        )
    items[url] = dict(
        url=url,
        title=title.split(" Published on")[0],
        document_type="regulation",
        published_at=published_at,
        applicable_season=year,
        rule_family="sporting" if "Sporting" in title else "technical",
        applicability_status=f"{year} edition; article-specific effective dates require review",
        effective_from=None,
        effective_to=None,
    )
s = BeautifulSoup(Path(sys.argv[2]).read_text(), "html.parser")
for a in s.select("main a[href]"):
    if "f1-glossary-" not in a["href"]:
        continue
    url = urljoin("https://www.formula1.com", a["href"])
    items[url] = dict(
        url=url,
        document_type="glossary",
        title="Formula 1 glossary",
        applicability_status=f"current glossary; not a historical {year} edition",
    )
(ROOT / "connectors/documents/manifest.references.json").write_text(
    json.dumps(list(items.values()), indent=2)
)
print("References:", len(items))

"""Readable current transcripts, regulations and glossary pages with typed metadata."""

import hashlib
import io
import json
import re
import time
import unicodedata
from datetime import datetime, timedelta, timezone
from pathlib import Path
from urllib.parse import urlparse
from urllib.robotparser import RobotFileParser
from xml.etree import ElementTree

import requests
from bs4 import BeautifulSoup
from fivetran_connector_sdk import Connector
from fivetran_connector_sdk import Operations as op
from pypdf import PdfReader

PARSER_VERSION = "6"
REGULATION_PARSER_VERSION = "7"


def sha(s):
    return hashlib.sha256(s.encode() if isinstance(s, str) else s).hexdigest()


def normalized(s):
    return " ".join(unicodedata.normalize("NFKC", s).split())


class Fetcher:
    def __init__(self, cache_dir=".cache", refresh=False):
        self.cache = Path(cache_dir)
        self.cache.mkdir(parents=True, exist_ok=True)
        self.last = {}
        self.rules = {}
        self.refresh = refresh
        self.http = requests.Session()
        self.http.headers["User-Agent"] = "F1ResearchDemo/1.0"

    def request(self, url, headers=None):
        host = urlparse(url).netloc
        for attempt in range(6):
            delay = 10 if host.endswith("fia.com") else 2.1
            if host in self.rules:
                delay = max(delay, self.rules[host].crawl_delay("*") or 0)
            time.sleep(max(0, delay - (time.monotonic() - self.last.get(host, 0))))
            self.last[host] = time.monotonic()
            try:
                r = self.http.get(url, headers=headers or {}, timeout=120)
            except (requests.ConnectionError, requests.Timeout):
                if attempt == 5:
                    raise
                time.sleep(2**attempt)
                continue
            if r.status_code == 429 or r.status_code >= 500:
                time.sleep(max(2**attempt, float(r.headers.get("Retry-After", 0))))
                continue
            r.raise_for_status()
            return r
        raise RuntimeError("Retries exhausted: " + url)

    def fetch(self, url, revalidate=False):
        refresh = self.refresh or revalidate
        key = self.cache / sha(url)
        meta_path = key.with_suffix(".json")
        if key.exists() and meta_path.exists() and not refresh:
            return key.read_bytes(), json.loads(meta_path.read_text())
        host = urlparse(url).netloc
        if host not in self.rules:
            rp = RobotFileParser()
            robot = self.request(f"{urlparse(url).scheme}://{host}/robots.txt")
            rp.parse(robot.text.splitlines())
            self.rules[host] = rp
        if not self.rules[host].can_fetch("F1ResearchDemo", url):
            raise PermissionError("robots.txt disallows " + url)
        key = self.cache / sha(url)
        meta_path = key.with_suffix(".json")
        meta = json.loads(meta_path.read_text()) if meta_path.exists() else {}
        if key.exists() and not refresh:
            return key.read_bytes(), meta
        headers = {}
        if meta.get("etag"):
            headers["If-None-Match"] = meta["etag"]
        if meta.get("last_modified"):
            headers["If-Modified-Since"] = meta["last_modified"]
        r = self.request(url, headers)
        if r.status_code == 304 and key.exists():
            return key.read_bytes(), meta
        meta = dict(
            etag=r.headers.get("ETag"),
            last_modified=r.headers.get("Last-Modified"),
            content_type=r.headers.get("Content-Type"),
            final_url=r.url,
        )
        key.write_bytes(r.content)
        meta_path.write_text(json.dumps(meta))
        return r.content, meta


def sitemap_pages(fetcher, url="https://www.fia.com/sitemap.xml", seen=None):
    """Read every sitemap page afresh (conditional HTTP requests reuse cached XML)."""
    seen = set() if seen is None else seen
    if url in seen:
        return {}
    seen.add(url)
    raw, _ = fetcher.fetch(url, revalidate=True)
    root = ElementTree.fromstring(raw)
    ns = "{http://www.sitemaps.org/schemas/sitemap/0.9}"
    pages = {}
    if root.tag not in (ns + "sitemapindex", ns + "urlset"):
        raise ValueError("Unrecognized sitemap: " + url)
    for entry in root:
        location = entry.findtext(ns + "loc")
        if not location:
            raise ValueError("Missing sitemap location: " + url)
        if root.tag == ns + "sitemapindex":
            pages.update(sitemap_pages(fetcher, location, seen))
        else:
            pages[location] = entry.findtext(ns + "lastmod")
    return pages


def discover_transcripts(fetcher, years, state):
    pages = sitemap_pages(fetcher)
    metadata = state.setdefault("transcript_pages", {})
    meetings, races = {}, []
    for year in sorted(years):
        # OpenF1 is an API; use the same paced/retrying HTTP client as documents.
        for meeting in fetcher.request(f"https://api.openf1.org/v1/meetings?year={year}").json():
            meetings[meeting["meeting_key"]] = meeting
        races.extend(fetcher.request(
            f"https://api.openf1.org/v1/sessions?year={year}&session_name=Race"
        ).json())
    pattern = re.compile(
        r"^https://www\.fia\.com/news/(?:f1-)?(?:(\d{4})-)?"
        r".+-grand-prix-(.+)-press-conference-transcript$"
    )
    items = []
    for url, lastmod in sorted(pages.items()):
        match = pattern.match(url)
        if not match or (match[1] and int(match[1]) not in years):
            continue
        previous = metadata.get(url)
        if previous is None or previous["lastmod"] != lastmod or fetcher.refresh:
            raw, _ = fetcher.fetch(url, revalidate=True)
            soup = BeautifulSoup(raw, "html.parser")
            date = soup.select_one('meta[property="article:published_time"]')
            title = soup.select_one('meta[property="og:title"]')
            if not date or not date.get("content"):
                raise ValueError("Missing transcript publication date: " + url)
            previous = dict(lastmod=lastmod, published_at=date["content"],
                            title=title["content"] if title else soup.title.get_text())
            metadata[url] = previous
        published = datetime.fromisoformat(previous["published_at"].replace("Z", "+00:00"))
        if published.year not in years:
            continue
        # Include media days before the race, with one day after for late publication.
        matches = [race for race in races if race.get("date_end") and
                   not race.get("is_cancelled") and
                   datetime.fromisoformat(race["date_start"].replace("Z", "+00:00")).date()
                   - timedelta(days=4) <= published.date() <=
                   datetime.fromisoformat(race["date_end"].replace("Z", "+00:00")).date()
                   + timedelta(days=1)]
        if len(matches) != 1:
            raise ValueError("Expected one race weekend for transcript: " + url)
        meeting = meetings[matches[0]["meeting_key"]]
        items.append(dict(
            url=url, document_type="transcript", title=previous["title"],
            published_at=previous["published_at"], conference_type=match[2],
            meeting_key=meeting["meeting_key"], race_name=meeting["meeting_name"],
            association_method="unique weekend publication window; content title retained for audit",
            sitemap_lastmod=lastmod,
        ))
    return items


def regulation_sections(reader):
    """Keep numbered clauses through level three intact, including across pages."""
    heading = re.compile(
        r"^\s*(?:ARTICLE\s+\d+\s*:|APPENDIX\s+\d+\b|"
        r"\d{1,2}\.\d{1,3}\.\d{1,3}\s+[0-9\"“‘]|"
        r"\d{1,2}(?:\.\d{1,3}){0,2}[.)]?\s+[A-Z])"
    )
    blocks = []
    lines = []
    section = None
    start_page = None

    def flush():
        if lines and "".join(lines).strip():
            blocks.append(dict(text="".join(lines).strip(), page_number=start_page,
                               section=section, speaker=None, question=None))
        lines.clear()

    for page_number, page in enumerate(reader.pages, 1):
        text = page.extract_text() or ""
        if not text.strip():
            raise ValueError(f"Empty PDF page {page_number}; OCR/manual review required")
        for line in text.splitlines(keepends=True):
            # Running page furniture is not part of a rule. Keep other text,
            # including front matter, contents, tables and appendix prose.
            if re.match(r"^\s*\d{4} Formula 1 (?:Technical|Sporting) Regulations\b", line):
                continue
            if re.match(r"^\s*©\s*\d{4} F[ée]d[ée]ration Internationale de l.Automobile\b", line):
                continue
            if heading.match(line):
                flush()
                section = line.strip()[:160]
                start_page = page_number
            if start_page is None and line.strip():
                start_page = page_number
            lines.append(line)
        # PDF pages need an explicit separator when their final line has none.
        if lines and not lines[-1].endswith(("\n", "\r")):
            lines.append("\n")
    flush()
    return blocks


def extract(raw, item):
    if raw.startswith(b"%PDF"):
        reader = PdfReader(io.BytesIO(raw))
        if item.get("document_type") == "regulation":
            return item["title"], item.get("published_at"), regulation_sections(reader)
        blocks = []
        for n, p in enumerate(reader.pages, 1):
            text = p.extract_text() or ""
            if not text.strip():
                raise ValueError(f"Empty PDF page {n}; OCR/manual review required")
            for part in re.split(r"(?m)(?=^\s*(?:ARTICLE\s+)?\d+\.\d*\s+[A-Z])", text):
                if part.strip():
                    blocks.append(
                        dict(
                            text=part.strip(),
                            page_number=n,
                            section=part.strip().splitlines()[0][:160],
                            speaker=None,
                            question=None,
                        )
                    )
        return item["title"], item.get("published_at"), blocks
    soup = BeautifulSoup(raw, "html.parser")
    tag = soup.select_one('meta[property="og:title"]')
    title = (
        tag.get("content")
        if tag
        else (soup.title.get_text() if soup.title else item.get("title", ""))
    )
    tag = soup.select_one('meta[property="article:published_time"]')
    published = tag.get("content") if tag else item.get("published_at")
    body = soup.select_one(".content-body") or soup.select_one("article") or soup.select_one("main")
    if body is None:
        raise ValueError("No recognized article body")
    for el in body.select("script,style,nav,footer,button"):
        el.decompose()
    for br in body.select("br"):
        br.replace_with("\n")
    paragraphs = [
        normalized(line)
        for el in body.select("p,h2,h3,h4,li")
        for line in el.get_text(" ", strip=False).splitlines()
    ]
    if not paragraphs:
        paragraphs = [normalized(t) for t in body.get_text("\n", strip=True).splitlines()]
    blocks = []
    question = None
    speaker = None
    section = None
    aliases = {}
    for text in paragraphs:
        if not text:
            continue
        if re.match(r"^Q\s*[:.]", text):
            question = text
            speaker = None
            blocks.append(
                dict(
                    text=text,
                    question=None,
                    speaker="INTERVIEWER",
                    section=section,
                    page_number=None,
                )
            )
            continue
        match = re.match(r"^([A-ZÀ-Ž][A-Za-zÀ-ž .’\-]{1,55}):\s*(.*)", text)
        if match:
            label, answer = match.groups()
            if " " in label:
                aliases["".join(w[0] for w in label.split())] = label
            speaker = aliases.get(label, label)
            if answer:
                blocks.append(
                    dict(
                        text=answer,
                        question=question,
                        speaker=speaker,
                        section=section,
                        page_number=None,
                    )
                )
        elif text.isupper() and len(text) < 100:
            section = text
            speaker = None
            question = None
            blocks.append(
                dict(
                    text=text,
                    question=None,
                    speaker=None,
                    section=section,
                    page_number=None,
                )
            )
        else:
            blocks.append(
                dict(
                    text=text,
                    question=question,
                    speaker=speaker,
                    section=section,
                    page_number=None,
                )
            )
    if sum(len(b["text"]) for b in blocks) < 200:
        raise ValueError("Insufficient extracted text")
    return title, published, blocks


KINDS = {
    "transcript": ("transcripts", "transcript_passages"),
    "regulation": ("regulations", "regulation_sections"),
    "glossary": ("glossary", "glossary_sections"),
}
COMMON_COLUMNS = {
    "document_id": "STRING",
    "source_url": "STRING",
    "title": "STRING",
    "published_at": "STRING",
    "content_hash": "STRING",
    "source_hash": "STRING",
    "parser_version": "STRING",
    "full_text": "STRING",
    "section_count": "LONG",
}
KIND_COLUMNS = {
    "transcript": {
        "meeting_key": "LONG",
        "race_name": "STRING",
        "conference_type": "STRING",
        "association_method": "STRING",
    },
    "regulation": {
        "applicable_season": "LONG",
        "rule_family": "STRING",
        "applicability_status": "STRING",
        "effective_from": "STRING",
        "effective_to": "STRING",
    },
    "glossary": {"applicability_status": "STRING"},
}
SECTION_COLUMNS = {
    "document_id": "STRING",
    "position": "LONG",
    "text": "STRING",
    "question": "STRING",
    "speaker": "STRING",
    "section": "STRING",
    "page_number": "LONG",
}


def schema(configuration):
    tables = []
    for kind, (parent, child) in KINDS.items():
        tables.append(
            dict(
                table=parent,
                primary_key=["document_id"],
                columns=dict(COMMON_COLUMNS, **KIND_COLUMNS[kind]),
            )
        )
        tables.append(
            dict(table=child, primary_key=["document_id", "position"], columns=SECTION_COLUMNS)
        )
    tables.append(
        dict(
            table="fetch_status",
            primary_key=["source_url"],
            columns={
                "source_url": "STRING",
                "status": "STRING",
                "detail": "STRING",
                "checked_at": "UTC_DATETIME",
            },
        )
    )
    return tables


def delete_document(docid, previous):
    if not previous:
        return
    parent, child = KINDS[previous["kind"]]
    for n in range(previous["section_count"]):
        op.delete(table=child, keys={"document_id": docid, "position": n})
    op.delete(table=parent, keys={"document_id": docid})


def update(configuration, state):
    base = Path(__file__).resolve().parent
    manifest = json.loads((base / configuration.get("manifest_path", "manifest.full.json")).read_text())
    fetcher = Fetcher(
        str(base / configuration.get("cache_dir", ".cache")),
        configuration.get("refresh", "false").lower() == "true",
    )
    if state.get("schema_version") not in (None, 2):
        raise ValueError("New table layout requires a fresh connection/state")
    state["schema_version"] = 2
    completed = state.setdefault("documents", {})
    discovery = bool(configuration.get("transcript_years"))
    if discovery:
        years = {int(year.strip()) for year in configuration["transcript_years"].split(",")}
        manifest += discover_transcripts(fetcher, years, state)
    failures = []
    urls = {item["url"] for item in manifest}
    if len(urls) != len(manifest):
        raise ValueError("Duplicate URLs in document manifest")
    # Static manifest removals delete documents. Sitemap absence never deletes transcripts,
    # including checkpoints created before migration from the transcript manifest.
    for docid, previous in list(completed.items()):
        if previous["source_url"] not in urls and not (discovery and previous["kind"] == "transcript"):
            delete_document(docid, previous)
            op.delete(table="fetch_status", keys={"source_url": previous["source_url"]})
            del completed[docid]
            op.checkpoint(state)
    for item in manifest:
        url, kind = item["url"], item["document_type"]
        parser_version = REGULATION_PARSER_VERSION if kind == "regulation" else PARSER_VERSION
        parent, child = KINDS[kind]
        docid = sha(url)
        signature = sha(
            json.dumps(item, sort_keys=True)
            + parser_version
            + configuration.get("refresh_generation", "initial")
        )
        previous = completed.get(docid)
        if previous and previous.get("signature") == signature and not fetcher.refresh:
            continue
        status, detail = "deleted", "Removed by manifest"
        parsed = None
        if not item.get("deleted"):
            try:
                raw, _headers = fetcher.fetch(url)
                title, published, blocks = extract(raw, item)
                parsed = (raw, title, published, blocks)
                status, detail = "parsed", f"{len(blocks)} sections"
            except requests.HTTPError as exc:
                status = (
                    "unavailable" if exc.response.status_code in (404, 410) else "download_failed"
                )
                detail = str(exc)
            except (requests.RequestException, RuntimeError, PermissionError) as exc:
                status, detail = "download_failed", str(exc)
            except Exception as exc:
                status, detail = "parsing_failed", f"{type(exc).__name__}: {exc}"
        # SDK failures must propagate; never label a failed warehouse write as a parse failure.
        if parsed:
            raw, title, published, blocks = parsed
            if previous and previous["kind"] != kind:
                delete_document(docid, previous)
                previous = None
            text = "\n\n".join(b["text"] for b in blocks)
            row = dict(
                document_id=docid,
                source_url=url,
                title=title,
                published_at=published,
                source_hash=sha(raw),
                content_hash=sha(normalized(text)),
                parser_version=parser_version,
                full_text=text,
                section_count=len(blocks),
            )
            row.update({key: item.get(key) for key in KIND_COLUMNS[kind]})
            op.upsert(table=parent, data=row)
            for n, block in enumerate(blocks):
                op.upsert(table=child, data=dict(document_id=docid, position=n, **block))
            for n in range(len(blocks), (previous or {}).get("section_count", 0)):
                op.delete(table=child, keys={"document_id": docid, "position": n})
            completed[docid] = dict(
                signature=signature, kind=kind, source_url=url, section_count=len(blocks)
            )
        elif status in ("deleted", "unavailable"):
            delete_document(docid, previous)
            completed[docid] = dict(signature=signature, kind=kind, source_url=url, section_count=0)
        else:
            failures.append(url)
        op.upsert(
            table="fetch_status",
            data=dict(
                source_url=url, status=status, detail=detail, checked_at=datetime.now(timezone.utc)
            ),
        )
        op.checkpoint(state)
    if failures:
        raise RuntimeError(
            f"{len(failures)} documents failed; see fetch_status; retry resumes progress"
        )


connector = Connector(update=update, schema=schema)
if __name__ == "__main__":
    connector.debug()

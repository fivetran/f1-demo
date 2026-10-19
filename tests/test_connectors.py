import importlib.util
import json
from datetime import datetime, timezone
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]


def load(name):
    spec = importlib.util.spec_from_file_location(name, ROOT / "connectors" / name / "connector.py")
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def test_question_context_and_speaker_do_not_follow_mentions():
    m = load("documents")
    raw = (
        "<html><title>Singapore 2023</title><main><p>Q: Did Lewis help?</p>"
        "<p>Carlos SAINZ: " + ("I helped Lando with DRS. " * 15) + "</p>"
        "<p>Q: How?</p><p>CS: " + ("I kept the gap small. " * 15) + "</p></main></html>"
    ).encode()
    title, date, blocks = m.extract(raw, {"document_type": "transcript"})
    answers = [b for b in blocks if b["speaker"] == "Carlos SAINZ"]
    assert len(answers) == 2 and answers[-1]["question"] == "Q: How?"
    assert all(b["speaker"] != "Lewis" for b in blocks)


def test_raw_version_and_content_hash_distinguish_markup():
    m = load("documents")
    a = " ".join(["a"] * 200)
    b = "\n".join(["a"] * 200)
    assert m.sha(a) != m.sha(b)
    assert m.sha(m.normalized(a)) == m.sha(m.normalized(b))


def test_regulation_sections_follow_headings_across_pages(monkeypatch):
    from types import SimpleNamespace

    m = load("documents")
    pages = [
        "2025 Formula 1 Technical Regulations 1 26 February 2025\n"
        "© 2025 Fédération Internationale de l’Automobile Issue 2\n"
        "CONTENTS:\n1.1 General\nARTICLE 1: GENERAL\n1.1 General\n"
        "1.1.1 First rule\n" + "A complete sentence. " * 150 + "\nContinues",
        "2025 Formula 1 Technical Regulations 2 26 February 2025\n"
        "© 2025 Fédération Internationale de l’Automobile Issue 2\n"
        "on the next page.\n1.1.1.1 A deeper clause stays with its parent.\n"
        "1.0 deg./s. is a measurement, not a heading.\n1.1.2 Second rule\n"
        "Body.\n1.2 A section without a third level\nBody.\n"
        "12.3.2 6.2mm Zylon Panel\nPanel text.\n"
        "17.3.1 “Listed Team Components” are defined here.\n"
        "APPENDIX 1\n1. Appendix heading\nAppendix body.",
    ]
    reader = SimpleNamespace(pages=[SimpleNamespace(extract_text=lambda t=t: t) for t in pages])
    monkeypatch.setattr(m, "PdfReader", lambda _: reader)
    _, _, blocks = m.extract(b"%PDF-test", {"document_type": "regulation", "title": "Rules"})
    first = next(b for b in blocks if b["section"] == "1.1.1 First rule")
    assert first["page_number"] == 1
    assert len(first["text"].split()) > 120
    assert "Continues\non the next page." in first["text"]
    assert "1.1.1.1 A deeper clause" in first["text"]
    assert "1.0 deg./s." in first["text"]
    assert "1.1.2" not in first["text"]
    assert next(b for b in blocks if b["section"] == "1.1.2 Second rule")["page_number"] == 2
    assert next(b for b in blocks if b["section"] == "1.2 A section without a third level")["text"].endswith("Body.")
    assert blocks[-1]["text"] == "1. Appendix heading\nAppendix body."
    assert any(b["section"] == "12.3.2 6.2mm Zylon Panel" for b in blocks)
    assert any(b["section"].startswith("17.3.1 “") for b in blocks if b["section"])
    assert all("©" not in b["text"] and "2025 Formula 1" not in b["text"] for b in blocks)


def test_regulation_empty_page_requires_review():
    from types import SimpleNamespace

    m = load("documents")
    with pytest.raises(ValueError, match="Empty PDF page 1"):
        m.regulation_sections(SimpleNamespace(pages=[SimpleNamespace(extract_text=lambda: "")]))


def test_fia_single_paragraph_br_markup():
    m = load("documents")
    raw = (
        "<main><p><strong>Q: How did you win?</strong><br/><strong>Carlos SAINZ:</strong> "
        + "I gave Lando DRS. " * 20
        + "<br/><strong>Q: Was that planned?</strong><br/>"
        + "<strong>CS:</strong> "
        + "Yes, we managed the pace. " * 20
        + "</p></main>"
    ).encode()
    _, _, blocks = m.extract(raw, {"document_type": "transcript"})
    assert len(blocks) == 4
    assert blocks[3]["speaker"] == "Carlos SAINZ"
    assert blocks[3]["question"] == "Q: Was that planned?"


def test_document_checkpoint_survives_ephemeral_cache(monkeypatch, tmp_path):
    m = load("documents")
    manifest = tmp_path / "manifest.json"
    manifest.write_text(
        json.dumps([{"url": "https://example.org/doc", "document_type": "transcript"}])
    )
    downloads = []

    def fetch(*args):
        downloads.append(True)
        return ("<main><p>" + "Race report. " * 30 + "</p></main>").encode(), {}

    monkeypatch.setattr(m.Fetcher, "fetch", fetch)
    monkeypatch.setattr(m.op, "upsert", lambda **kw: None)
    monkeypatch.setattr(m.op, "checkpoint", lambda s: None)
    state = {}
    config = {"manifest_path": str(manifest), "cache_dir": str(tmp_path / "cache")}
    m.update(config, state)
    m.update(config, json.loads(json.dumps(state)))
    assert len(downloads) == 1
    m.update(dict(config, refresh="true"), state)
    assert len(downloads) == 2


def test_endpoint_schemas_are_typed_and_keyed():
    m = load("openf1")
    tables = {s["table"]: s for s in m.schema({})}
    assert len(tables) == 19
    assert "records" not in tables
    assert tables["laps"]["primary_key"] == ["session_key", "driver_number", "lap_number"]
    assert tables["car_data"]["columns"]["speed"] == "LONG"
    row = m.typed_row(
        "intervals",
        dict(
            session_key=1,
            driver_number=4,
            date="2023-01-01T00:00:00Z",
            gap_to_leader="+1 LAP",
            interval=1.25,
        ),
    )
    assert row["gap_to_leader"] == "+1 LAP" and row["interval"] == "1.25"
    with pytest.raises(ValueError, match="Undeclared"):
        m.typed_row("drivers", {"new_field": 1})


def test_failed_write_does_not_checkpoint(monkeypatch):
    m = load("openf1")
    state = {"completed": {}}

    def fail(**kwargs):
        raise RuntimeError("write interrupted")

    monkeypatch.setattr(m.op, "upsert", fail)
    with pytest.raises(RuntimeError, match="interrupted"):
        m.ingest(None, "drivers", 1, {}, state, "v2", rows=[{"session_key": 1, "driver_number": 4}])
    assert not state["completed"]


def test_resume_makes_no_endpoint_request(monkeypatch):
    m = load("openf1")
    state = {"completed": {"laps:9165": "v2"}}
    m.ingest(None, "laps", 9165, {}, state, "v2")
    # None has no get method; a completed scope must return before touching the client.


def test_grid_uses_qualifying_source_key_and_checkpoint(monkeypatch):
    m = load("openf1")
    sessions = [
        dict(
            session_key=10, meeting_key=1, session_name="Sprint Qualifying", date_start="2025-01-01"
        ),
        dict(session_key=11, meeting_key=1, session_name="Qualifying", date_start="2025-01-02"),
        dict(session_key=12, meeting_key=1, session_name="Race", date_start="2025-01-03", date_end="2025-01-03T16:00:00Z"),
    ]
    requests = []

    def get(self, endpoint, **params):
        requests.append((endpoint, params))
        if endpoint == "meetings":
            return [dict(meeting_key=1)]
        if endpoint == "sessions":
            return sessions
        assert endpoint == "starting_grid" and params == {"session_key": 11}
        return [dict(session_key=11, driver_number=4, position=1)]

    events = []
    monkeypatch.setattr(m.Client, "get", get)
    monkeypatch.setattr(m.log, "info", lambda message: None)
    monkeypatch.setattr(m.op, "upsert", lambda **kw: events.append(kw))
    monkeypatch.setattr(m.op, "checkpoint", lambda s: None)
    state = {}
    config = {"year": "2025", "endpoints": "starting_grid"}
    m.update(config, state)
    m.update(config, state)
    assert len([r for r in requests if r[0] == "starting_grid"]) == 1
    grid = [e["data"] for e in events if e["table"] == "starting_grid"]
    assert grid[0]["session_key"] == 11
    assert "starting_grid:11" in state["completed"]
    assert "starting_grid:12" not in state["completed"]


def test_grid_rejects_missing_or_ambiguous_qualifying():
    m = load("openf1")
    race = dict(meeting_key=1)
    with pytest.raises(ValueError, match="one qualifying"):
        m.starting_grid_session([], race)
    qualifying = dict(meeting_key=1, session_name="Qualifying")
    with pytest.raises(ValueError, match="one qualifying"):
        m.starting_grid_session([qualifying, qualifying], race)


def test_multiple_seasons_preserve_checkpoints_and_skip_unfinished_races(monkeypatch):
    m = load("openf1")
    sessions = {
        2025: [dict(session_key=1, meeting_key=1, session_name="Race", date_start="2025-01-01", date_end="2025-01-01T16:00:00Z")],
        2026: [
            dict(session_key=2, meeting_key=2, session_name="Race", date_start="2026-03-01", date_end="2026-03-01T16:00:00Z"),
            dict(session_key=3, meeting_key=3, session_name="Race", date_start="2999-01-01", date_end="2999-01-01T16:00:00Z"),
            dict(session_key=4, meeting_key=4, session_name="Race", date_start="2026-03-02", date_end="2026-03-02T16:00:00Z", is_cancelled=True),
            dict(session_key=5, meeting_key=5, session_name="Race", date_start="2026-03-03", date_end=datetime.now(timezone.utc).isoformat()),
        ],
    }
    requests, events = [], []

    def get(self, endpoint, **params):
        requests.append((endpoint, params))
        if endpoint == "meetings":
            return [dict(meeting_key=params["year"])]
        if endpoint == "sessions":
            return sessions[params["year"]]
        assert endpoint == "drivers" and params == {"session_key": 2}
        return [dict(session_key=2, driver_number=4)]

    monkeypatch.setattr(m.Client, "get", get)
    monkeypatch.setattr(m.op, "upsert", lambda **kw: events.append(kw))
    monkeypatch.setattr(m.op, "checkpoint", lambda state: None)
    monkeypatch.setattr(m.log, "info", lambda message: None)
    state = {"schema_version": 2, "completed": {"drivers:1": "existing"}}
    config = {"years": "2025,2026", "endpoints": "drivers", "refresh_generation": "existing"}
    m.update(config, state)
    m.update(config, state)
    assert [params for endpoint, params in requests if endpoint == "drivers"] == [{"session_key": 2}]
    assert state["completed"]["drivers:1"] == state["completed"]["drivers:2"] == "existing"
    assert all(f"drivers:{key}" not in state["completed"] for key in (3, 4, 5))
    assert len([e for e in events if e["table"] == "meetings"]) == 4


def test_document_refresh_removes_trailing_sections(monkeypatch, tmp_path):
    m = load("documents")
    url = "https://example.org/doc"
    manifest = tmp_path / "manifest.json"
    manifest.write_text(json.dumps([{"url": url, "document_type": "transcript"}]))
    monkeypatch.setattr(m.Fetcher, "fetch", lambda *a: (b"source", {}))
    monkeypatch.setattr(
        m,
        "extract",
        lambda *a: (
            "Title",
            None,
            [dict(text="text", speaker=None, question=None, section=None, page_number=None)],
        ),
    )
    deletes = []
    monkeypatch.setattr(m.op, "upsert", lambda **kw: None)
    monkeypatch.setattr(m.op, "delete", lambda **kw: deletes.append(kw))
    monkeypatch.setattr(m.op, "checkpoint", lambda s: None)
    state = {
        "documents": {
            m.sha(url): {
                "signature": "old",
                "kind": "transcript",
                "source_url": url,
                "section_count": 3,
            }
        }
    }
    m.update({"manifest_path": str(manifest), "cache_dir": str(tmp_path)}, state)
    assert [d["keys"]["position"] for d in deletes] == [1, 2]
    assert all(d["table"] == "transcript_passages" for d in deletes)


def test_parse_failure_keeps_last_good_document(monkeypatch, tmp_path):
    m = load("documents")
    manifest = tmp_path / "manifest.json"
    manifest.write_text(
        json.dumps([{"url": "https://example.org/doc", "document_type": "transcript"}])
    )
    monkeypatch.setattr(m.Fetcher, "fetch", lambda *a: (b"<html>broken</html>", {}))
    events = []
    monkeypatch.setattr(m.op, "upsert", lambda **kw: events.append(kw))
    monkeypatch.setattr(m.op, "checkpoint", lambda s: None)
    with pytest.raises(RuntimeError, match="documents failed"):
        m.update({"manifest_path": str(manifest), "cache_dir": str(tmp_path)}, {})
    assert len(events) == 1 and events[0]["data"]["status"] == "parsing_failed"


def test_manifest_removal_deletes_document_sections_and_status(monkeypatch, tmp_path):
    m = load("documents")
    manifest = tmp_path / "manifest.json"
    manifest.write_text("[]")
    url = "https://example.org/doc"
    docid = m.sha(url)
    state = {"documents": {docid: {"kind": "transcript", "source_url": url, "section_count": 2}}}
    events = []
    monkeypatch.setattr(m.op, "delete", lambda **kw: events.append(kw))
    monkeypatch.setattr(m.op, "checkpoint", lambda s: None)
    m.update({"manifest_path": str(manifest), "cache_dir": str(tmp_path)}, state)
    assert state["documents"] == {}
    assert [e["table"] for e in events] == [
        "transcript_passages",
        "transcript_passages",
        "transcripts",
        "fetch_status",
    ]
    assert events[-1]["keys"] == {"source_url": url}


def test_transcript_discovery_dates_metadata_and_sitemap_refresh(monkeypatch):
    from types import SimpleNamespace

    m = load('documents')
    root = 'https://www.fia.com/sitemap.xml'
    child = root + '?page=1'
    prefix = 'https://www.fia.com/news/'
    italian = prefix + 'italian-grand-prix-post-race-press-conference-transcript'
    old = prefix + 'f1-monaco-grand-prix-thursday-press-conference-transcript'
    added = prefix + 'f1-2025-italian-grand-prix-friday-press-conference-transcript'
    urls = [italian, old, prefix + 'f1-2024-monaco-grand-prix-post-race-press-conference-transcript']
    calls = []
    lastmod = '2025-09-08'

    def fetch(url, revalidate=False):
        calls.append((url, revalidate))
        ns = 'xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"'
        if url == root:
            return f'<sitemapindex {ns}><sitemap><loc>{child}</loc></sitemap></sitemapindex>'.encode(), {}
        if url == child:
            return (f'<urlset {ns}>' + ''.join(
                f'<url><loc>{u}</loc><lastmod>{lastmod}</lastmod></url>' for u in urls
            ) + '</urlset>').encode(), {}
        date = '2024-05-23' if url == old else '2025-09-07'
        return (f'<meta property="article:published_time" content="{date}T18:00:00+02:00">'
                '<meta property="og:title" content="Conference">').encode(), {}

    def request(url):
        if '/meetings?' in url:
            return SimpleNamespace(json=lambda: [dict(meeting_key=1272, meeting_name='Italian Grand Prix')])
        return SimpleNamespace(json=lambda: [dict(meeting_key=1272,
            date_start='2025-09-07T13:00:00+00:00', date_end='2025-09-07T15:00:00+00:00')])

    fetcher = SimpleNamespace(fetch=fetch, request=request, refresh=False)
    state = {}
    items = m.discover_transcripts(fetcher, {2025}, state)
    assert len(items) == 1 and items[0]['url'] == italian
    assert items[0]['meeting_key'] == 1272 and items[0]['conference_type'] == 'post-race'
    urls.append(added)
    items = m.discover_transcripts(fetcher, {2025}, json.loads(json.dumps(state)))
    assert {i['url'] for i in items} == {italian, added}
    assert sum(u == italian for u, _ in calls) == 1
    assert sum(u == old for u, _ in calls) == 1
    assert sum(u == child and fresh for u, fresh in calls) == 2
    lastmod = '2025-09-09'
    refreshed = m.discover_transcripts(fetcher, {2025}, state)
    assert all(i['sitemap_lastmod'] == lastmod for i in refreshed)
    assert sum(u == italian and fresh for u, fresh in calls) == 2
    fetcher.request = lambda url: SimpleNamespace(json=lambda: [])
    with pytest.raises(ValueError, match='Expected one race weekend'):
        m.discover_transcripts(fetcher, {2025}, state)


def test_sitemap_absence_preserves_legacy_transcripts_but_static_removal_deletes(monkeypatch, tmp_path):
    m = load('documents')
    manifest = tmp_path / 'manifest.json'
    manifest.write_text('[]')
    state = {'documents': {
        'transcript': dict(kind='transcript', source_url='https://example.org/transcript', section_count=2),
        'regulation': dict(kind='regulation', source_url='https://example.org/regulation', section_count=1),
    }}
    monkeypatch.setattr(m, 'discover_transcripts', lambda *args: [])
    deleted = []
    monkeypatch.setattr(m.op, 'delete', lambda **kw: deleted.append(kw))
    monkeypatch.setattr(m.op, 'checkpoint', lambda s: None)
    m.update(dict(manifest_path=str(manifest), cache_dir=str(tmp_path), transcript_years='2025'), state)
    assert set(state['documents']) == {'transcript'}
    assert [d['table'] for d in deleted] == ['regulation_sections', 'regulations', 'fetch_status']


def test_discovery_failure_does_not_delete_or_checkpoint(monkeypatch, tmp_path):
    m = load('documents')
    manifest = tmp_path / 'manifest.json'
    manifest.write_text('[]')
    state = {'documents': {'old': dict(kind='glossary', source_url='https://example.org/old', section_count=1)}}
    def fail(*args):
        raise RuntimeError('sitemap unavailable')
    monkeypatch.setattr(m, 'discover_transcripts', fail)
    events = []
    monkeypatch.setattr(m.op, 'delete', lambda **kw: events.append(kw))
    monkeypatch.setattr(m.op, 'checkpoint', lambda s: events.append(s))
    with pytest.raises(RuntimeError, match='sitemap unavailable'):
        m.update(dict(manifest_path=str(manifest), cache_dir=str(tmp_path), transcript_years='2025'), state)
    assert not events and 'old' in state['documents']

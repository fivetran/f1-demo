{{ config(alias='ROOT') }}

select
    'user' as provider,
    'user' as key,
    r"""# F1 dimensional catalog

Start with AGENTS.TABLES, then look up DIMENSIONS, MEASURES and JOINS. AGENTS.ROOT contains one row with provider `user`, key `user`, and this Markdown document. Four dimensional metadata tables describe the finished data. The specification is pinned at https://github.com/dbt-labs/agents_schema/blob/a0bc90498302c8abb15a5e98a54c8c94df5a52f8/SPEC.md. Physical names use canonical uppercase AGENTS; data table names remain lowercase.

The catalog describes the finished query tables in `{{ target.database }}.f1`: normalized racing data and searchable documents. Use BigQuery Standard SQL. TABLES.table_name is fully qualified; quote it with backticks. A primary_key array states the row grain. It is a validated logical key, not an enforced warehouse constraint. All five metadata tables describe data; none copies race measurements or document bodies.

DIMENSIONS documents every physical column, including numeric observations usable as row-level filters. Merely being numeric does not make a column summable. MEASURES provides the deliberate aggregate expressions and their restrictions. Use alias `t` when applying an aggregate or row_filter. JSON mini-sector arrays remain raw data, not inferred timing measures.

## Coverage and identities

Racing data covers 2025 and completed 2026 races. Always filter meetings.year for a season-specific question; for comparisons group by year and state the completed-race coverage. Meeting/session metadata includes testing, practice, qualifying and sprint sessions. Detailed racing facts cover main Grand Prix Race sessions (24 in 2025); future and cancelled races have metadata only. Starting grids are the exception: their session_key identifies main Qualifying. No detailed Sprint points or Sprint laps are loaded. Read sync_status when investigating missing detail; metadata presence does not imply endpoint coverage. A 404/unavailable scope is not zero events. A recent timestamp for one scope does not establish completeness or freshness of other scopes.

Drivers are people, teams are named team identities, and session_entries assigns a person and team to a car number within one session. Never join facts on driver_number alone. Number mappings are season-scoped: for example, Norris changes from 4 in 2025 to 1 in 2026. Person IDs use source names and are not guaranteed permanent across spelling changes. Driver portraits use the latest non-null photo; circuit URLs and locality labels describe the latest calendar meeting, not a historical version. Team colour belongs to team_sessions. Driver country codes were all null in the 2025 profile; do not invent nationality.

## Aggregation and joins

1. Establish the question's base grain before joining. JOIN type records maximum cardinality from `l` to `r`; it does not choose INNER versus LEFT. A one-one relationship can be optional. Apply each input's TABLES.row_filter before an outer join.
2. A many-one lookup preserves the left grain. A one-many expansion repeats the parent's measures. Aggregate independent fact tables separately to a shared grain before combining them. DISTINCT on a repeated numeric amount is not a fix for double-counting. Reversing a many-one join makes it one-many. Do not combine multiple paths to the same dimension without choosing explicit roles.
3. Race points are additive over Race results. Championship points are snapshots: select one session checkpoint (latest by session date, not MAX(points)) before summing across people or teams. Snapshots include nonparticipating drivers, so joining through session_entries can silently drop them. Before/after checkpoint changes are not a substitute for all-season Race-plus-Sprint points.
4. Ranks, speeds and temperatures are not additive. Means are computed from base observations, not averages of group averages. Telemetry, gap and weather means are sample-weighted. To estimate elapsed time, use explicit timestamp intervals and boundary rules. Wind direction is circular; no arithmetic-mean measure is offered.
5. Qualifying grid to Race result requires this path: grid -> Qualifying session -> same-meeting main Race session -> Race entry -> result, with the additional grid.driver_id = Race entry.driver_id condition. Joining only on meeting or equating the two session keys is wrong. Preserve grids with no Race result using LEFT JOIN. Position gain is source grid position minus final classified position; it is not a count of on-track overtakes or a guarantee of the actual penalty-adjusted starting position.
6. Do not join laps directly to weather, car_data, location, position or intervals solely on session/driver. Those facts have different grains and clocks. Aggregate independently or define an as-of/interval match with an explicit maximum age and at most one chosen target per source row. Exact timestamp equality across independent feeds is not assumed.
7. Inclusive lap-to-stint range matching is NOT a declared many-one join. Validation of 2025 found 80 laps matching multiple stint ranges and 44 with none. An analysis of pace by compound or tyre age must identify ambiguous/unmatched laps and state how they are handled; never silently choose MIN/MAX(stint_number). Stint spans are not additive distinct lap counts. A causal tyre-degradation estimate also needs comparable laps and control for fuel, traffic, weather and race-control conditions.
8. Gap strings can contain lap labels. SAFE_CAST metrics deliberately exclude nonnumeric values; report coverage rather than convert lapped cars to zero seconds. Null timing means missing, not zero. Positive lap/sector durations are usable timings, not automatically a clean racing-lap cohort. A sum of best sectors may not correspond to any real lap.
9. Pit lane_duration and stationary stop_duration are distinct. The deprecated pit_duration aliases lane_duration (all 821 profiled 2025 rows agree); never add the aliases. Only 702 of those 2025 visits have stationary timings. Neither duration measures causal race time lost to a stop. Overtakes are recorded position exchanges, including pit/penalty effects, not exclusively on-track passes. Race-control message counts are not incident counts or safety-car durations. Radio records reference audio; the press-conference corpus is not a transcription of team radio.

## Documents

Transcript coverage remains 2025; do not infer 2026 document coverage from racing tables. Choose `transcript_passages_search` for press-conference quotes, `regulation_passages_search` for rules, and `glossary_passages_search` for definitions. Query the relevant table directly; for questions spanning sources, search each relevant table separately and synthesize the cited evidence. Each row carries document metadata and citation URL alongside the complete passage in `text`. Read passages in order by `source_position` within `(document_type, document_id)`. To retrieve adjacent context, query the same table for the neighboring source positions. A block is not necessarily one article, glossary term or utterance. Use distinct document keys for document counts. Transcript meeting associations retain `association_method` provenance. Explicit speaker labels are text, not verified driver identities; do not join on a mentioned name.

Regulation editions require applicability assessment; published_at does not prove an article's effective date, and unknown effective dates stay unknown. Current glossary pages explain terminology but are not historical 2025 law. No season-only regulation-to-race join or inferred speaker-to-driver join is declared.

## Hybrid document retrieval

Use `f1.transcript_passages_search`, `f1.regulation_passages_search`, or `f1.glossary_passages_search` according to the question. Each has its own embeddings and supports hybrid search. Small sources can be searched without an index. Search `embedding_text`; return `text` with document metadata for context and citation. A usable embedding has empty status and a 3072-element result. NULL embeddings are unavailable for search, and nonempty status indicates an error. Compare embedding_ready_count with row_count to assess how much of the selected corpus is searchable.

Use ``AI.SEARCH(TABLE `{{ target.database }}.f1.transcript_passages_search`, 'embedding_text', 'your question', mode => 'HYBRID', top_k => 5)`` for transcript evidence; substitute the regulation or glossary table when appropriate. Explicit HYBRID avoids AUTO silently selecting semantic-only search. All three tables store document_id, source_position and speaker_label for prefiltering; transcripts additionally store meeting_key and conference_type, and regulations store rule_family and applicable_season. Do not refer to transcript columns in the regulation/glossary tables or regulation columns in the other tables. A speaker label is not a verified identity; a regulation season is not proof of applicability.

Regulation search uses complete numbered sections through level three (such as 1.1.1), retaining deeper clauses and continuations across PDF pages. Each regulation section has no fixed word limit; page_number is its starting page. Article/appendix headings and unheaded front matter are also retained. Contents can repeat section numbers. Transcript and glossary search also keep each complete source passage in one row. Deduplicate `(document_type, document_id, source_position)` when counting blocks, or `(document_type, document_id)` when counting documents. Gemini Embedding 2 embeds up to 8,192 input tokens; the API truncates oversized embedding inputs, while the complete passage remains stored and should be read for answer context. Successful embedding status does not prove full-text semantic coverage. `embedding_text` includes bounded contextual material; glossary context can mention neighboring definitions. Inspect the full `text` passage, read adjacent positions in this table when needed, and cite `source_url`. Hybrid matches and their semantic distances are not exhaustive fact counts or calibrated confidence scores. The output order is not guaranteed. AI.SEARCH omits rows without embeddings; check readiness when freshness matters. The query examples below illustrate all three topics.

## Findings from warehouse profiling

The current 2025 checkpoint feed disagrees with classified Race result point changes on 23 driver rows across Australia, China, Singapore and Las Vegas. Treat each feed as its own recorded state; do not claim every checkpoint has been reconciled to later classification. Grand Prix result points total 2,424, while the latest driver championship checkpoint totals 2,640; Race-only detail cannot explain the full championship season.

The 2025 car samples include 1,160,081 brake codes of 104 and 1,157,156 throttle values above 100. The braking fraction uses only documented 0/100 codes, and the throttle mean uses only values in 0..100; always report their coverage measures. Gear codes exceed 8 on 474 samples, including within scheduled Race windows. Do not silently clamp these codes or infer their physical meaning. Some 5,604,947 car samples fall outside the scheduled session interval; retain them but select an explicit analysis window.

Glossary speaker labels can be section labels such as Example. They are not people. Regulation and glossary question fields, and regulation speaker fields, are all null in this corpus. All eight regulation editions have unknown effective_from/effective_to dates. These observations describe the current data; check the relevant fields for the subset you query.

## Metadata tables

TABLES: one physical relation per row. table_name is fully qualified; primary_key is the grain. Apply row_filter with alias t before joins. Descriptions explain scope and limitations.

DIMENSIONS: one physical column per row, including identifiers, categories, text, timestamps and raw numeric observations. Numeric columns are not automatically additive. column_name is literal; data_type matches BigQuery.

MEASURES: one named aggregate per table. sql_expression is a complete BigQuery aggregate using table alias t. Apply TABLES.row_filter and description constraints first. Recompute averages/ratios from base rows; do not sum averages. Snapshot measures require one checkpoint. All aggregates must preserve the base table grain.

JOINS: one named directed relationship. from_table uses alias l, to_table uses r. sql_expression is the ON predicate, not a full SELECT. join_type means maximum cardinality (one-one, one-many, many-one), not INNER/LEFT. Optional relationships require LEFT JOIN. Filter both inputs before joining. Reverse joins invert cardinality. Never infer a safe fact-to-fact join from a shared dimension.

## Twenty motivating questions

This coverage checklist restates the exploratory topics for the new catalog; it is not a claim to reproduce the earlier chat questions verbatim. Restrictions are part of the answer, not missing joins to be fabricated.

| # | Question | Measures and relationships |
|---|---|---|
| 1 | Which countries and circuits hosted the season's Grands Prix? | sessions.grand_prix_count; sessions -> meetings -> circuits -> countries; exclude testing/Sprint. |
| 2 | Who drove for each team at each race, including midseason changes? | session_entries -> drivers / teams; count distinct people, retain session membership. |
| 3 | Who scored the most Grand Prix points, wins and podiums? | session_result.race_points / wins / podiums -> session_entries -> drivers / teams; excludes Sprint points. |
| 4 | What were the driver and constructor standings after a selected race? | driver_standings / team_standings checkpoint_points and checkpoint_rank; filter one checkpoint and join canonical identities directly. |
| 5 | Who gained the most positions relative to the published grid? | Qualifying -> main Race role join plus grid.driver_id = entry.driver_id; grid position minus result position; report unmatched rows and flags. |
| 6 | Who recorded the fastest lap and best sector times at each circuit? | laps.fastest_lap_seconds / best_duration_sector_*_seconds -> entries / sessions / geography; no fabricated actual lap from best sectors. |
| 7 | Which drivers had the most consistent comparable lap times? | laps.average_lap_seconds / lap_time_stddev_seconds; define comparable-lap cohort before aggregation. |
| 8 | Which drivers or teams had the fastest stationary pit stops? | pit.fastest_stop_duration_seconds / average_stop_duration_seconds -> session_entries -> drivers / teams; separate lane transit. |
| 9 | How many pit visits and tyre stints did each driver use? | pit.row_count and stints.row_count aggregated separately per entry before combining; these counts are not interchangeable. |
| 10 | Which compounds were used, and how long were reported stints? | stints.compound / average_reported_span_laps / average_starting_tyre_age_laps; spans can overlap. |
| 11 | How did pace change as tyres aged? | laps + stint ranges require an explicit overlap/unmatched policy first; no misleading many-one join or causal degradation measure. |
| 12 | Who gained and lost the most recorded position exchanges? | overtakes.row_count with separate overtaking and overtaken entry roles; includes pit/penalty changes and feed limitations. |
| 13 | How often did drivers retire, fail to start, or get disqualified? | session_result.dnf_count / dns_count / dsq_count; specify denominator and overlapping flags. |
| 14 | What were peak speeds and sampled throttle/braking patterns? | car_data.maximum_speed_kmh / average_sample_throttle_pct / braking_sample_fraction; choose time window; no elapsed-time claim. |
| 15 | How did the gaps to the leader evolve? | intervals numeric gap averages plus numeric coverage; preserve +1 LAP labels; explicit time windows. |
| 16 | What were race weather conditions, and did it rain? | weather average temperatures and rainy_sample_fraction -> sessions; sample statistics, not duration/depth. |
| 17 | Which flags and race-control messages occurred around an incident? | race_control messages with optional entry/lap joins; explicit time window for other feeds; message count is not incident duration. |
| 18 | What did drivers say after a difficult race, and what radio clips are available? | transcript_passages_search -> meetings; read text once per source_position with speaker labels and source URLs. team_radio -> entries separately; no inferred audio transcript or person link. |
| 19 | What do racing terms mean, and what did the relevant regulation edition say? | glossary_passages_search or regulation_passages_search; inspect full text blocks and edition/applicability, cite sources, no season-only legal join. |
| 20 | Is an apparent gap missing data or genuinely no recorded events? | sync_status unavailable_scope_count / reported_source_rows for racing coverage; each chosen search table's document_count / source_block_count and embedding_ready_count for document/search coverage. Search misses do not establish absence; use ordinary SQL to inspect text and counts. |

# Query examples

## grid_to_finish

Question: Show each driver's qualifying grid position, race finish and positions gained in 2025.

```sql
-- Each output row is one published grid entry, including entrants with no Race result.
SELECT g.session_key AS qualifying_session_key, g.driver_id, race.session_key AS race_session_key,
  d.full_name, g.position AS grid_position, result.position AS finish_position,
  g.position - result.position AS positions_gained,
  result.driver_number AS result_driver_number, result.dnf, result.dns, result.dsq
FROM `{{ target.database }}.f1.starting_grid` AS g
JOIN `{{ target.database }}.f1.sessions` AS q ON g.session_key = q.session_key
LEFT JOIN `{{ target.database }}.f1.sessions` AS race
  ON q.meeting_key = race.meeting_key
  AND q.session_name = 'Qualifying' AND NOT COALESCE(q.is_cancelled, FALSE)
  AND race.session_name = 'Race' AND NOT COALESCE(race.is_cancelled, FALSE)
LEFT JOIN `{{ target.database }}.f1.session_entries` AS e
  ON race.session_key = e.session_key AND g.driver_id = e.driver_id
LEFT JOIN `{{ target.database }}.f1.session_result` AS result
  ON e.session_key = result.session_key AND e.driver_number = result.driver_number
JOIN `{{ target.database }}.f1.drivers` AS d ON g.driver_id = d.driver_id
ORDER BY qualifying_session_key, grid_position
```

## lap_stint_ambiguity

Question: How many laps have ambiguous or missing tyre-stint matches?

```sql
-- Diagnostics only: this many-many range match is intentionally absent from AGENTS.JOINS.
SELECT COUNTIF(stint_matches > 1) AS ambiguous_laps,
  COUNTIF(stint_matches = 0) AS unmatched_laps, COUNT(*) AS lap_rows
FROM (
  SELECT l.session_key, l.driver_number, l.lap_number, COUNT(s.stint_number) AS stint_matches
  FROM `{{ target.database }}.f1.laps` AS l
  LEFT JOIN `{{ target.database }}.f1.stints` AS s
    ON l.session_key = s.session_key AND l.driver_number = s.driver_number
    AND l.lap_number BETWEEN s.lap_start AND s.lap_end
  GROUP BY 1, 2, 3
)
```

## latest_driver_standings

Question: What are the latest available driver championship standings?

```sql
-- Choose latest available checkpoint by event time, never the maximum points value.
WITH checkpoint AS (
  SELECT s.session_key
  FROM `{{ target.database }}.f1.sessions` AS s
  WHERE EXISTS (SELECT 1 FROM `{{ target.database }}.f1.driver_standings` AS p
                WHERE p.session_key = s.session_key)
  ORDER BY s.date_start DESC, s.session_key DESC LIMIT 1
)
SELECT p.session_key, p.driver_id, d.full_name, p.points_current, p.position_current
FROM `{{ target.database }}.f1.driver_standings` AS p
JOIN checkpoint USING (session_key)
JOIN `{{ target.database }}.f1.drivers` AS d USING (driver_id)
ORDER BY p.position_current
```

## pace_and_pit

Question: Compare recorded average lap times and pit visits for each race entry.

```sql
-- Aggregate independent facts before combining; joining raw laps to raw pit visits inflates both.
WITH pace AS (
  SELECT session_key, driver_number,
    AVG(IF(lap_duration > 0, lap_duration, NULL)) AS average_recorded_lap_seconds,
    COUNT(*) AS lap_rows
  FROM `{{ target.database }}.f1.laps` GROUP BY 1, 2
), stops AS (
  SELECT session_key, driver_number, COUNT(*) AS pit_visits,
    AVG(IF(stop_duration > 0, stop_duration, NULL)) AS average_stationary_stop_seconds
  FROM `{{ target.database }}.f1.pit` GROUP BY 1, 2
)
SELECT e.session_key, e.driver_id, e.team_id, pace.lap_rows,
  pace.average_recorded_lap_seconds, COALESCE(stops.pit_visits, 0) AS pit_visits,
  stops.average_stationary_stop_seconds
FROM `{{ target.database }}.f1.session_entries` AS e
LEFT JOIN pace USING (session_key, driver_number)
LEFT JOIN stops USING (session_key, driver_number)
-- Zero pit visits is justified only for scopes explicitly completed as available.
JOIN `{{ target.database }}.f1.sync_status` AS coverage
  ON e.session_key = coverage.session_key AND coverage.endpoint = 'pit'
  AND coverage.status = 'available' AND coverage.driver_number IS NULL
```

## search_glossary

Question: Explain dirty air and loss of downforce when following another car, using glossary sources.

```sql
select base.document_id, base.source_position,
       base.title, base.text, base.embedding_text, base.source_url, distance
from ai.search(
    (select * from `{{ target.database }}.f1.glossary_passages_search`),
    'embedding_text', 'dirty air and loss of downforce when following another car',
    mode => 'HYBRID', top_k => 5
)
```

## search_regulations

Question: Find regulations about leaving the track and gaining a lasting advantage, with citations.

```sql
-- Retrieve evidence across editions; assess applicability before applying a rule.
select base.document_id, base.source_position,
       base.title, base.rule_family, base.effective_from, base.effective_to,
       base.text, base.source_url, distance
from ai.search(
    (select * from `{{ target.database }}.f1.regulation_passages_search`),
    'embedding_text', 'leaving the track and gaining a lasting advantage',
    mode => 'HYBRID', top_k => 5
)
```

## search_transcripts

Question: Find post-race comments about tyre degradation and managing tyres, with citations.

```sql
-- Hybrid retrieval selects relevant evidence; distance is semantic distance,
-- not a calibrated confidence or a documented combined ranking score.
select base.document_id, base.source_position,
       base.title, base.speaker_label, base.question, base.text,
       base.source_url, distance
from ai.search(
    (select * from `{{ target.database }}.f1.transcript_passages_search`
     where conference_type = 'post-race'),
    'embedding_text', 'tyre degradation and managing the tyres during the race',
    mode => 'HYBRID', top_k => 5
)
```

## transcript_context

Question: Show original transcript blocks mentioning tyres, with their race context.

```sql
-- Each row holds one full passage.
SELECT p.document_id, p.source_url, p.title, p.conference_type, p.association_method,
  m.meeting_name, p.source_position, p.speaker_label, p.question, p.text
FROM `{{ target.database }}.f1.transcript_passages_search` AS p
LEFT JOIN `{{ target.database }}.f1.meetings` AS m USING (meeting_key)
WHERE LOWER(COALESCE(p.text, '')) LIKE '%tyre%'
ORDER BY p.document_id, p.source_position
LIMIT 100
```
""" as content

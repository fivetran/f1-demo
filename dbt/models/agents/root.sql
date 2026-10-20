select
    'user' as provider,
    'user' as key,
    r"""# F1 query catalog

Start with agents.tables, then look up columns and joins. agents.root contains one row with provider `user`, key `user`, and this Markdown document. The four catalog tables are root, tables, columns and joins. This is a project-specific query catalog; physical names use lowercase model names in the agents dataset.

The catalog describes the finished query tables in `{{ target.database }}.f1`: racing data and native document collections. Use BigQuery Standard SQL. TABLES.table_name is fully qualified; quote it with backticks. A primary_key array states the row grain. It is a validated logical key, not an enforced warehouse constraint. All four metadata tables describe data; none copies race measurements or document bodies.

COLUMNS describes physical columns, including their meanings, units, null semantics and aggregation limitations. Types come from the physical table schema. Numeric columns are not automatically summable. Use the model-provided decoded and derived columns for analysis; raw values remain available for inspection. Use alias `t` when applying a row_filter. JSON mini-sector arrays remain raw data.

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
8. Gap strings can contain lap labels. The interval_seconds and gap_to_leader_seconds columns are null for nonnumeric values; report coverage rather than convert lapped cars to zero seconds. Null timing means missing, not zero. Recorded lap and sector durations do not automatically define a clean racing-lap cohort. A sum of best sectors may not correspond to any real lap.
9. Pit lane_duration and stationary stop_duration are distinct. The deprecated pit_duration aliases lane_duration (all 821 profiled 2025 rows agree); never add the aliases. Only 702 of those 2025 visits have stationary timings. Neither duration measures causal race time lost to a stop. Overtakes are recorded position exchanges, including pit/penalty effects, not exclusively on-track passes. Race-control message counts are not incident counts or safety-car durations. Radio records reference audio; the press-conference corpus is not a transcription of team radio.

## Documents

All query tables include source rows marked deleted.

Transcript coverage remains 2025. Search `f1.transcript_passages` for quotes, `f1.regulation_sections` for rules, and `f1.glossary_sections` for definitions. Each collection has its own schema. Join passages to their parent (`transcripts`, `regulations`, or `glossary`) on `document_id` to obtain title, source_url and collection-specific metadata. Join transcripts to `f1.meetings` for race context. Document tables include source rows marked deleted. Passage tables also retain previously loaded rows if they disappear from the source. Speaker labels are not verified identities.

Read the complete `text` and retrieve neighboring passages ordered by the qualified column `p.position` within a document. Regulation sections follow headings through level three (1.1.1), retaining deeper clauses and page continuations. Section numbers may repeat. Glossary sections follow HTML headings. Publication dates are not event/effective dates; unknown regulation effective dates remain null. Current glossary pages are not historical law.

## Hybrid document retrieval

Choose retrieval per question; there is no mandatory search mode:
- Semantic concepts or paraphrases: `VECTOR_SEARCH` on `embedding`, with a query vector from `AI.EMBED(query_text, endpoint => 'gemini-embedding-2').result` and COSINE distance.
- Specific words or names: `SEARCH(text, 'terms')` in a WHERE clause. SEARCH is a boolean token match requiring all supplied terms, not a relevance score or semantic match. For an exact substring use STRPOS or LIKE; for known section numbers prefer equality on section. Apply ordinary SQL ordering and limits as appropriate.
- Both: single-query `VECTOR_SEARCH` with `lexical_search_columns => ['text']` and `lexical_search_query_value => query_text` combines semantic and keyword retrieval (Preview). Alternatively run the two searches separately and deduplicate evidence by (document_id, position).
Search each relevant collection separately. Join passages to their parent for citations and applicability; filter parent criteria through document_id before retrieval. Small tables support these queries without index acceleration. Do not use AI.SEARCH: these tables have ordinary embedding arrays, not autonomous generated embeddings.

Gemini Embedding 2 embeds up to 8,192 input tokens, truncating oversized inputs while the complete text remains stored for RAG. Embeddings are 3072-element ARRAY<FLOAT64> values. Check ARRAY_LENGTH(embedding) = 3072 when inspecting embedding coverage. Vector and hybrid matches are relevant evidence, not exhaustive counts or calibrated confidence scores. Always inspect full text and cite the parent's source_url.


## Findings from warehouse profiling

The current 2025 checkpoint feed disagrees with classified Race result point changes on 23 driver rows across Australia, China, Singapore and Las Vegas. Treat each feed as its own recorded state; do not claim every checkpoint has been reconciled to later classification. Grand Prix result points total 2,424, while the latest driver championship checkpoint totals 2,640; Race-only detail cannot explain the full championship season.

The 2025 car samples include 1,160,081 brake codes of 104 and 1,157,156 throttle values above 100. is_braking decodes only documented 0/100 codes; throttle_pct contains only values in 0..100. Report COUNT of these nullable fields alongside COUNT(*) when aggregating. is_known_gear identifies codes in 0..8. Gear codes exceed 8 on 474 samples, including within scheduled Race windows. Do not silently clamp these codes or infer their physical meaning. Some 5,604,947 car samples fall outside the scheduled session interval; retain them but select an explicit analysis window.

All eight regulation editions have unknown effective_from/effective_to dates. Check applicability for the subset you query.

## Metadata tables

TABLES: one physical relation per row. table_name is fully qualified; primary_key is the grain. Apply row_filter with alias t before joins. Descriptions explain scope and limitations.

COLUMNS: one physical column per row. table_name identifies its relation; column_name is literal; description explains meaning, units, nulls and appropriate use. There is no separate dimensions or measures table. Recompute averages and fractions from base rows; select one checkpoint for snapshot values.

JOINS: one named directed relationship. from_table uses alias l, to_table uses r. sql_expression is the ON predicate, not a full SELECT. join_type means maximum cardinality (one-one, one-many, many-one), not INNER/LEFT. Optional relationships require LEFT JOIN. Filter both inputs before joining. Reverse joins invert cardinality. Never infer a safe fact-to-fact join from a shared dimension.

## Twenty motivating questions

This coverage checklist restates the exploratory topics for the new catalog; it is not a claim to reproduce the earlier chat questions verbatim. Restrictions are part of the answer, not missing joins to be fabricated.

| # | Question | Columns and relationships |
|---|---|---|
| 1 | Which countries and circuits hosted the season's Grands Prix? | count sessions with session_name = 'Race' and no cancellation; sessions -> meetings -> circuits -> countries; exclude testing/Sprint. |
| 2 | Who drove for each team at each race, including midseason changes? | session_entries -> drivers / teams; count distinct people, retain session membership. |
| 3 | Who scored the most Grand Prix points, wins and podiums? | sum session_result.points; count winning/top-three positions excluding DSQ -> session_entries -> drivers / teams; excludes Sprint points. |
| 4 | What were the driver and constructor standings after a selected race? | driver_standings / team_standings points_current and position_current; filter one checkpoint and join canonical identities directly. |
| 5 | Who gained the most positions relative to the published grid? | Qualifying -> main Race role join plus grid.driver_id = entry.driver_id; grid position minus result position; report unmatched rows and flags. |
| 6 | Who recorded the fastest lap and best sector times at each circuit? | min laps.lap_duration / duration_sector_1/2/3 -> entries / sessions / geography; no fabricated actual lap from best sectors. |
| 7 | Which drivers had the most consistent comparable lap times? | avg and stddev_pop of laps.lap_duration; define comparable-lap cohort before aggregation. |
| 8 | Which drivers or teams had the fastest stationary pit stops? | min and avg of pit.stop_duration -> session_entries -> drivers / teams; separate lane transit. |
| 9 | How many pit visits and tyre stints did each driver use? | pit and stints row counts aggregated separately per entry before combining; these counts are not interchangeable. |
| 10 | Which compounds were used, and how long were reported stints? | stints.compound / reported_span_laps / tyre_age_at_start; spans can overlap. |
| 11 | How did pace change as tyres aged? | laps + stint ranges require an explicit overlap/unmatched policy first; no misleading many-one join or causal degradation measure. |
| 12 | Who gained and lost the most recorded position exchanges? | count overtakes rows with separate overtaking and overtaken entry roles; includes pit/penalty changes and feed limitations. |
| 13 | How often did drivers retire, fail to start, or get disqualified? | count true session_result.dnf / dns / dsq flags; specify denominator and overlapping flags. |
| 14 | What were peak speeds and sampled throttle/braking patterns? | max car_data.speed / avg throttle_pct / avg cast(is_braking as int64); choose time window; no elapsed-time claim. |
| 15 | How did the gaps to the leader evolve? | intervals.interval_seconds and gap_to_leader_seconds averages plus nonnull counts; preserve +1 LAP labels; explicit time windows. |
| 16 | What were race weather conditions, and did it rain? | weather average temperatures and fraction of known rainfall samples flagged 1 -> sessions; sample statistics, not duration/depth. |
| 17 | Which flags and race-control messages occurred around an incident? | race_control messages with optional entry/lap joins; explicit time window for other feeds; message count is not incident duration. |
| 18 | What did drivers say after a difficult race, and what radio clips are available? | transcript_passages -> transcripts -> meetings; read text once per position with speaker labels and source URLs. team_radio -> entries separately; no inferred audio transcript or person link. |
| 19 | What do racing terms mean, and what did the relevant regulation edition say? | glossary_sections -> glossary or regulation_sections -> regulations; inspect full text blocks and edition/applicability, cite sources, no season-only legal join. |
| 20 | Is an apparent gap missing data or genuinely no recorded events? | sync_status.status / row_count for racing coverage; document parent and passage row counts / embedding validity for document/search coverage. Search misses do not establish absence; use ordinary SQL to inspect text and counts. |

# Query examples

## race_achievements

Question: How many Grand Prix points, wins and podiums did each driver record in 2025?

```sql
select
    d.full_name,
    sum(r.points) as race_points,
    countif(r.position = 1 and not coalesce(r.dsq, false)) as wins,
    countif(r.position between 1 and 3 and not coalesce(r.dsq, false)) as podiums
from `{{ target.database }}.f1.session_result` as r
join `{{ target.database }}.f1.session_entries` as e
    on r.session_key = e.session_key and r.driver_number = e.driver_number
join `{{ target.database }}.f1.drivers` as d on e.driver_id = d.driver_id
join `{{ target.database }}.f1.sessions` as s on r.session_key = s.session_key
join `{{ target.database }}.f1.meetings` as m on s.meeting_key = m.meeting_key
where m.year = 2025 and s.session_name = 'Race'
group by d.driver_id, d.full_name
order by race_points desc
```

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
-- Diagnostics only: this many-many range match is intentionally absent from agents.joins.
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
    AVG(lap_duration) AS average_recorded_lap_seconds,
    COUNT(*) AS lap_rows
  FROM `{{ target.database }}.f1.laps` GROUP BY 1, 2
), stops AS (
  SELECT session_key, driver_number, COUNT(*) AS pit_visits,
    AVG(stop_duration) AS average_stationary_stop_seconds
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
select hits.base.document_id, hits.base.position, d.title,
       hits.base.text, d.source_url, hits.distance
from vector_search(
    (select p.* from `{{ target.database }}.f1.glossary_sections` p
     where p.document_id in (
         select d.document_id from `{{ target.database }}.f1.glossary` d)),
    'embedding',
    query_value => ai.embed('dirty air and loss of downforce when following another car',
        endpoint => 'gemini-embedding-2').result,
    distance_type => 'COSINE', top_k => 5
) hits
join `{{ target.database }}.f1.glossary` d
  on hits.base.document_id = d.document_id
```

## search_regulations

Question: Find regulation passages containing the words lasting advantage, with citations.

```sql
select p.document_id, p.position, d.title, p.section,
       p.text, d.source_url, d.rule_family, d.effective_from, d.effective_to
from `{{ target.database }}.f1.regulation_sections` p
join `{{ target.database }}.f1.regulations` d on p.document_id = d.document_id
where search(p.text, 'lasting advantage')
order by p.document_id, p.position
limit 20
```

## search_transcripts

Question: Find post-race comments about tyre degradation and managing tyres, with citations.

```sql
select hits.base.document_id, hits.base.position, d.title,
       hits.base.text, d.source_url, hits.base.speaker, hits.base.question, hits.distance
from vector_search(
    (select p.* from `{{ target.database }}.f1.transcript_passages` p
     where p.document_id in (
         select d.document_id from `{{ target.database }}.f1.transcripts` d where d.conference_type = 'post-race')),
    'embedding',
    query_value => ai.embed('tyre degradation and managing the tyres during the race',
        endpoint => 'gemini-embedding-2').result,
    lexical_search_columns => ['text'],
    lexical_search_query_value => 'tyre degradation and managing the tyres during the race',
    distance_type => 'COSINE', top_k => 5
) hits
join `{{ target.database }}.f1.transcripts` d
  on hits.base.document_id = d.document_id
```

## transcript_context

Question: Show original transcript passages mentioning tyres, with their race context.

```sql
select p.document_id, d.source_url, d.title, d.conference_type, d.association_method,
       m.meeting_name, p.position, p.speaker, p.question, p.text
from `{{ target.database }}.f1.transcript_passages` p
join `{{ target.database }}.f1.transcripts` d on p.document_id = d.document_id
left join `{{ target.database }}.f1.meetings` m on d.meeting_key = m.meeting_key
where lower(p.text) like '%tyre%'
order by p.document_id, p.position
limit 100
```
""" as content

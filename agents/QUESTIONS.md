# Twenty motivating questions

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
| 18 | What did drivers say after a difficult race, and what radio clips are available? | document_passages_search filtered to transcript -> meetings; read text once per source_position using chunk_index = 0, with speaker labels and source URLs. team_radio -> entries separately; no inferred audio transcript or person link. |
| 19 | What do racing terms mean, and what did the relevant regulation edition say? | document_passages_search filtered to glossary or regulation; inspect full text blocks and edition/applicability, cite sources, no season-only legal join. |
| 20 | Is an apparent gap missing data or genuinely no recorded events? | sync_status unavailable_scope_count / reported_source_rows for racing coverage; document_passages_search document_count / source_block_count and embedding_ready_count for document/search coverage. Search misses do not establish absence; use ordinary SQL to inspect text and counts. |

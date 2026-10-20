select *
from unnest(array<struct<table_name string, column_name string, description string>>[
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""brake""",
        r"""Raw brake code. Documented 0=not pressed and 100=pressed; 1,160,081 profiled 2025 samples contain undocumented 104. Preserve those values but do not silently decode 104 as pressed. Use is_braking for decoded sample statistics."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""date""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""drs""",
        r"""Raw DRS code, not a Boolean. Observed codes include undocumented 11,13,15 as well as known and uncertain codes. No automatic activation-time measure is offered."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""is_braking""",
        r"""Decoded brake state: false for raw 0, true for raw 100, null for unknown codes or missing values. AVG(CAST(is_braking AS INT64)) is the braking fraction among known samples, not elapsed braking time. Report COUNT(is_braking) alongside COUNT(*) for coverage."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""is_known_gear""",
        r"""Whether the raw gear code lies in the documented 0..8 range; null when missing. False identifies an undocumented code, not a physical extra gear."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""n_gear""",
        r"""Raw gear code. Documented range is 0 (neutral) to 8; 474 profiled 2025 samples exceed 8, including within scheduled Race windows. Do not interpret those codes as real extra gears. Use is_known_gear to identify undocumented samples."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""rpm""",
        r"""Engine revolutions per minute at the sample."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""speed""",
        r"""Instantaneous speed in km/h. MAX gives peak sampled speed; AVG is sample-weighted, not lap speed or distance divided by elapsed time. Choose an observation window; pre/post-race samples are included."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""throttle""",
        r"""Raw source throttle percentage. Observed range is 0..104 with 1,157,156 profiled 2025 values above 100. Range-filtered means exclude and report these samples; do not silently clamp them. Use throttle_pct for documented-range aggregates."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""throttle_pct""",
        r"""Throttle percentage in the documented 0..100 range; other raw codes become null. AVG is sample-weighted, not time at full throttle. Report COUNT(throttle_pct) alongside COUNT(*) for coverage."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""circuit_image""",
        r"""Circuit image URL from the latest calendar meeting."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""circuit_info_url""",
        r"""Circuit information URL from the latest calendar meeting; its season can differ from the race being analyzed."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""circuit_key""",
        r"""OpenF1 circuit identifier."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""circuit_short_name""",
        r"""Short source circuit name."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""circuit_type""",
        r"""Source circuit classification, for example permanent or street."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""country_key""",
        r"""OpenF1 venue-country identifier; a key, never an additive measure."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""location""",
        r"""Venue locality from the latest calendar meeting; not a telemetry coordinate."""
    ),
    (
        r"""{{ target.database }}.f1.countries""",
        r"""country_code""",
        r"""Source country code. In drivers this is entirely null in the profiled 2025 data; do not infer nationality."""
    ),
    (
        r"""{{ target.database }}.f1.countries""",
        r"""country_flag""",
        r"""Source country flag image reference."""
    ),
    (
        r"""{{ target.database }}.f1.countries""",
        r"""country_key""",
        r"""OpenF1 venue-country identifier; a key, never an additive measure."""
    ),
    (
        r"""{{ target.database }}.f1.countries""",
        r"""country_name""",
        r"""Venue country name."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""driver_id""",
        r"""Canonical person ID derived from source names; not guaranteed stable across spelling changes or future seasons."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""points_change""",
        r"""Recorded before/after checkpoint points difference. Not guaranteed to equal Race result points or cover Sprint points between snapshots; not complete seasonal points earned. Later result corrections may differ."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""points_current""",
        r"""Championship points as recorded at this session checkpoint. May reflect a during/post-race state that omits later corrections; never sum across checkpoints. Select exactly one session checkpoint before summing across distinct entities; never sum across checkpoints. Latest means latest by session time, not MAX(points), since adjustments can reduce points. Source snapshots may predate corrections."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""points_start""",
        r"""Cumulative championship points before this checkpoint. Not race points."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""position_current""",
        r"""Championship rank as recorded at this session checkpoint, potentially before later corrections; lower is better; not additive. Select one checkpoint and entity to read rank directly; MIN across entities or checkpoints is not a seasonal rank."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""position_start""",
        r"""Championship rank before this checkpoint; lower is better."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""broadcast_name""",
        r"""Driver display name used in broadcasts."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""country_code""",
        r"""Source country code. In drivers this is entirely null in the profiled 2025 data; do not infer nationality."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""driver_id""",
        r"""Canonical person ID derived from source names; not guaranteed stable across spelling changes or future seasons."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""first_name""",
        r"""Source driver given name."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""full_name""",
        r"""Source driver full display name."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""headshot_url""",
        r"""Latest non-null driver portrait URL by session time across the loaded seasons."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""last_name""",
        r"""Source driver surname."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""name_acronym""",
        r"""Source short driver abbreviation; use driver_id as the join key."""
    ),
    (
        r"""{{ target.database }}.f1.glossary""",
        r"""applicability_status""",
        r"""Applicability limitation supplied with this source."""
    ),
    (
        r"""{{ target.database }}.f1.glossary""",
        r"""document_id""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1.glossary""",
        r"""source_url""",
        r"""Original source URL for citation."""
    ),
    (
        r"""{{ target.database }}.f1.glossary""",
        r"""title""",
        r"""Source document title."""
    ),
    (
        r"""{{ target.database }}.f1.glossary_sections""",
        r"""document_id""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1.glossary_sections""",
        r"""position""",
        r"""Zero-based passage order within document_id; qualify this column with its table alias."""
    ),
    (
        r"""{{ target.database }}.f1.glossary_sections""",
        r"""section""",
        r"""Source heading; not a unique identifier."""
    ),
    (
        r"""{{ target.database }}.f1.glossary_sections""",
        r"""text""",
        r"""Complete source passage. Search this field and read full text for RAG. API truncation affects the embedding only."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""date""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""gap_to_leader""",
        r"""Source gap string: seconds or labels such as +1 LAP. Preserve labels; SAFE_CAST only parses numeric gaps."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""gap_to_leader_seconds""",
        r"""Numeric gap to the leader in seconds; null for lap/status labels or missing values. Raw gap_to_leader preserves labels. AVG is sample-weighted over numeric observations only; report COUNT(gap_to_leader_seconds) alongside COUNT(*) because exclusions can bias comparisons."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""interval""",
        r"""Source gap to the car ahead: numeric seconds or lap/status labels. Null is not zero."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""interval_seconds""",
        r"""Numeric gap to the car ahead in seconds; null for lap/status labels or missing values. Raw interval preserves labels. AVG is sample-weighted over numeric observations only; report COUNT(interval_seconds) alongside COUNT(*) because exclusions can bias comparisons."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""date_start""",
        r"""Source lap start timestamp in UTC; may be null for incomplete observations."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""duration_sector_1""",
        r"""Sector 1 duration in seconds; null means unavailable. Null means missing, not zero; COUNT of this column gives timing coverage compared with COUNT(*). Select comparable laps before pace analysis; pit and safety-car effects remain. Best sectors may come from different laps, so their sum is theoretical. Minimum lap duration is not automatically an official fastest-lap award."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""duration_sector_2""",
        r"""Sector 2 duration in seconds; null means unavailable. Null means missing, not zero; COUNT of this column gives timing coverage compared with COUNT(*). Select comparable laps before pace analysis; pit and safety-car effects remain. Best sectors may come from different laps, so their sum is theoretical. Minimum lap duration is not automatically an official fastest-lap award."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""duration_sector_3""",
        r"""Sector 3 duration in seconds; null means unavailable. Null means missing, not zero; COUNT of this column gives timing coverage compared with COUNT(*). Select comparable laps before pace analysis; pit and safety-car effects remain. Best sectors may come from different laps, so their sum is theoretical. Minimum lap duration is not automatically an official fastest-lap award."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""i_1_speed""",
        r"""Speed at intermediate trap 1 in km/h. MAX gives the highest recorded trap speed, not average lap speed."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""i_2_speed""",
        r"""Speed at intermediate trap 2 in km/h. MAX gives the highest recorded trap speed, not average lap speed."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""is_pit_out_lap""",
        r"""Source pit-out-lap flag. It does not identify all pit-in or safety-car laps. COUNTIF counts marked laps, not stationary pit stops."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""lap_duration""",
        r"""Source lap duration in seconds. Null means unavailable/incomplete, not zero. Null means missing, not zero; COUNT of this column gives timing coverage compared with COUNT(*). Select comparable laps before pace analysis; pit and safety-car effects remain. Best sectors may come from different laps, so their sum is theoretical. Minimum lap duration is not automatically an official fastest-lap award."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""lap_number""",
        r"""Lap ordinal within a driver/session; not an elapsed count to sum."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""segments_sector_1""",
        r"""JSON array of source mini-sector status codes for sector 1; not durations."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""segments_sector_2""",
        r"""JSON array of source mini-sector status codes for sector 2; not durations."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""segments_sector_3""",
        r"""JSON array of source mini-sector status codes for sector 3; not durations."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""st_speed""",
        r"""Speed-trap speed in km/h. MAX gives the highest recorded trap speed, not average lap speed."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""date""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""x""",
        r"""Source approximate X coordinate in a local track reference system; not longitude."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""y""",
        r"""Source approximate Y coordinate in a local track reference system; not latitude."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""z""",
        r"""Source approximate Z coordinate; do not assume precise surveyed elevation or derive distance without validation."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""circuit_key""",
        r"""OpenF1 circuit identifier."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""date_end""",
        r"""Source end timestamp in UTC."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""date_start""",
        r"""Source start timestamp in UTC; session schedule is not a hard boundary for captured observations."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""gmt_offset""",
        r"""Source local-time offset string; timestamps remain UTC."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""is_cancelled""",
        r"""Source cancellation indicator; null is unknown, not an explicit true."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""meeting_key""",
        r"""OpenF1 event/weekend identifier; a meeting contains several sessions and may be a testing event."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""meeting_name""",
        r"""Short event name."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""meeting_official_name""",
        r"""Official event name."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""year""",
        r"""Season year, not a count."""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""date""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""overtaken_driver_number""",
        r"""Session-scoped number of the driver losing the position; use the overtaken role join."""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""overtaking_driver_number""",
        r"""Session-scoped number of the driver gaining the position; use the overtaking role join."""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""position""",
        r"""Source position associated with the recorded exchange; not a count of passes."""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""date""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""lane_duration""",
        r"""Time in the pit lane, seconds; includes travel and a stop when present. Null means missing, not zero; COUNT of this column gives timing coverage compared with COUNT(*). Keep lane transit and stationary stop separate; neither measures causal race time lost to a pit strategy."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""lap_number""",
        r"""Lap ordinal within a driver/session; not an elapsed count to sum."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""pit_duration""",
        r"""Deprecated source alias for lane_duration (seconds). All 821 profiled 2025 rows agree exactly. Prefer lane_duration; never add these two columns together."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""stop_duration""",
        r"""Stationary pit-stop duration in seconds; null does not prove there was no stop. Null means missing, not zero; COUNT of this column gives timing coverage compared with COUNT(*). Keep lane transit and stationary stop separate; neither measures causal race time lost to a pit strategy."""
    ),
    (
        r"""{{ target.database }}.f1.position""",
        r"""date""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.position""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.position""",
        r"""position""",
        r"""Running-order rank at this observation; not final classified position or elapsed time in rank. MIN is best sampled running rank, not finishing rank. Observation counts do not measure laps or time led."""
    ),
    (
        r"""{{ target.database }}.f1.position""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""category""",
        r"""Source race-control message category."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""date""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""flag""",
        r"""Source flag code, when present. COUNT(flag) counts messages carrying flags, not distinct incidents or safety-car/red-flag durations; reconstruct event intervals first."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""lap_number""",
        r"""Lap ordinal within a driver/session; not an elapsed count to sum."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""message""",
        r"""Verbatim race-control message. Messages are not automatically distinct incidents or penalties."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""message_id""",
        r"""Opaque message identifier, unique together with session_key. It is not an incident identifier."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""qualifying_phase""",
        r"""Source qualifying phase, when present; current detailed coverage is Race."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""scope""",
        r"""Source scope label; interpretation is specific to this table."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""sector""",
        r"""Source sector number when the message is sector-scoped."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_sections""",
        r"""document_id""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_sections""",
        r"""page_number""",
        r"""One-based starting PDF page of this section."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_sections""",
        r"""position""",
        r"""Zero-based passage order within document_id; qualify this column with its table alias."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_sections""",
        r"""section""",
        r"""Source heading; not a unique identifier."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_sections""",
        r"""text""",
        r"""Complete source passage. Search this field and read full text for RAG. API truncation affects the embedding only."""
    ),
    (
        r"""{{ target.database }}.f1.regulations""",
        r"""applicability_status""",
        r"""Applicability limitation supplied with this source."""
    ),
    (
        r"""{{ target.database }}.f1.regulations""",
        r"""applicable_season""",
        r"""Intended regulation season; alone does not establish applicability."""
    ),
    (
        r"""{{ target.database }}.f1.regulations""",
        r"""document_id""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1.regulations""",
        r"""effective_from""",
        r"""Known effective start date, otherwise null."""
    ),
    (
        r"""{{ target.database }}.f1.regulations""",
        r"""effective_to""",
        r"""Known effective end date, otherwise null."""
    ),
    (
        r"""{{ target.database }}.f1.regulations""",
        r"""published_at""",
        r"""Source publication timestamp as supplied; not event or effective date."""
    ),
    (
        r"""{{ target.database }}.f1.regulations""",
        r"""rule_family""",
        r"""Regulation family, such as sporting or technical."""
    ),
    (
        r"""{{ target.database }}.f1.regulations""",
        r"""source_url""",
        r"""Original source URL for citation."""
    ),
    (
        r"""{{ target.database }}.f1.regulations""",
        r"""title""",
        r"""Source document title."""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""driver_id""",
        r"""Canonical person ID derived from source names; not guaranteed stable across spelling changes or future seasons. COUNT(DISTINCT driver_id) counts represented people, not race starts; non-additive across races or teams."""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""team_id""",
        r"""Team ID derived from the source team name; changes of name are not automatically reconciled. COUNT(DISTINCT team_id) counts represented teams; non-additive across sessions."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""dnf""",
        r"""Source did-not-finish flag; independent of DNS/DSQ. COUNTIF counts explicitly flagged results; null is not counted."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""dns""",
        r"""Source did-not-start flag; an entry does not necessarily imply a race start. COUNTIF counts explicitly flagged results; entries are not necessarily starts."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""dsq""",
        r"""Source disqualification flag. COUNTIF counts explicitly flagged results. Classification flags can overlap."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""duration""",
        r"""Source Race result duration in seconds; do not treat as a lap duration. Comparisons and averages require comparable race lengths and classifications; not a sum of lap samples."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""gap_to_leader""",
        r"""Source gap string: seconds or labels such as +1 LAP. Preserve labels; SAFE_CAST only parses numeric gaps."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""number_of_laps""",
        r"""Completed laps reported in the session result, distinct from lap rows with partial timing. SUM across drivers is driver-laps, not the race distance."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""points""",
        r"""Points awarded in this Grand Prix result. Summable across drivers/races, but excludes Sprint points. SUM is additive across entries and races. Sprint points are excluded, so this need not equal championship totals."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""position""",
        r"""Final classified Race position; lower is better. Use DNF/DNS/DSQ flags separately. Wins have position = 1 and podiums position BETWEEN 1 AND 3, excluding DSQ; the catalog convention treats null DSQ as not flagged. AVG is mean available classified rank; state treatment of DNS/DNF/DSQ."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""date_end""",
        r"""Source end timestamp in UTC."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""date_start""",
        r"""Source start timestamp in UTC; session schedule is not a hard boundary for captured observations."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""gmt_offset""",
        r"""Source local-time offset string; timestamps remain UTC."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""is_cancelled""",
        r"""Source cancellation indicator; null is unknown, not an explicit true."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""meeting_key""",
        r"""OpenF1 event/weekend identifier; a meeting contains several sessions and may be a testing event."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""session_name""",
        r"""Specific session name. Use exact Race for Grand Prix detail; exclude Sprint and Sprint Qualifying. Count scheduled Grands Prix with COUNTIF(session_name = 'Race' AND NOT COALESCE(is_cancelled, FALSE)); excludes Sprint/testing but can include future races. Verify completed detail using sync_status."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""session_type""",
        r"""Source session category; session_name is needed to distinguish main Race from Sprint."""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""driver_id""",
        r"""Canonical person ID derived from source names; not guaranteed stable across spelling changes or future seasons."""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""lap_duration""",
        r"""Source lap duration in seconds. Null means unavailable/incomplete, not zero. Null means missing, not zero; COUNT of this column gives timing coverage compared with COUNT(*). Supplied on the Qualifying-keyed grid; not a complete qualifying-lap history."""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""position""",
        r"""Position in the OpenF1 grid published under main Qualifying. Do not assume it incorporates every later grid penalty or pit-lane start. AVG is mean source qualifying-grid position; later penalties and pit-lane starts may differ."""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""compound""",
        r"""Source tyre compound label."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""lap_end""",
        r"""Source inclusive last lap of the stint; may be missing. Do not assume nonoverlapping ranges."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""lap_start""",
        r"""Source inclusive first lap of the stint. Boundaries can overlap adjacent stints."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""reported_span_laps""",
        r"""Inclusive reported stint span in laps; null for missing or reversed bounds. Spans overlap: do not sum as distinct laps or infer a many-one lap join. AVG describes reported spans, not total tyre life."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""stint_number""",
        r"""Source tyre-stint ordinal within an entry."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""tyre_age_at_start""",
        r"""Tyre age in laps at stint start, including prior use; not the stint length. AVG describes starting tyre age, not total tyre life."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""completed_at""",
        r"""Availability timestamp for this scope; not event time or evidence that every scope is current. MAX is the latest selected completion; other scopes may be older or unavailable."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""endpoint""",
        r"""OpenF1 endpoint for this request scope."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""row_count""",
        r"""Source row count for one completed request scope; compare within an endpoint, not across unrelated grains. Sum only disjoint completed scopes within one endpoint; different endpoints have incompatible grains. Not a total count of F1 events."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""scope""",
        r"""Coverage identifier for metadata, a session, or a driver within a session, depending on endpoint."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""status""",
        r"""Source retrieval/availability status. Missing/unavailable data is not evidence of zero events."""
    ),
    (
        r"""{{ target.database }}.f1.team_radio""",
        r"""date""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.team_radio""",
        r"""driver_number""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.team_radio""",
        r"""recording_url""",
        r"""Audio recording URL. No audio transcript is stored in this table."""
    ),
    (
        r"""{{ target.database }}.f1.team_radio""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.team_sessions""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.team_sessions""",
        r"""team_colour""",
        r"""Source display colour for this team in this session; may vary across the season."""
    ),
    (
        r"""{{ target.database }}.f1.team_sessions""",
        r"""team_id""",
        r"""Team ID derived from the source team name; changes of name are not automatically reconciled."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""points_change""",
        r"""Recorded before/after checkpoint points difference. Not guaranteed to equal Race result points or cover Sprint points between snapshots; not complete seasonal points earned. Later result corrections may differ."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""points_current""",
        r"""Championship points as recorded at this session checkpoint. May reflect a during/post-race state that omits later corrections; never sum across checkpoints. Select exactly one session checkpoint before summing across distinct entities; never sum across checkpoints. Latest means latest by session time, not MAX(points), since adjustments can reduce points. Source snapshots may predate corrections."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""points_start""",
        r"""Cumulative championship points before this checkpoint. Not race points."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""position_current""",
        r"""Championship rank as recorded at this session checkpoint, potentially before later corrections; lower is better; not additive. Select one checkpoint and entity to read rank directly; MIN across entities or checkpoints is not a seasonal rank."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""position_start""",
        r"""Championship rank before this checkpoint; lower is better."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""team_id""",
        r"""Team ID derived from the source team name; changes of name are not automatically reconciled."""
    ),
    (
        r"""{{ target.database }}.f1.teams""",
        r"""team_id""",
        r"""Team ID derived from the source team name; changes of name are not automatically reconciled."""
    ),
    (
        r"""{{ target.database }}.f1.teams""",
        r"""team_name""",
        r"""Source team name."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages""",
        r"""document_id""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages""",
        r"""position""",
        r"""Zero-based passage order within document_id; qualify this column with its table alias."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages""",
        r"""question""",
        r"""Question providing context for this transcript passage, when available."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages""",
        r"""section""",
        r"""Source heading; not a unique identifier."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages""",
        r"""speaker""",
        r"""Source speaker label, not a resolved driver identity."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages""",
        r"""text""",
        r"""Complete source passage. Search this field and read full text for RAG. API truncation affects the embedding only."""
    ),
    (
        r"""{{ target.database }}.f1.transcripts""",
        r"""association_method""",
        r"""Provenance of the transcript-to-meeting association."""
    ),
    (
        r"""{{ target.database }}.f1.transcripts""",
        r"""conference_type""",
        r"""Press-conference type, such as post-race."""
    ),
    (
        r"""{{ target.database }}.f1.transcripts""",
        r"""document_id""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1.transcripts""",
        r"""meeting_key""",
        r"""Associated race meeting; join f1.meetings. Not a speaker identity."""
    ),
    (
        r"""{{ target.database }}.f1.transcripts""",
        r"""published_at""",
        r"""Source publication timestamp as supplied; not event or effective date."""
    ),
    (
        r"""{{ target.database }}.f1.transcripts""",
        r"""source_url""",
        r"""Original source URL for citation."""
    ),
    (
        r"""{{ target.database }}.f1.transcripts""",
        r"""title""",
        r"""Source document title."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""air_temperature""",
        r"""Ambient air temperature in degrees Celsius. AVG is sample-weighted, not time-weighted. Weather observations are session-level and independent of driver sample clocks."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""date""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""humidity""",
        r"""Relative humidity percent. AVG is sample-weighted, not time-weighted. Weather observations are session-level and independent of driver sample clocks."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""pressure""",
        r"""Air pressure in mbar. AVG is sample-weighted, not time-weighted. Weather observations are session-level and independent of driver sample clocks."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""rainfall""",
        r"""Source rainfall indicator (0/1); not precipitation depth or duration. SAFE_DIVIDE(COUNTIF(rainfall = 1), COUNT(rainfall)) is the fraction of nonnull samples flagged as rain, not elapsed rainy time."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""session_key""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""track_temperature""",
        r"""Track surface temperature in degrees Celsius. AVG is sample-weighted, not time-weighted. Weather observations are session-level and independent of driver sample clocks."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""wind_direction""",
        r"""Wind direction in degrees; circular, so ordinary arithmetic means are misleading."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""wind_speed""",
        r"""Wind speed in metres per second. AVG is sample-weighted, not time-weighted. Weather observations are session-level and independent of driver sample clocks."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages""",
        r"""embedding""",
        r"""Gemini Embedding 2 semantic vector, ARRAY<FLOAT64> with 3072 elements. Use matching query embeddings for vector/hybrid search. Invalid new vectors fail the model load; matches are evidence, not exhaustive counts."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages""",
        r"""_fivetran_synced""",
        r"""Source synchronization timestamp retained as the incremental update watermark; not the document publication or event time."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_sections""",
        r"""embedding""",
        r"""Gemini Embedding 2 semantic vector, ARRAY<FLOAT64> with 3072 elements. Use matching query embeddings for vector/hybrid search. Invalid new vectors fail the model load; matches are evidence, not exhaustive counts."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_sections""",
        r"""_fivetran_synced""",
        r"""Source synchronization timestamp retained as the incremental update watermark; not the document publication or event time."""
    ),
    (
        r"""{{ target.database }}.f1.glossary_sections""",
        r"""embedding""",
        r"""Gemini Embedding 2 semantic vector, ARRAY<FLOAT64> with 3072 elements. Use matching query embeddings for vector/hybrid search. Invalid new vectors fail the model load; matches are evidence, not exhaustive counts."""
    ),
    (
        r"""{{ target.database }}.f1.glossary_sections""",
        r"""_fivetran_synced""",
        r"""Source synchronization timestamp retained as the incremental update watermark; not the document publication or event time."""
    )
])

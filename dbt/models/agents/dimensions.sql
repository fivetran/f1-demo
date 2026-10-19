{{ config(alias='DIMENSIONS') }}

select *
from unnest(array<struct<table_name string, column_name string, data_type string, description string>>[
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""date""",
        r"""TIMESTAMP""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""brake""",
        r"""INTEGER""",
        r"""Raw brake code. Documented 0=not pressed and 100=pressed; 1,160,081 profiled 2025 samples contain undocumented 104. Preserve those values but do not silently decode 104 as pressed."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""drs""",
        r"""INTEGER""",
        r"""Raw DRS code, not a Boolean. Observed codes include undocumented 11,13,15 as well as known and uncertain codes. No automatic activation-time measure is offered."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""n_gear""",
        r"""INTEGER""",
        r"""Raw gear code. Documented range is 0 (neutral) to 8; 474 profiled 2025 samples exceed 8, including within scheduled Race windows. Do not interpret those codes as real extra gears."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""rpm""",
        r"""INTEGER""",
        r"""Engine revolutions per minute at the sample."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""speed""",
        r"""INTEGER""",
        r"""Instantaneous speed in km/h."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""throttle""",
        r"""INTEGER""",
        r"""Raw source throttle percentage. Observed range is 0..104 with 1,157,156 profiled 2025 values above 100. Range-filtered means exclude and report these samples; do not silently clamp them."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""circuit_key""",
        r"""INTEGER""",
        r"""OpenF1 circuit identifier."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""country_key""",
        r"""INTEGER""",
        r"""OpenF1 venue-country identifier; a key, never an additive measure."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""circuit_short_name""",
        r"""STRING""",
        r"""Short source circuit name."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""circuit_type""",
        r"""STRING""",
        r"""Source circuit classification, for example permanent or street."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""circuit_image""",
        r"""STRING""",
        r"""Circuit image URL from the latest calendar meeting."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""circuit_info_url""",
        r"""STRING""",
        r"""Circuit information URL from the latest calendar meeting; its season can differ from the race being analyzed."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""location""",
        r"""STRING""",
        r"""Venue locality from the latest calendar meeting; not a telemetry coordinate."""
    ),
    (
        r"""{{ target.database }}.f1.countries""",
        r"""country_key""",
        r"""INTEGER""",
        r"""OpenF1 venue-country identifier; a key, never an additive measure."""
    ),
    (
        r"""{{ target.database }}.f1.countries""",
        r"""country_code""",
        r"""STRING""",
        r"""Source country code. In drivers this is entirely null in the profiled 2025 data; do not infer nationality."""
    ),
    (
        r"""{{ target.database }}.f1.countries""",
        r"""country_name""",
        r"""STRING""",
        r"""Venue country name."""
    ),
    (
        r"""{{ target.database }}.f1.countries""",
        r"""country_flag""",
        r"""STRING""",
        r"""Source country flag image reference."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""driver_id""",
        r"""STRING""",
        r"""Canonical person ID derived from source names; not guaranteed stable across spelling changes or future seasons."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""points_current""",
        r"""FLOAT""",
        r"""Championship points as recorded at this session checkpoint. May reflect a during/post-race state that omits later corrections; never sum across checkpoints."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""points_start""",
        r"""FLOAT""",
        r"""Cumulative championship points before this checkpoint. Not race points."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""position_current""",
        r"""INTEGER""",
        r"""Championship rank as recorded at this session checkpoint, potentially before later corrections; lower is better; not additive."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""position_start""",
        r"""INTEGER""",
        r"""Championship rank before this checkpoint; lower is better."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""driver_id""",
        r"""STRING""",
        r"""Canonical person ID derived from source names; not guaranteed stable across spelling changes or future seasons."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""broadcast_name""",
        r"""STRING""",
        r"""Driver display name used in broadcasts."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""country_code""",
        r"""STRING""",
        r"""Source country code. In drivers this is entirely null in the profiled 2025 data; do not infer nationality."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""first_name""",
        r"""STRING""",
        r"""Source driver given name."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""full_name""",
        r"""STRING""",
        r"""Source driver full display name."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""headshot_url""",
        r"""STRING""",
        r"""Latest non-null driver portrait URL by session time across the loaded seasons."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""last_name""",
        r"""STRING""",
        r"""Source driver surname."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""name_acronym""",
        r"""STRING""",
        r"""Source short driver abbreviation; use driver_id as the join key."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""date""",
        r"""TIMESTAMP""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""gap_to_leader""",
        r"""STRING""",
        r"""Source gap string: seconds or labels such as +1 LAP. Preserve labels; SAFE_CAST only parses numeric gaps."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""interval""",
        r"""STRING""",
        r"""Source gap to the car ahead: numeric seconds or lap/status labels. Null is not zero."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""lap_number""",
        r"""INTEGER""",
        r"""Lap ordinal within a driver/session; not an elapsed count to sum."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""date_start""",
        r"""TIMESTAMP""",
        r"""Source lap start timestamp in UTC; may be null for incomplete observations."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""duration_sector_1""",
        r"""FLOAT""",
        r"""Sector 1 duration in seconds; null means unavailable."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""duration_sector_2""",
        r"""FLOAT""",
        r"""Sector 2 duration in seconds; null means unavailable."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""duration_sector_3""",
        r"""FLOAT""",
        r"""Sector 3 duration in seconds; null means unavailable."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""i_1_speed""",
        r"""INTEGER""",
        r"""Speed at intermediate trap 1 in km/h."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""i_2_speed""",
        r"""INTEGER""",
        r"""Speed at intermediate trap 2 in km/h."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""is_pit_out_lap""",
        r"""BOOLEAN""",
        r"""Source pit-out-lap flag. It does not identify all pit-in or safety-car laps."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""lap_duration""",
        r"""FLOAT""",
        r"""Source lap duration in seconds. Null means unavailable/incomplete, not zero."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""segments_sector_1""",
        r"""JSON""",
        r"""JSON array of source mini-sector status codes for sector 1; not durations."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""segments_sector_2""",
        r"""JSON""",
        r"""JSON array of source mini-sector status codes for sector 2; not durations."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""segments_sector_3""",
        r"""JSON""",
        r"""JSON array of source mini-sector status codes for sector 3; not durations."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""st_speed""",
        r"""INTEGER""",
        r"""Speed-trap speed in km/h."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""date""",
        r"""TIMESTAMP""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""x""",
        r"""INTEGER""",
        r"""Source approximate X coordinate in a local track reference system; not longitude."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""y""",
        r"""INTEGER""",
        r"""Source approximate Y coordinate in a local track reference system; not latitude."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""z""",
        r"""INTEGER""",
        r"""Source approximate Z coordinate; do not assume precise surveyed elevation or derive distance without validation."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""meeting_key""",
        r"""INTEGER""",
        r"""OpenF1 event/weekend identifier; a meeting contains several sessions and may be a testing event."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""circuit_key""",
        r"""INTEGER""",
        r"""OpenF1 circuit identifier."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""meeting_name""",
        r"""STRING""",
        r"""Short event name."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""meeting_official_name""",
        r"""STRING""",
        r"""Official event name."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""year""",
        r"""INTEGER""",
        r"""Season year, not a count."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""date_start""",
        r"""TIMESTAMP""",
        r"""Source start timestamp in UTC; session schedule is not a hard boundary for captured observations."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""date_end""",
        r"""TIMESTAMP""",
        r"""Source end timestamp in UTC."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""gmt_offset""",
        r"""STRING""",
        r"""Source local-time offset string; timestamps remain UTC."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""is_cancelled""",
        r"""BOOLEAN""",
        r"""Source cancellation indicator; null is unknown, not an explicit true."""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""date""",
        r"""TIMESTAMP""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""overtaken_driver_number""",
        r"""INTEGER""",
        r"""Session-scoped number of the driver losing the position; use the overtaken role join."""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""overtaking_driver_number""",
        r"""INTEGER""",
        r"""Session-scoped number of the driver gaining the position; use the overtaking role join."""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""position""",
        r"""INTEGER""",
        r"""Source position associated with the recorded exchange; not a count of passes."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""date""",
        r"""TIMESTAMP""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""lane_duration""",
        r"""FLOAT""",
        r"""Time in the pit lane, seconds; includes travel and a stop when present."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""lap_number""",
        r"""INTEGER""",
        r"""Lap ordinal within a driver/session; not an elapsed count to sum."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""pit_duration""",
        r"""FLOAT""",
        r"""Deprecated source alias for lane_duration (seconds). All 821 profiled 2025 rows agree exactly. Prefer lane_duration; never add these two columns together."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""stop_duration""",
        r"""FLOAT""",
        r"""Stationary pit-stop duration in seconds; null does not prove there was no stop."""
    ),
    (
        r"""{{ target.database }}.f1.position""",
        r"""date""",
        r"""TIMESTAMP""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.position""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.position""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.position""",
        r"""position""",
        r"""INTEGER""",
        r"""Running-order rank at this observation; not final classified position or elapsed time in rank."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""message_id""",
        r"""STRING""",
        r"""Opaque message identifier, unique together with session_key. It is not an incident identifier."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""category""",
        r"""STRING""",
        r"""Source race-control message category."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""date""",
        r"""TIMESTAMP""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""flag""",
        r"""STRING""",
        r"""Source flag code, when present."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""lap_number""",
        r"""INTEGER""",
        r"""Lap ordinal within a driver/session; not an elapsed count to sum."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""message""",
        r"""STRING""",
        r"""Verbatim race-control message. Messages are not automatically distinct incidents or penalties."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""qualifying_phase""",
        r"""STRING""",
        r"""Source qualifying phase, when present; current detailed coverage is Race."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""scope""",
        r"""STRING""",
        r"""Source scope label; interpretation is specific to this table."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""sector""",
        r"""INTEGER""",
        r"""Source sector number when the message is sector-scoped."""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""driver_id""",
        r"""STRING""",
        r"""Canonical person ID derived from source names; not guaranteed stable across spelling changes or future seasons."""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""team_id""",
        r"""STRING""",
        r"""Team ID derived from the source team name; changes of name are not automatically reconciled."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""dnf""",
        r"""BOOLEAN""",
        r"""Source did-not-finish flag; independent of DNS/DSQ."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""dns""",
        r"""BOOLEAN""",
        r"""Source did-not-start flag; an entry does not necessarily imply a race start."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""dsq""",
        r"""BOOLEAN""",
        r"""Source disqualification flag."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""duration""",
        r"""FLOAT""",
        r"""Source Race result duration in seconds; do not treat as a lap duration."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""gap_to_leader""",
        r"""STRING""",
        r"""Source gap string: seconds or labels such as +1 LAP. Preserve labels; SAFE_CAST only parses numeric gaps."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""number_of_laps""",
        r"""INTEGER""",
        r"""Completed laps reported in the session result, distinct from lap rows with partial timing."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""position""",
        r"""INTEGER""",
        r"""Final classified Race position; lower is better. Use DNF/DNS/DSQ flags separately."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""points""",
        r"""FLOAT""",
        r"""Points awarded in this Grand Prix result. Summable across drivers/races, but excludes Sprint points."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""meeting_key""",
        r"""INTEGER""",
        r"""OpenF1 event/weekend identifier; a meeting contains several sessions and may be a testing event."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""session_name""",
        r"""STRING""",
        r"""Specific session name. Use exact Race for Grand Prix detail; exclude Sprint and Sprint Qualifying."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""session_type""",
        r"""STRING""",
        r"""Source session category; session_name is needed to distinguish main Race from Sprint."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""date_start""",
        r"""TIMESTAMP""",
        r"""Source start timestamp in UTC; session schedule is not a hard boundary for captured observations."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""date_end""",
        r"""TIMESTAMP""",
        r"""Source end timestamp in UTC."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""gmt_offset""",
        r"""STRING""",
        r"""Source local-time offset string; timestamps remain UTC."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""is_cancelled""",
        r"""BOOLEAN""",
        r"""Source cancellation indicator; null is unknown, not an explicit true."""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""driver_id""",
        r"""STRING""",
        r"""Canonical person ID derived from source names; not guaranteed stable across spelling changes or future seasons."""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""lap_duration""",
        r"""FLOAT""",
        r"""Source lap duration in seconds. Null means unavailable/incomplete, not zero."""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""position""",
        r"""INTEGER""",
        r"""Position in the OpenF1 grid published under main Qualifying. Do not assume it incorporates every later grid penalty or pit-lane start."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""stint_number""",
        r"""INTEGER""",
        r"""Source tyre-stint ordinal within an entry."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""compound""",
        r"""STRING""",
        r"""Source tyre compound label."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""lap_end""",
        r"""INTEGER""",
        r"""Source inclusive last lap of the stint; may be missing. Do not assume nonoverlapping ranges."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""lap_start""",
        r"""INTEGER""",
        r"""Source inclusive first lap of the stint. Boundaries can overlap adjacent stints."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""tyre_age_at_start""",
        r"""INTEGER""",
        r"""Tyre age in laps at stint start, including prior use; not the stint length."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""endpoint""",
        r"""STRING""",
        r"""OpenF1 endpoint for this request scope."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""scope""",
        r"""STRING""",
        r"""Coverage identifier for metadata, a session, or a driver within a session, depending on endpoint."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""status""",
        r"""STRING""",
        r"""Source retrieval/availability status. Missing/unavailable data is not evidence of zero events."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""row_count""",
        r"""INTEGER""",
        r"""Source row count for one completed request scope; compare within an endpoint, not across unrelated grains."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""completed_at""",
        r"""TIMESTAMP""",
        r"""Availability timestamp for this scope; not event time or evidence that every scope is current."""
    ),
    (
        r"""{{ target.database }}.f1.team_radio""",
        r"""date""",
        r"""TIMESTAMP""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.team_radio""",
        r"""driver_number""",
        r"""INTEGER""",
        r"""Car number scoped to a session entry; never a permanent person identifier."""
    ),
    (
        r"""{{ target.database }}.f1.team_radio""",
        r"""recording_url""",
        r"""STRING""",
        r"""Audio recording URL. No audio transcript is stored in this table."""
    ),
    (
        r"""{{ target.database }}.f1.team_radio""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.team_sessions""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.team_sessions""",
        r"""team_id""",
        r"""STRING""",
        r"""Team ID derived from the source team name; changes of name are not automatically reconciled."""
    ),
    (
        r"""{{ target.database }}.f1.team_sessions""",
        r"""team_colour""",
        r"""STRING""",
        r"""Source display colour for this team in this session; may vary across the season."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""team_id""",
        r"""STRING""",
        r"""Team ID derived from the source team name; changes of name are not automatically reconciled."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""points_current""",
        r"""FLOAT""",
        r"""Championship points as recorded at this session checkpoint. May reflect a during/post-race state that omits later corrections; never sum across checkpoints."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""points_start""",
        r"""FLOAT""",
        r"""Cumulative championship points before this checkpoint. Not race points."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""position_current""",
        r"""INTEGER""",
        r"""Championship rank as recorded at this session checkpoint, potentially before later corrections; lower is better; not additive."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""position_start""",
        r"""INTEGER""",
        r"""Championship rank before this checkpoint; lower is better."""
    ),
    (
        r"""{{ target.database }}.f1.teams""",
        r"""team_id""",
        r"""STRING""",
        r"""Team ID derived from the source team name; changes of name are not automatically reconciled."""
    ),
    (
        r"""{{ target.database }}.f1.teams""",
        r"""team_name""",
        r"""STRING""",
        r"""Source team name."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""date""",
        r"""TIMESTAMP""",
        r"""Source observation/event timestamp in UTC. Different feeds have independent sampling clocks."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""session_key""",
        r"""INTEGER""",
        r"""OpenF1 session identifier. Race and Qualifying have different keys even within one meeting."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""air_temperature""",
        r"""FLOAT""",
        r"""Ambient air temperature in degrees Celsius."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""humidity""",
        r"""FLOAT""",
        r"""Relative humidity percent."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""pressure""",
        r"""FLOAT""",
        r"""Air pressure in mbar."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""rainfall""",
        r"""INTEGER""",
        r"""Source rainfall indicator (0/1); not precipitation depth or duration."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""track_temperature""",
        r"""FLOAT""",
        r"""Track surface temperature in degrees Celsius."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""wind_direction""",
        r"""INTEGER""",
        r"""Wind direction in degrees; circular, so ordinary arithmetic means are misleading."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""wind_speed""",
        r"""FLOAT""",
        r"""Wind speed in metres per second."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcripts""",
        r"""document_id""",
        r"""STRING""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcripts""",
        r"""source_url""",
        r"""STRING""",
        r"""Original source URL for citation."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcripts""",
        r"""title""",
        r"""STRING""",
        r"""Source document title."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcripts""",
        r"""published_at""",
        r"""STRING""",
        r"""Source publication timestamp as supplied; not event or effective date."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcripts""",
        r"""meeting_key""",
        r"""INT64""",
        r"""Associated race meeting; join f1.meetings. Not a speaker identity."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcripts""",
        r"""conference_type""",
        r"""STRING""",
        r"""Press-conference type, such as post-race."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcripts""",
        r"""association_method""",
        r"""STRING""",
        r"""Provenance of the transcript-to-meeting association."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcripts""",
        r"""_fivetran_deleted""",
        r"""BOOLEAN""",
        r"""Exclude true values in both parent and passage tables."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcript_passages""",
        r"""document_id""",
        r"""STRING""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcript_passages""",
        r"""position""",
        r"""INT64""",
        r"""Zero-based passage order within document_id; qualify this column with its table alias."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcript_passages""",
        r"""text""",
        r"""STRING""",
        r"""Complete source passage. Search this field and read full text for RAG. API truncation affects the embedding only."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcript_passages""",
        r"""question""",
        r"""STRING""",
        r"""Question providing context for this transcript passage, when available."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcript_passages""",
        r"""speaker""",
        r"""STRING""",
        r"""Source speaker label, not a resolved driver identity."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcript_passages""",
        r"""section""",
        r"""STRING""",
        r"""Source heading; not a unique identifier."""
    ),
    (
        r"""{{ target.database }}.f1_documents.transcript_passages""",
        r"""_fivetran_deleted""",
        r"""BOOLEAN""",
        r"""Exclude true values in both parent and passage tables."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulations""",
        r"""document_id""",
        r"""STRING""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulations""",
        r"""source_url""",
        r"""STRING""",
        r"""Original source URL for citation."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulations""",
        r"""title""",
        r"""STRING""",
        r"""Source document title."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulations""",
        r"""published_at""",
        r"""STRING""",
        r"""Source publication timestamp as supplied; not event or effective date."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulations""",
        r"""applicable_season""",
        r"""INT64""",
        r"""Intended regulation season; alone does not establish applicability."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulations""",
        r"""rule_family""",
        r"""STRING""",
        r"""Regulation family, such as sporting or technical."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulations""",
        r"""applicability_status""",
        r"""STRING""",
        r"""Applicability limitation supplied with this source."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulations""",
        r"""effective_from""",
        r"""STRING""",
        r"""Known effective start date, otherwise null."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulations""",
        r"""effective_to""",
        r"""STRING""",
        r"""Known effective end date, otherwise null."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulations""",
        r"""_fivetran_deleted""",
        r"""BOOLEAN""",
        r"""Exclude true values in both parent and passage tables."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulation_sections""",
        r"""document_id""",
        r"""STRING""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulation_sections""",
        r"""position""",
        r"""INT64""",
        r"""Zero-based passage order within document_id; qualify this column with its table alias."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulation_sections""",
        r"""text""",
        r"""STRING""",
        r"""Complete source passage. Search this field and read full text for RAG. API truncation affects the embedding only."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulation_sections""",
        r"""section""",
        r"""STRING""",
        r"""Source heading; not a unique identifier."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulation_sections""",
        r"""page_number""",
        r"""INT64""",
        r"""One-based starting PDF page of this section."""
    ),
    (
        r"""{{ target.database }}.f1_documents.regulation_sections""",
        r"""_fivetran_deleted""",
        r"""BOOLEAN""",
        r"""Exclude true values in both parent and passage tables."""
    ),
    (
        r"""{{ target.database }}.f1_documents.glossary""",
        r"""document_id""",
        r"""STRING""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1_documents.glossary""",
        r"""source_url""",
        r"""STRING""",
        r"""Original source URL for citation."""
    ),
    (
        r"""{{ target.database }}.f1_documents.glossary""",
        r"""title""",
        r"""STRING""",
        r"""Source document title."""
    ),
    (
        r"""{{ target.database }}.f1_documents.glossary""",
        r"""applicability_status""",
        r"""STRING""",
        r"""Applicability limitation supplied with this source."""
    ),
    (
        r"""{{ target.database }}.f1_documents.glossary""",
        r"""_fivetran_deleted""",
        r"""BOOLEAN""",
        r"""Exclude true values in both parent and passage tables."""
    ),
    (
        r"""{{ target.database }}.f1_documents.glossary_sections""",
        r"""document_id""",
        r"""STRING""",
        r"""Stable document identifier; joins a passage to its parent."""
    ),
    (
        r"""{{ target.database }}.f1_documents.glossary_sections""",
        r"""position""",
        r"""INT64""",
        r"""Zero-based passage order within document_id; qualify this column with its table alias."""
    ),
    (
        r"""{{ target.database }}.f1_documents.glossary_sections""",
        r"""text""",
        r"""STRING""",
        r"""Complete source passage. Search this field and read full text for RAG. API truncation affects the embedding only."""
    ),
    (
        r"""{{ target.database }}.f1_documents.glossary_sections""",
        r"""section""",
        r"""STRING""",
        r"""Source heading; not a unique identifier."""
    ),
    (
        r"""{{ target.database }}.f1_documents.glossary_sections""",
        r"""_fivetran_deleted""",
        r"""BOOLEAN""",
        r"""Exclude true values in both parent and passage tables."""
    )
])

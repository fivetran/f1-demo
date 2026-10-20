{{ config(alias='JOINS') }}

select *
from unnest(array<struct<join_name string, from_table string, to_table string, join_type string, sql_expression string, description string>>[
    (
        r"""circuits_to_countries""",
        r"""{{ target.database }}.f1.circuits""",
        r"""{{ target.database }}.f1.countries""",
        r"""many-one""",
        r"""l.country_key = r.country_key""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""meetings_to_circuits""",
        r"""{{ target.database }}.f1.meetings""",
        r"""{{ target.database }}.f1.circuits""",
        r"""many-one""",
        r"""l.circuit_key = r.circuit_key""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""sessions_to_meetings""",
        r"""{{ target.database }}.f1.sessions""",
        r"""{{ target.database }}.f1.meetings""",
        r"""many-one""",
        r"""l.meeting_key = r.meeting_key""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""team_sessions_to_sessions""",
        r"""{{ target.database }}.f1.team_sessions""",
        r"""{{ target.database }}.f1.sessions""",
        r"""many-one""",
        r"""l.session_key = r.session_key""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""team_sessions_to_teams""",
        r"""{{ target.database }}.f1.team_sessions""",
        r"""{{ target.database }}.f1.teams""",
        r"""many-one""",
        r"""l.team_id = r.team_id""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""session_entries_to_sessions""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""{{ target.database }}.f1.sessions""",
        r"""many-one""",
        r"""l.session_key = r.session_key""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""session_entries_to_drivers""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""{{ target.database }}.f1.drivers""",
        r"""many-one""",
        r"""l.driver_id = r.driver_id""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""session_entries_to_team_sessions""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""{{ target.database }}.f1.team_sessions""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.team_id = r.team_id""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""driver_standings_to_sessions""",
        r"""{{ target.database }}.f1.driver_standings""",
        r"""{{ target.database }}.f1.sessions""",
        r"""many-one""",
        r"""l.session_key = r.session_key""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data. Join drivers directly; nonparticipating championship drivers have no same-session entry."""
    ),
    (
        r"""driver_standings_to_drivers""",
        r"""{{ target.database }}.f1.driver_standings""",
        r"""{{ target.database }}.f1.drivers""",
        r"""many-one""",
        r"""l.driver_id = r.driver_id""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data. Join drivers directly; nonparticipating championship drivers have no same-session entry."""
    ),
    (
        r"""team_standings_to_sessions""",
        r"""{{ target.database }}.f1.team_standings""",
        r"""{{ target.database }}.f1.sessions""",
        r"""many-one""",
        r"""l.session_key = r.session_key""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""team_standings_to_teams""",
        r"""{{ target.database }}.f1.team_standings""",
        r"""{{ target.database }}.f1.teams""",
        r"""many-one""",
        r"""l.team_id = r.team_id""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""starting_grid_to_sessions""",
        r"""{{ target.database }}.f1.starting_grid""",
        r"""{{ target.database }}.f1.sessions""",
        r"""many-one""",
        r"""l.session_key = r.session_key""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data. This session is Qualifying, never the Race session; the driver join uses canonical identity."""
    ),
    (
        r"""starting_grid_to_drivers""",
        r"""{{ target.database }}.f1.starting_grid""",
        r"""{{ target.database }}.f1.drivers""",
        r"""many-one""",
        r"""l.driver_id = r.driver_id""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data. This session is Qualifying, never the Race session; the driver join uses canonical identity."""
    ),
    (
        r"""car_data_to_session_entries""",
        r"""{{ target.database }}.f1.car_data""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""intervals_to_session_entries""",
        r"""{{ target.database }}.f1.intervals""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""laps_to_session_entries""",
        r"""{{ target.database }}.f1.laps""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""location_to_session_entries""",
        r"""{{ target.database }}.f1.location""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""overtakes_to_sessions""",
        r"""{{ target.database }}.f1.overtakes""",
        r"""{{ target.database }}.f1.sessions""",
        r"""many-one""",
        r"""l.session_key = r.session_key""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data. For entry joins preserve the overtaking/overtaken role, with a separate alias and driver lookup for each."""
    ),
    (
        r"""overtakes_to_session_entries_overtaking""",
        r"""{{ target.database }}.f1.overtakes""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.overtaking_driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data. For entry joins preserve the overtaking/overtaken role, with a separate alias and driver lookup for each."""
    ),
    (
        r"""overtakes_to_session_entries_overtaken""",
        r"""{{ target.database }}.f1.overtakes""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.overtaken_driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data. For entry joins preserve the overtaking/overtaken role, with a separate alias and driver lookup for each."""
    ),
    (
        r"""pit_to_session_entries""",
        r"""{{ target.database }}.f1.pit""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""position_to_session_entries""",
        r"""{{ target.database }}.f1.position""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""race_control_to_sessions""",
        r"""{{ target.database }}.f1.race_control""",
        r"""{{ target.database }}.f1.sessions""",
        r"""many-one""",
        r"""l.session_key = r.session_key""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""race_control_to_session_entries""",
        r"""{{ target.database }}.f1.race_control""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. Optional reference: use LEFT JOIN to retain null/unmatched rows."""
    ),
    (
        r"""session_result_to_session_entries""",
        r"""{{ target.database }}.f1.session_result""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""one-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""stints_to_session_entries""",
        r"""{{ target.database }}.f1.stints""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""team_radio_to_session_entries""",
        r"""{{ target.database }}.f1.team_radio""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""weather_to_sessions""",
        r"""{{ target.database }}.f1.weather""",
        r"""{{ target.database }}.f1.sessions""",
        r"""many-one""",
        r"""l.session_key = r.session_key""",
        r"""Use the complete predicate; cardinality is from l to r. At most one target per source row; validated against current data."""
    ),
    (
        r"""sync_status_to_sessions""",
        r"""{{ target.database }}.f1.sync_status""",
        r"""{{ target.database }}.f1.sessions""",
        r"""many-one""",
        r"""l.session_key = r.session_key""",
        r"""Use the complete predicate; cardinality is from l to r. Optional reference: use LEFT JOIN to retain null/unmatched rows."""
    ),
    (
        r"""sync_status_to_session_entries""",
        r"""{{ target.database }}.f1.sync_status""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number""",
        r"""Use the complete predicate; cardinality is from l to r. Optional reference: use LEFT JOIN to retain null/unmatched rows."""
    ),
    (
        r"""entries_to_teams""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""{{ target.database }}.f1.teams""",
        r"""many-one""",
        r"""l.team_id = r.team_id""",
        r"""Team membership is determined by this session entry. Do not use a person-to-team mapping across the whole season."""
    ),
    (
        r"""entry_to_driver_standings""",
        r"""{{ target.database }}.f1.session_entries""",
        r"""{{ target.database }}.f1.driver_standings""",
        r"""one-one""",
        r"""l.session_key = r.session_key AND l.driver_id = r.driver_id""",
        r"""Optional one-to-one lookup for entrants. LEFT JOIN preserves entries; start from standings to retain nonparticipants. Never sum checkpoint points across sessions."""
    ),
    (
        r"""team_appearance_to_standings""",
        r"""{{ target.database }}.f1.team_sessions""",
        r"""{{ target.database }}.f1.team_standings""",
        r"""one-one""",
        r"""l.session_key = r.session_key AND l.team_id = r.team_id""",
        r"""Optional championship checkpoint for a team appearance; LEFT JOIN preserves appearances."""
    ),
    (
        r"""qualifying_to_race""",
        r"""{{ target.database }}.f1.sessions""",
        r"""{{ target.database }}.f1.sessions""",
        r"""one-one""",
        r"""l.meeting_key = r.meeting_key AND l.session_name = 'Qualifying' AND r.session_name = 'Race' AND NOT COALESCE(l.is_cancelled, FALSE) AND NOT COALESCE(r.is_cancelled, FALSE)""",
        r"""Role-playing session join: l is main Qualifying, r is main Race. Excludes Sprint Qualifying. Filter the left input to Qualifying for this path. To compare grids to results, also match grid.driver_id to the Race entry.driver_id; otherwise this path expands to all entrants."""
    ),
    (
        r"""pit_to_lap""",
        r"""{{ target.database }}.f1.pit""",
        r"""{{ target.database }}.f1.laps""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number AND l.lap_number = r.lap_number""",
        r"""Optional source lap reference; LEFT JOIN retains pit events lacking a lap. Multiple pit events can refer to one lap: lap measures would be repeated."""
    ),
    (
        r"""race_control_to_lap""",
        r"""{{ target.database }}.f1.race_control""",
        r"""{{ target.database }}.f1.laps""",
        r"""many-one""",
        r"""l.session_key = r.session_key AND l.driver_number = r.driver_number AND l.lap_number = r.lap_number""",
        r"""Optional exact driver/lap reference only. LEFT JOIN retains global or unmatched messages. Does not label every lap affected by the message."""
    ),
    (
        r"""transcript_passages_to_transcripts""",
        r"""{{ target.database }}.f1.transcript_passages""",
        r"""{{ target.database }}.f1.transcripts""",
        r"""many-one""",
        r"""l.document_id = r.document_id""",
        r"""Join active passages to active parents for metadata and citation URL."""
    ),
    (
        r"""regulation_sections_to_regulations""",
        r"""{{ target.database }}.f1.regulation_sections""",
        r"""{{ target.database }}.f1.regulations""",
        r"""many-one""",
        r"""l.document_id = r.document_id""",
        r"""Join active passages to active parents for metadata and citation URL."""
    ),
    (
        r"""glossary_sections_to_glossary""",
        r"""{{ target.database }}.f1.glossary_sections""",
        r"""{{ target.database }}.f1.glossary""",
        r"""many-one""",
        r"""l.document_id = r.document_id""",
        r"""Join active passages to active parents for metadata and citation URL."""
    ),
    (
        r"""transcripts_to_meeting""",
        r"""{{ target.database }}.f1.transcripts""",
        r"""{{ target.database }}.f1.meetings""",
        r"""many-one""",
        r"""l.meeting_key = r.meeting_key""",
        r"""LEFT JOIN preserves unmatched transcripts. This association does not resolve speakers to drivers."""
    )
])

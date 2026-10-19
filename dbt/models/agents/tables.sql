{{ config(alias='TABLES') }}

select *
from unnest(array<struct<table_name string, description string, primary_key array<string>, row_filter string>>[
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""One driver/session telemetry sample at its source timestamp. Pre/post-race samples are retained.""",
        [r"""session_key""", r"""driver_number""", r"""date"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""One source circuit. Image, information URL and locality describe the latest calendar meeting; these presentation fields are not historical versions of the circuit.""",
        [r"""circuit_key"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.countries""",
        r"""One country identified by the OpenF1 country_key. Venue geography only; driver country_code is preserved separately and may be null.""",
        [r"""country_key"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""One driver championship checkpoint per Race session, including drivers who did not enter that race. Points and positions are cumulative, not the race result. Source checkpoint snapshots may disagree with later classified results; driver checkpoint changes differ from Race result points in 23 profiled 2025 rows.""",
        [r"""session_key""", r"""driver_id"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""One person per driver_id. IDs are not guaranteed to identify the same person across spelling changes or future seasons; use session_entries to associate a person with a car number in a session.""",
        [r"""driver_id"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""One timestamped gap observation. Gap strings preserve labels such as +1 LAP.""",
        [r"""session_key""", r"""driver_number""", r"""date"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""One entry lap. Incomplete timings and JSON sector segment arrays are preserved; no inferred weather/telemetry joins.""",
        [r"""session_key""", r"""driver_number""", r"""lap_number"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""One driver/session location sample at its source timestamp. Sampling differs from car_data; no timestamp equality is assumed.""",
        [r"""session_key""", r"""driver_number""", r"""date"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""One meeting, including testing events. Geography is reached through circuit_key.""",
        [r"""meeting_key"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""One source position exchange between two session entries. Includes pit-stop and penalty changes, not exclusively on-track passes; feed may be incomplete.""",
        [r"""session_key""", r"""date""", r"""overtaking_driver_number""", r"""overtaken_driver_number"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""One pit-lane event, keyed by session, driver number and timestamp. lane_duration includes transit; pit_duration is its deprecated alias, verified equal in all profiled 2025 rows. Stationary stop_duration is available for 702 of 821 profiled 2025 events; a missing value does not establish a drive-through.""",
        [r"""session_key""", r"""driver_number""", r"""date"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.position""",
        r"""One running-order observation per driver entry and source timestamp.""",
        [r"""session_key""", r"""driver_number""", r"""date"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""One timestamped race-control message. Driver reference is optional; message_id identifies a message within a session.""",
        [r"""session_key""", r"""message_id"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""One source driver entry per session and driver number. Team membership and driver identity are explicit; no Qualifying entries are fabricated.""",
        [r"""session_key""", r"""driver_number"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""One Race result per driver entry. Finish position, race points, laps completed and DNS/DNF/DSQ indicators are preserved.""",
        [r"""session_key""", r"""driver_number"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""One scheduled session. Meeting carries year and circuit; detailed data remains restricted to selected Race sessions except grids.""",
        [r"""session_key"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""One driver grid record per main Qualifying session. Join to Race via meeting_key through sessions, never by equating Race and Qualifying keys. Preserves qualifying lap_duration.""",
        [r"""session_key""", r"""driver_id"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""One tyre stint per driver entry; lap bounds and tyre age are preserved.""",
        [r"""session_key""", r"""driver_number""", r"""stint_number"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""Data availability by endpoint and scope. Use this to distinguish unavailable detail from zero recorded events. Metadata scopes have no session; HTTP 404 means unavailable.""",
        [r"""endpoint""", r"""scope"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.team_radio""",
        r"""One radio recording per driver entry, timestamp and recording URL. Audio is referenced, not transcribed.""",
        [r"""session_key""", r"""driver_number""", r"""date""", r"""recording_url"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.team_sessions""",
        r"""One team appearance per session; preserves the source team colour as observed in that session.""",
        [r"""session_key""", r"""team_id"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""One team championship checkpoint per Race session. Source checkpoint snapshots may disagree with later classified results; driver checkpoint changes differ from Race result points in 23 profiled 2025 rows.""",
        [r"""session_key""", r"""team_id"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.teams""",
        r"""One team per team_id. Session-specific colours are in team_sessions. Team identity continuity across name changes is not guaranteed.""",
        [r"""team_id"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""One session weather observation per source timestamp. No driver reference.""",
        [r"""session_key""", r"""date"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages_search""",
        r"""One complete transcript passage with its citation URL; no fixed word limit. Choose for press-conference quotes and race context; speaker labels are not resolved driver identities. Hybrid matches are relevant evidence, not exhaustive counts. Read each full block once with chunk_index = 0.""",
        [r"""passage_id"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.regulation_passages_search""",
        r"""One complete regulation section and citation URL, bounded by numbered headings through level three and retaining page continuations. No fixed word limit. Choose for sporting/technical rules; check edition and effective dates before applying a rule. Hybrid matches are relevant evidence, not exhaustive counts. Read each full block once with chunk_index = 0.""",
        [r"""passage_id"""],
        r"""TRUE"""
    ),
    (
        r"""{{ target.database }}.f1.glossary_passages_search""",
        r"""One complete glossary passage with its citation URL; no fixed word limit. Choose for definitions and terminology; current glossary pages are not historical law. Hybrid matches are relevant evidence, not exhaustive counts. Read each full block once with chunk_index = 0.""",
        [r"""passage_id"""],
        r"""TRUE"""
    )
])

select
    driver_number,
    session_key,
    stint_number,
    compound,
    lap_end,
    lap_start,
    tyre_age_at_start,
    if(lap_end >= lap_start, lap_end - lap_start + 1, null) as reported_span_laps
from {{ source('openf1', 'stints') }}

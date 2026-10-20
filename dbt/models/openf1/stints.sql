select
    driver_number,
    session_key,
    stint_number,
    compound,
    lap_end,
    lap_start,
    tyre_age_at_start
from {{ source('openf1', 'stints') }}

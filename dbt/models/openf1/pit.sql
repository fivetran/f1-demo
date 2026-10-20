select
    date,
    driver_number,
    session_key,
    lane_duration,
    lap_number,
    pit_duration,
    stop_duration
from {{ source('openf1', 'pit') }}

select
    driver_number,
    lap_number,
    session_key,
    date_start,
    duration_sector_1,
    duration_sector_2,
    duration_sector_3,
    i_1_speed,
    i_2_speed,
    is_pit_out_lap,
    lap_duration,
    segments_sector_1,
    segments_sector_2,
    segments_sector_3,
    st_speed
from {{ source('openf1', 'laps') }}

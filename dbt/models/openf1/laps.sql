select
    source_row.`driver_number`,
    source_row.`lap_number`,
    source_row.`session_key`,
    source_row.`date_start`,
    source_row.`duration_sector_1`,
    source_row.`duration_sector_2`,
    source_row.`duration_sector_3`,
    source_row.`i_1_speed`,
    source_row.`i_2_speed`,
    source_row.`is_pit_out_lap`,
    source_row.`lap_duration`,
    source_row.`segments_sector_1`,
    source_row.`segments_sector_2`,
    source_row.`segments_sector_3`,
    source_row.`st_speed`
from {{ source('openf1', 'laps') }} as source_row

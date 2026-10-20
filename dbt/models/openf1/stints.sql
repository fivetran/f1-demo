select
    source_row.`driver_number`,
    source_row.`session_key`,
    source_row.`stint_number`,
    source_row.`compound`,
    source_row.`lap_end`,
    source_row.`lap_start`,
    source_row.`tyre_age_at_start`
from {{ source('openf1', 'stints') }} as source_row

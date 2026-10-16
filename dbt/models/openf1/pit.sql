select
    source_row.`date`,
    source_row.`driver_number`,
    source_row.`session_key`,
    source_row.`lane_duration`,
    source_row.`lap_number`,
    source_row.`pit_duration`,
    source_row.`stop_duration`
from {{ source('openf1', 'pit') }} as source_row
where not coalesce(source_row._fivetran_deleted, false)

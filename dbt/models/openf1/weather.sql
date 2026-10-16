select
    source_row.`date`,
    source_row.`session_key`,
    source_row.`air_temperature`,
    source_row.`humidity`,
    source_row.`pressure`,
    source_row.`rainfall`,
    source_row.`track_temperature`,
    source_row.`wind_direction`,
    source_row.`wind_speed`
from {{ source('openf1', 'weather') }} as source_row
where not coalesce(source_row._fivetran_deleted, false)

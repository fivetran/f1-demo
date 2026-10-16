select
    source_row.`date`,
    source_row.`overtaken_driver_number`,
    source_row.`overtaking_driver_number`,
    source_row.`session_key`,
    source_row.`position`
from {{ source('openf1', 'overtakes') }} as source_row
where not coalesce(source_row._fivetran_deleted, false)

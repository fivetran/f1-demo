{{ config(partition_by={'field': 'date', 'data_type': 'timestamp', 'granularity': 'day'}, cluster_by=['session_key', 'driver_number']) }}

select
    source_row.`date`,
    source_row.`driver_number`,
    source_row.`session_key`,
    source_row.`x`,
    source_row.`y`,
    source_row.`z`
from {{ source('openf1', 'location') }} as source_row
where not coalesce(source_row._fivetran_deleted, false)

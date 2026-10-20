{{ config(partition_by={'field': 'date', 'data_type': 'timestamp', 'granularity': 'day'}, cluster_by=['session_key', 'driver_number']) }}

select
    source_row.`date`,
    source_row.`driver_number`,
    source_row.`session_key`,
    source_row.`position`
from {{ source('openf1', 'position') }} as source_row

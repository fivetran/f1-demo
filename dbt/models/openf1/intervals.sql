{{ config(partition_by={'field': 'date', 'data_type': 'timestamp', 'granularity': 'day'}, cluster_by=['session_key', 'driver_number']) }}

select
    source_row.`date`,
    source_row.`driver_number`,
    source_row.`session_key`,
    source_row.`gap_to_leader`,
    source_row.`interval`
from {{ source('openf1', 'intervals') }} as source_row

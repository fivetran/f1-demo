{{ config(partition_by={'field': 'date', 'data_type': 'timestamp', 'granularity': 'day'}, cluster_by=['session_key', 'driver_number']) }}

select
    source_row.`date`,
    source_row.`driver_number`,
    source_row.`session_key`,
    source_row.`brake`,
    source_row.`drs`,
    source_row.`n_gear`,
    source_row.`rpm`,
    source_row.`speed`,
    source_row.`throttle`
from {{ source('openf1', 'car_data') }} as source_row

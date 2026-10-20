{{ config(partition_by={'field': 'date', 'data_type': 'timestamp', 'granularity': 'day'}, cluster_by=['session_key', 'driver_number']) }}

select
    date,
    driver_number,
    session_key,
    x,
    y,
    z
from {{ source('openf1', 'location') }}

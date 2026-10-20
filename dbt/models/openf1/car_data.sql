{{ config(partition_by={'field': 'date', 'data_type': 'timestamp', 'granularity': 'day'}, cluster_by=['session_key', 'driver_number']) }}

select
    date,
    driver_number,
    session_key,
    brake,
    drs,
    n_gear,
    rpm,
    speed,
    throttle
from {{ source('openf1', 'car_data') }}

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
    throttle,
    case brake when 0 then false when 100 then true end as is_braking,
    if(throttle between 0 and 100, throttle, null) as throttle_pct,
    n_gear between 0 and 8 as is_known_gear
from {{ source('openf1', 'car_data') }}

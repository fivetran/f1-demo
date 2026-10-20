{{ config(partition_by={'field': 'date', 'data_type': 'timestamp', 'granularity': 'day'}, cluster_by=['session_key', 'driver_number']) }}

select
    date,
    driver_number,
    session_key,
    gap_to_leader,
    `interval`,
    safe_cast(`interval` as float64) as interval_seconds,
    safe_cast(gap_to_leader as float64) as gap_to_leader_seconds
from {{ source('openf1', 'intervals') }}

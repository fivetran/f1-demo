select
    date,
    overtaken_driver_number,
    overtaking_driver_number,
    session_key,
    position
from {{ source('openf1', 'overtakes') }}

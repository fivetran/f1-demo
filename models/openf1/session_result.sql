select
    driver_number,
    session_key,
    dnf,
    dns,
    dsq,
    duration,
    gap_to_leader,
    number_of_laps,
    position,
    points
from {{ source('openf1', 'session_result') }}

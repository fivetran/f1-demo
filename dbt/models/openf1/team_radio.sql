select
    date,
    driver_number,
    recording_url,
    session_key
from {{ source('openf1', 'team_radio') }}

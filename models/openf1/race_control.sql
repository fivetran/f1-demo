select
    message_id,
    session_key,
    category,
    date,
    driver_number,
    flag,
    lap_number,
    message,
    qualifying_phase,
    scope,
    sector
from {{ source('openf1', 'race_control') }}

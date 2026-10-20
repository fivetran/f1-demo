select
    date,
    session_key,
    air_temperature,
    humidity,
    pressure,
    rainfall,
    track_temperature,
    wind_direction,
    wind_speed
from {{ source('openf1', 'weather') }}

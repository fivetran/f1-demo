select
    fact.session_key,
    identity.driver_id,
    fact.lap_duration,
    fact.position
from {{ source('openf1', 'starting_grid') }} as fact
left join {{ source('openf1', 'sessions') }} as s on fact.session_key = s.session_key
left join {{ ref('driver_identity_map') }} as identity
    on s.year = identity.season and fact.driver_number = identity.driver_number

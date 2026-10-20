select fact.session_key, identity.driver_id,
    fact.points_current, fact.points_start, fact.position_current, fact.position_start
from {{ source('openf1', 'championship_drivers') }} as fact
left join {{ source('openf1', 'sessions') }} as s on fact.session_key = s.session_key
left join {{ ref('driver_identity_map') }} as identity
    on s.year = identity.season and fact.driver_number = identity.driver_number

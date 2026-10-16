select d.session_key, d.driver_number, driver_identity.driver_id, team_identity.team_id
from {{ source('openf1', 'drivers') }} as d
left join {{ source('openf1', 'sessions') }} as s on d.session_key = s.session_key and not coalesce(s._fivetran_deleted, false)
left join {{ ref('driver_identity_map') }} as driver_identity
    on s.year = driver_identity.season and d.driver_number = driver_identity.driver_number
left join {{ ref('team_identity_map') }} as team_identity
    on s.year = team_identity.season and d.team_name = team_identity.source_team_name
where not coalesce(d._fivetran_deleted, false)

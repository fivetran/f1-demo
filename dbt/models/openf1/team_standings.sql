select fact.session_key, identity.team_id,
    fact.points_current, fact.points_start, fact.position_current, fact.position_start
from {{ source('openf1', 'championship_teams') }} as fact
left join {{ source('openf1', 'sessions') }} as s on fact.session_key = s.session_key and not coalesce(s._fivetran_deleted, false)
left join {{ ref('team_identity_map') }} as identity
    on s.year = identity.season and fact.team_name = identity.source_team_name
where not coalesce(fact._fivetran_deleted, false)

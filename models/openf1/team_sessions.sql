-- Colour varies across sessions, but agrees across teammates within each session.
select distinct d.session_key, identity.team_id, d.team_colour
from {{ source('openf1', 'drivers') }} as d
left join {{ source('openf1', 'sessions') }} as s on d.session_key = s.session_key
left join {{ ref('team_identity_map') }} as identity
    on s.year = identity.season and d.team_name = identity.source_team_name

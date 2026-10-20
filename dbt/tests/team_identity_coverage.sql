with source_teams as (
    select session_key, team_name from {{ source('openf1', 'drivers') }}

    union distinct
    select session_key, team_name from {{ source('openf1', 'championship_teams') }}

)
select d.*
from source_teams as d
left join {{ source('openf1', 'sessions') }} as s
    on d.session_key = s.session_key
left join {{ ref('team_identity_map') }} as identity
    on s.year = identity.season and d.team_name = identity.source_team_name
where identity.team_id is null

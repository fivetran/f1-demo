-- Include standings-only teams; a team need not have an entry in that session.
with source_teams as (
    select d.session_key, d.team_name
    from {{ source('openf1', 'drivers') }} as d

    union distinct
    select standing.session_key, standing.team_name
    from {{ source('openf1', 'championship_teams') }} as standing

)
select distinct
    s.year as season,
    source_team.team_name as source_team_name,
    case when nullif(trim(source_team.team_name), '') is not null
        then concat('team_', trim(regexp_replace(
            lower(source_team.team_name), r'[^a-z0-9]+', '_'
        ), '_'))
    end as team_id,
    source_team.team_name
from source_teams as source_team
left join {{ source('openf1', 'sessions') }} as s
    on source_team.session_key = s.session_key

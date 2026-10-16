-- Names remain identity checks; headshots are presentation metadata that changes.
-- Use the latest non-null photo by session time across the loaded seasons.
select distinct
    identity.driver_id,
    d.broadcast_name, d.country_code, d.first_name, d.full_name,
    first_value(d.headshot_url ignore nulls) over (
        partition by identity.driver_id order by s.date_start desc, s.session_key desc
        rows between unbounded preceding and unbounded following
    ) as headshot_url,
    d.last_name, d.name_acronym
from {{ source('openf1', 'drivers') }} as d
left join {{ source('openf1', 'sessions') }} as s on d.session_key = s.session_key and not coalesce(s._fivetran_deleted, false)
left join {{ ref('driver_identity_map') }} as identity
    on s.year = identity.season and d.driver_number = identity.driver_number
where not coalesce(d._fivetran_deleted, false)

-- Every active entry must resolve to the same source name through the computed lookup.
select d.session_key, d.driver_number, d.full_name, identity.source_full_name
from {{ source('openf1', 'drivers') }} as d
left join {{ source('openf1', 'sessions') }} as s
    on d.session_key = s.session_key and not coalesce(s._fivetran_deleted, false)
left join {{ ref('driver_identity_map') }} as identity
    on s.year = identity.season and d.driver_number = identity.driver_number
where not coalesce(d._fivetran_deleted, false)
  and (identity.driver_id is null or d.full_name is distinct from identity.source_full_name)

-- Names identify people only within the supported source data, not permanently.
-- Conflicting names/numbers or slug collisions fail the identity/profile tests.
select distinct
    s.year as season,
    d.driver_number,
    d.full_name as source_full_name,
    case
        when nullif(trim(d.first_name), '') is not null
         and nullif(trim(d.last_name), '') is not null
        then concat('drv_', trim(regexp_replace(
            lower(concat(d.first_name, '_', d.last_name)), r'[^a-z0-9]+', '_'
        ), '_'))
    end as driver_id
from {{ source('openf1', 'drivers') }} as d
left join {{ source('openf1', 'sessions') }} as s
    on d.session_key = s.session_key

-- Circuit URLs are season-specific; locality labels also change between calendars.
-- Present the newest calendar's descriptive fields, while retaining identity conflicts.
with profiles as (
    select
        *,
        first_value(struct(circuit_image, circuit_info_url, location)) over (
            partition by circuit_key
            order by date_start desc, meeting_key desc
        ) as presentation
    from {{ source('openf1', 'meetings') }}
)
select distinct
    circuit_key,
    country_key,
    circuit_short_name,
    circuit_type,
    presentation.circuit_image,
    presentation.circuit_info_url,
    presentation.location
from profiles

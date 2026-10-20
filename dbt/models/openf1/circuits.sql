-- Circuit URLs are season-specific; locality labels also change between calendars.
-- Present the newest calendar's descriptive fields, while retaining identity conflicts.
with profiles as (
    select source_row.*,
        first_value(struct(source_row.circuit_image, source_row.circuit_info_url, source_row.location)) over (
            partition by source_row.circuit_key
            order by source_row.date_start desc, source_row.meeting_key desc
        ) as presentation
    from {{ source('openf1', 'meetings') }} as source_row

)
select distinct
    circuit_key, country_key, circuit_short_name, circuit_type,
    presentation.circuit_image, presentation.circuit_info_url, presentation.location
from profiles

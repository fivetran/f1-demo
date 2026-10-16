select distinct
    source_row.`country_key`,
    source_row.`country_code`,
    source_row.`country_name`,
    source_row.`country_flag`
from {{ source('openf1', 'meetings') }} as source_row
where not coalesce(source_row._fivetran_deleted, false)

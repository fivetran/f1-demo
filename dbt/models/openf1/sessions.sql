select
    source_row.`session_key`,
    source_row.`meeting_key`,
    source_row.`session_name`,
    source_row.`session_type`,
    source_row.`date_start`,
    source_row.`date_end`,
    source_row.`gmt_offset`,
    source_row.`is_cancelled`
from {{ source('openf1', 'sessions') }} as source_row

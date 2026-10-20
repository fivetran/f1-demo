select
    source_row.`meeting_key`,
    source_row.`circuit_key`,
    source_row.`meeting_name`,
    source_row.`meeting_official_name`,
    source_row.`year`,
    source_row.`date_start`,
    source_row.`date_end`,
    source_row.`gmt_offset`,
    source_row.`is_cancelled`
from {{ source('openf1', 'meetings') }} as source_row

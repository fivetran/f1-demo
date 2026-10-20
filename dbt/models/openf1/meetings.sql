select
    meeting_key,
    circuit_key,
    meeting_name,
    meeting_official_name,
    year,
    date_start,
    date_end,
    gmt_offset,
    is_cancelled
from {{ source('openf1', 'meetings') }}

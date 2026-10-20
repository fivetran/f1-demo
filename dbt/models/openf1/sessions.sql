select
    session_key,
    meeting_key,
    session_name,
    session_type,
    date_start,
    date_end,
    gmt_offset,
    is_cancelled
from {{ source('openf1', 'sessions') }}

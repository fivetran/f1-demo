select
    endpoint,
    scope,
    session_key,
    driver_number,
    status,
    row_count,
    completed_at
from {{ source('openf1', 'sync_status') }}

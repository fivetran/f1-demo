select
    source_row.`endpoint`,
    source_row.`scope`,
    source_row.`session_key`,
    source_row.`driver_number`,
    source_row.`status`,
    source_row.`row_count`,
    source_row.`completed_at`
from {{ source('openf1', 'sync_status') }} as source_row

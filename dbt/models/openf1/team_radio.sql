select
    source_row.`date`,
    source_row.`driver_number`,
    source_row.`recording_url`,
    source_row.`session_key`
from {{ source('openf1', 'team_radio') }} as source_row

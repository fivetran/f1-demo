select
    source_row.`driver_number`,
    source_row.`session_key`,
    source_row.`dnf`,
    source_row.`dns`,
    source_row.`dsq`,
    source_row.`duration`,
    source_row.`gap_to_leader`,
    source_row.`number_of_laps`,
    source_row.`position`,
    source_row.`points`
from {{ source('openf1', 'session_result') }} as source_row

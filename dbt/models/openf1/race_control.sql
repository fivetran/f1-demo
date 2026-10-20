select
    source_row.`message_id`,
    source_row.`session_key`,
    source_row.`category`,
    source_row.`date`,
    source_row.`driver_number`,
    source_row.`flag`,
    source_row.`lap_number`,
    source_row.`message`,
    source_row.`qualifying_phase`,
    source_row.`scope`,
    source_row.`sector`
from {{ source('openf1', 'race_control') }} as source_row

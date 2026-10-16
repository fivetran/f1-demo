select distinct team_id, team_name
from {{ ref('team_identity_map') }}

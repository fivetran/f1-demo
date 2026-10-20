select distinct
    country_key,
    country_code,
    country_name,
    country_flag
from {{ source('openf1', 'meetings') }}

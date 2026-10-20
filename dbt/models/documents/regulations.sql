{{ config(materialized='table') }}

select
    document_id,
    source_url,
    title,
    published_at,
    applicable_season,
    rule_family,
    applicability_status,
    effective_from,
    effective_to
from {{ source('documents', 'regulations') }}

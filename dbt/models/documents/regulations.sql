{{ config(materialized='table') }}

select
    s.document_id,
    s.source_url,
    s.title,
    s.published_at,
    s.applicable_season,
    s.rule_family,
    s.applicability_status,
    s.effective_from,
    s.effective_to
from {{ source('documents', 'regulations') }} s
where not coalesce(s._fivetran_deleted, false)

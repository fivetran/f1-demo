{{ config(materialized='table') }}

select
    s.document_id,
    s.source_url,
    s.title,
    s.published_at,
    s.meeting_key,
    s.conference_type,
    s.association_method
from {{ source('documents', 'transcripts') }} s
where not coalesce(s._fivetran_deleted, false)

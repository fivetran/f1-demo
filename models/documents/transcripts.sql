{{ config(materialized='table') }}

select
    document_id,
    source_url,
    title,
    published_at,
    meeting_key,
    conference_type,
    association_method
from {{ source('documents', 'transcripts') }}

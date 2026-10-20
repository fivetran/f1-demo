{{ config(materialized='table') }}

select
    s.document_id,
    s.source_url,
    s.title,
    s.applicability_status
from {{ source('documents', 'glossary') }} s

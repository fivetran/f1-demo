{{ config(materialized='table') }}

select
    document_id,
    source_url,
    title,
    applicability_status
from {{ source('documents', 'glossary') }}

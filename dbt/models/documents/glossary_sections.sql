{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['document_id', 'position'],
    on_schema_change='append_new_columns',
    full_refresh=false,
    post_hook='{{ ensure_document_index() }}'
) }}

select
    s.document_id,
    s.position,
    s.text,
    s.section,
    s._fivetran_synced,
    {{ function('embed_text') }}(s.text) as embedding
from {{ source('documents', 'glossary_sections') }} s

{% if is_incremental() %}
where s._fivetran_synced > (
      select coalesce(max(t._fivetran_synced), timestamp('1970-01-01'))
      from {{ this }} t
  )
{% endif %}

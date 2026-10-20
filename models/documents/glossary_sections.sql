{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['document_id', 'position'],
    on_schema_change='append_new_columns',
    full_refresh=false,
    post_hook='{{ ensure_document_index() }}'
) }}

select
    document_id,
    position,
    text,
    section,
    _fivetran_synced,
    {{ function('embed_text') }}(text) as embedding
from {{ source('documents', 'glossary_sections') }}

{% if is_incremental() %}
where _fivetran_synced > (
    select coalesce(max(_fivetran_synced), timestamp('1970-01-01'))
    from {{ this }}
)
{% endif %}

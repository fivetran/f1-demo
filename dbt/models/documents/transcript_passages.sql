{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['document_id', 'position'],
    on_schema_change='append_new_columns',
    full_refresh=false,
    post_hook=[
        '{{ prune_document_passages("transcript_passages") }}',
        '{{ ensure_document_index() }}'
    ]
) }}

select
    s.document_id,
    s.position,
    s.text,
    s.question,
    s.speaker,
    s.section
from {{ source('documents', 'transcript_passages') }} s
{% if is_incremental() %}
left join {{ this }} t on s.document_id = t.document_id and s.position = t.position
{% endif %}
where not coalesce(s._fivetran_deleted, false)
{% if is_incremental() %}
  and (t.document_id is null
       or s.text is distinct from t.text
       or s.question is distinct from t.question
       or s.speaker is distinct from t.speaker
       or s.section is distinct from t.section)
{% endif %}

{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='passage_id',
    on_schema_change='append_new_columns',
    full_refresh=false,
    cluster_by=['document_type', 'document_id', 'meeting_key'],
    post_hook=[
        '{{ prune_document_search() }}',
        '{{ ensure_document_embedding() }}',
        '{{ ensure_document_hybrid_index() }}'
    ]
) }}

-- append_new_columns makes the MERGE use input columns only, excluding the
-- generated embedding column. sync_all_columns would drop it; ignore would
-- try to write it. A full refresh is disabled to preserve managed embeddings.
select s.*
from {{ ref('document_search_input') }} as s
{% if is_incremental() %}
left join {{ this }} as t on s.passage_id = t.passage_id
where t.passage_id is null or s.content_hash is distinct from t.content_hash
{% endif %}

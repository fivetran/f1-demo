{% macro document_search_source(kind, sections, parents) %}
select
    '{{ kind }}' as document_type,
    s.document_id,
    s.position as source_position,
    s.text,
    s.question,
    s.speaker as speaker_label,
    s.section,
    s.page_number,
    p.title,
    p.source_url,
    p.published_at,
    {% if kind == 'transcript' %}
    p.meeting_key, p.race_name, p.conference_type, p.association_method,
    cast(null as int64) as applicable_season,
    cast(null as string) as rule_family,
    cast(null as string) as applicability_status,
    cast(null as string) as effective_from,
    cast(null as string) as effective_to,
    {% else %}
    cast(null as int64) as meeting_key,
    cast(null as string) as race_name,
    cast(null as string) as conference_type,
    cast(null as string) as association_method,
    {% if kind == 'regulation' %}
    p.applicable_season, p.rule_family, p.applicability_status,
    p.effective_from, p.effective_to,
    {% else %}
    cast(null as int64) as applicable_season,
    cast(null as string) as rule_family,
    p.applicability_status,
    cast(null as string) as effective_from,
    cast(null as string) as effective_to,
    {% endif %}
    {% endif %}
    {% if kind == 'glossary' %}
    lag(s.text) over (partition by s.document_id order by s.position) as previous_text,
    lead(s.text) over (partition by s.document_id order by s.position) as next_text
    {% else %}
    cast(null as string) as previous_text,
    cast(null as string) as next_text
    {% endif %}
from {{ source('documents', sections) }} as s
join {{ source('documents', parents) }} as p on s.document_id = p.document_id
where not coalesce(s._fivetran_deleted, false)
  and not coalesce(p._fivetran_deleted, false)
{% endmacro %}

{% macro ensure_document_embedding() %}
    if not exists (
        select 1 from `{{ this.database }}.{{ this.schema }}.INFORMATION_SCHEMA.COLUMNS`
        where table_name = '{{ this.identifier }}' and column_name = 'embedding'
    ) then
    -- Fail synchronously if IAM has not propagated; otherwise a background job
    -- can stall with every embedding still NULL and no per-row error status.
    assert (select e.status = '' from (
        select ai.embed('Formula 1',
            connection_id => '{{ target.database }}.us.f1_document_embeddings',
            endpoint => 'text-embedding-005') as e
    )) as 'Embedding connection is not ready; verify IAM and retry';
    alter table {{ this }} add column if not exists embedding
        struct<result array<float64>, status string>
        generated always as (
            ai.embed(embedding_text,
                connection_id => '{{ target.database }}.us.f1_document_embeddings',
                endpoint => 'text-embedding-005')
        ) stored options (asynchronous = true);
    end if;
{% endmacro %}

{% macro create_document_embedding_connection() %}
    {% if target.schema != 'f1' or target.database != env_var('F1_GCP_PROJECT') %}
        {{ exceptions.raise_compiler_error('Document search must target the F1 project and f1 dataset') }}
    {% endif %}
    {% do run_query('create connection if not exists `' ~ target.database ~ '.us.f1_document_embeddings` options (connection_type="CLOUD_RESOURCE", friendly_name="F1 document embeddings")') %}
{% endmacro %}

{% macro prune_document_search() %}
    delete from {{ this }} as t
    where not exists (
        select 1 from {{ ref('document_search_input') }} as s
        where s.passage_id = t.passage_id
    )
{% endmacro %}

{% macro ensure_document_hybrid_index() %}
    create vector index if not exists document_passages_hybrid
    on {{ this }} (embedding)
    storing (embedding_text, document_type, document_id, source_position,
             meeting_key, conference_type, speaker_label, rule_family, applicable_season)
    options (index_type = 'IVF', distance_type = 'COSINE',
             lexical_search_columns = ['embedding_text']);
{% endmacro %}

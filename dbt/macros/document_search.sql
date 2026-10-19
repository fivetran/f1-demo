{% macro ensure_document_embedding() %}
    -- Gemini Embedding 2 defaults to 3072 dimensions. Pass the full input:
    -- API truncation affects the vector only, never the stored passage.
    -- Existing generated columns require the explicit reset operation below.
    if not exists (
        select 1 from `{{ this.database }}.{{ this.schema }}.INFORMATION_SCHEMA.COLUMNS`
        where table_name = '{{ this.identifier }}' and column_name = 'embedding'
    ) then
    -- Fail synchronously if IAM has not propagated; otherwise a background job
    -- can stall with every embedding still NULL and no per-row error status.
    assert (select e.status = '' from (
        select ai.embed('Formula 1',
            connection_id => '{{ target.database }}.us.f1_document_embeddings',
            endpoint => 'gemini-embedding-2') as e
    )) as 'Embedding connection is not ready; verify IAM and retry';
    alter table {{ this }} add column if not exists embedding
        struct<result array<float64>, status string>
        generated always as (
            ai.embed(embedding_text,
                connection_id => '{{ target.database }}.us.f1_document_embeddings',
                endpoint => 'gemini-embedding-2')
        ) stored options (asynchronous = true);
    end if;
{% endmacro %}

{% macro reset_document_embeddings() %}
    {# Explicit one-time migration: keep passage rows, regenerate vectors/indexes on the next build. #}
    {% if target.schema != 'f1' or target.database != env_var('F1_GCP_PROJECT') %}
        {{ exceptions.raise_compiler_error('Embedding migration must target the F1 project and f1 dataset') }}
    {% endif %}
    {% do run_query("assert (select e.status = '' and array_length(e.result) = 3072 from (select ai.embed('Formula 1', connection_id => '" ~ target.database ~ ".us.f1_document_embeddings', endpoint => 'gemini-embedding-2') as e)) as 'Gemini Embedding 2 is not ready'") %}
    {% for kind in ['transcript', 'regulation', 'glossary'] %}
        {% set relation = ref(kind ~ '_passages_search') %}
        {% do run_query('drop vector index if exists ' ~ kind ~ '_passages_hybrid on ' ~ relation) %}
        {% do run_query('alter table ' ~ relation ~ ' drop column if exists embedding') %}
    {% endfor %}
{% endmacro %}

{% macro create_document_embedding_connection() %}
    {% if target.schema != 'f1' or target.database != env_var('F1_GCP_PROJECT') %}
        {{ exceptions.raise_compiler_error('Document search must target the F1 project and f1 dataset') }}
    {% endif %}
    {% do run_query('create connection if not exists `' ~ target.database ~ '.us.f1_document_embeddings` options (connection_type="CLOUD_RESOURCE", friendly_name="F1 document embeddings")') %}
{% endmacro %}

{% macro prune_document_search(input_model) %}
    delete from {{ this }} as t
    where not exists (
        select 1 from {{ ref(input_model) }} as s
        where s.passage_id = t.passage_id
    )
{% endmacro %}

{% macro ensure_document_hybrid_index(kind) %}
    -- Small sources support hybrid search without an index.
    if (select count(*) from {{ this }}) >= 5000 then
    create vector index if not exists {{ kind }}_passages_hybrid
    on {{ this }} (embedding)
    storing (embedding_text, document_id, source_position, speaker_label
             {% if kind == 'transcript' %}, meeting_key, conference_type
             {% elif kind == 'regulation' %}, rule_family, applicable_season
             {% endif %})
    options (index_type = 'IVF', distance_type = 'COSINE',
             lexical_search_columns = ['embedding_text']);
    end if;
{% endmacro %}

{% macro ensure_document_index() %}
    -- Generated STRUCT columns belong on dbt copies: Fivetran rejects them on sources.
    if not exists (
        select 1 from `{{ this.database }}.{{ this.schema }}.INFORMATION_SCHEMA.COLUMNS`
        where table_name = '{{ this.identifier }}' and column_name = 'embedding'
    ) then
        alter table {{ this }} add column embedding
            struct<result array<float64>, status string>
            generated always as (
                ai.embed(text,
                    connection_id => '{{ target.database }}.us.f1_document_embeddings',
                    endpoint => 'gemini-embedding-2')
            ) stored options (asynchronous = true);
    end if;
    if (select count(*) from {{ this }}) >= 5000 then
        create vector index if not exists {{ this.identifier }}_hybrid
        on {{ this }} (embedding)
        storing (text, document_id, position)
        options (index_type = 'IVF', distance_type = 'COSINE',
                 lexical_search_columns = ['text']);
    end if;
{% endmacro %}

{% macro prune_document_passages(source_table) %}
    delete from {{ this }} t
    where not exists (
        select 1 from {{ source('documents', source_table) }} s
        where not coalesce(s._fivetran_deleted, false)
          and s.document_id = t.document_id and s.position = t.position
    )
{% endmacro %}

{% macro create_document_embedding_connection() %}
    {% if target.schema != 'f1' or target.database != env_var('F1_GCP_PROJECT') %}
        {{ exceptions.raise_compiler_error('Document search must target the F1 project') }}
    {% endif %}
    {% do run_query('create connection if not exists `' ~ target.database ~ '.us.f1_document_embeddings` options (connection_type="CLOUD_RESOURCE", friendly_name="F1 document embeddings")') %}
{% endmacro %}

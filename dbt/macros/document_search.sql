{% macro ensure_document_indexes() %}
    {# Idempotent DDL only. Fivetran owns the rows; BigQuery maintains embeddings. #}
    {% if target.schema != 'f1' or target.database != env_var('F1_GCP_PROJECT') %}
        {{ exceptions.raise_compiler_error('Document search must target the F1 project') }}
    {% endif %}
    {% for table in ['transcript_passages', 'regulation_sections', 'glossary_sections'] %}
        {% set relation = '`' ~ target.database ~ '.f1_documents.' ~ table ~ '`' %}
        {% set ddl %}
        if not exists (
            select 1 from `{{ target.database }}.f1_documents.INFORMATION_SCHEMA.COLUMNS`
            where table_name = '{{ table }}' and column_name = 'embedding'
        ) then
        alter table {{ relation }} add column if not exists embedding
            struct<result array<float64>, status string>
            generated always as (
                ai.embed(text,
                    connection_id => '{{ target.database }}.us.f1_document_embeddings',
                    endpoint => 'gemini-embedding-2')
            ) stored options (asynchronous = true);
        end if;
        if (select count(*) from {{ relation }}) >= 5000 then
            create vector index if not exists {{ table }}_hybrid
            on {{ relation }} (embedding)
            storing (text, document_id, position, _fivetran_deleted)
            options (index_type = 'IVF', distance_type = 'COSINE',
                     lexical_search_columns = ['text']);
        end if;
        {% endset %}
        {% do run_query(ddl) %}
    {% endfor %}
{% endmacro %}

{% macro create_document_embedding_connection() %}
    {% if target.schema != 'f1' or target.database != env_var('F1_GCP_PROJECT') %}
        {{ exceptions.raise_compiler_error('Document search must target the F1 project') }}
    {% endif %}
    {% do run_query('create connection if not exists `' ~ target.database ~ '.us.f1_document_embeddings` options (connection_type="CLOUD_RESOURCE", friendly_name="F1 document embeddings")') %}
{% endmacro %}

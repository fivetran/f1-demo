{% macro ensure_document_index() %}
    if (select count(*) from {{ this }}) >= 5000 then
        create vector index if not exists {{ this.identifier }}_hybrid
        on {{ this }} (embedding)
        storing (text, document_id, position)
        options (index_type = 'IVF', distance_type = 'COSINE',
                 lexical_search_columns = ['text']);
    end if;
{% endmacro %}

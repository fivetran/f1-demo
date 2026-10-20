{{ config(tags=['document_search']) }}

{% for name in ['transcript_passages', 'regulation_sections', 'glossary_sections'] %}
select '{{ name }}' as collection, coalesce(s.document_id, t.document_id) as document_id,
       coalesce(s.position, t.position) as position
from (
    select s.document_id, s.position, s.text
    from {{ source('documents', name) }} s
    where not coalesce(s._fivetran_deleted, false)
) s
full outer join {{ ref(name) }} t
    on s.document_id = t.document_id and s.position = t.position
where s.document_id is null or t.document_id is null or s.text is distinct from t.text
{% if not loop.last %}union all{% endif %}
{% endfor %}

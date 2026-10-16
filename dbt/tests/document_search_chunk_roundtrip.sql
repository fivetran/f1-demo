{{ config(tags=['document_search']) }}
with original as (
    select * from {{ ref('transcript_search_source') }}
    union all
    select * from {{ ref('regulation_search_source') }}
    union all
    select * from {{ ref('glossary_search_source') }}
), reconstructed as (
    select s.document_type, s.document_id, s.source_position,
        string_agg(s.chunk_text, '' order by s.chunk_index) as rebuilt_text
    from {{ ref('document_passages_search') }} as s
    group by 1, 2, 3
)
select o.document_type, o.document_id, o.source_position
from original as o
full outer join reconstructed as r
    using (document_type, document_id, source_position)
where o.text is distinct from r.rebuilt_text

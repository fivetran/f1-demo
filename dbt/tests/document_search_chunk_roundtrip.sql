{{ config(tags=['document_search']) }}
with original as (
    {{ document_search_source('transcript', 'transcript_passages', 'transcripts') }}
    union all
    {{ document_search_source('regulation', 'regulation_sections', 'regulations') }}
    union all
    {{ document_search_source('glossary', 'glossary_sections', 'glossary') }}
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

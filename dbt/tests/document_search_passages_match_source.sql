{{ config(tags=['document_search']) }}
with original as (
    select 'transcript' as document_type, s.document_id, s.position as source_position, s.text
    from {{ source('documents', 'transcript_passages') }} as s
    join {{ source('documents', 'transcripts') }} as p on s.document_id = p.document_id
    where not coalesce(s._fivetran_deleted, false)
      and not coalesce(p._fivetran_deleted, false)
    union all
    select 'regulation' as document_type, s.document_id, s.position as source_position, s.text
    from {{ source('documents', 'regulation_sections') }} as s
    join {{ source('documents', 'regulations') }} as p on s.document_id = p.document_id
    where not coalesce(s._fivetran_deleted, false)
      and not coalesce(p._fivetran_deleted, false)
    union all
    select 'glossary' as document_type, s.document_id, s.position as source_position, s.text
    from {{ source('documents', 'glossary_sections') }} as s
    join {{ source('documents', 'glossary') }} as p on s.document_id = p.document_id
    where not coalesce(s._fivetran_deleted, false)
      and not coalesce(p._fivetran_deleted, false)
), searchable as (
    select document_type, document_id, source_position, text
    from {{ ref('transcript_passages_search') }}
    union all
    select document_type, document_id, source_position, text
    from {{ ref('regulation_passages_search') }}
    union all
    select document_type, document_id, source_position, text
    from {{ ref('glossary_passages_search') }}
)
select o.document_type, o.document_id, o.source_position
from original as o
full outer join searchable as s
    using (document_type, document_id, source_position)
where o.text is distinct from s.text

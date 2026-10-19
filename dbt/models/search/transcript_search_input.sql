{{ config(materialized='view') }}

with passages as (
    select
        'transcript' as document_type,
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
        p.meeting_key, p.race_name, p.conference_type, p.association_method,
        cast(null as string) as previous_text,
        cast(null as string) as next_text
    from {{ source('documents', 'transcript_passages') }} as s
    join {{ source('documents', 'transcripts') }} as p on s.document_id = p.document_id
    where not coalesce(s._fivetran_deleted, false)
      and not coalesce(p._fivetran_deleted, false)
), chunks as (
    -- Keep the connector's full passage. The embedding API handles overflow.
    select p.*, p.text as chunk_text, 0 as chunk_index
    from passages as p
), contextualized as (
    select c.* except(previous_text, next_text),
        to_hex(sha256(to_json_string(struct(
            c.document_type, c.document_id, c.source_position, c.chunk_index
        )))) as passage_id,
        array_to_string([
            concat('Title: ', left(c.title, 240)),
            concat('Section: ', left(c.section, 160)),
            concat('Speaker label: ', left(c.speaker_label, 80)),
            concat('Question: ', left(c.question, 600)),
            concat('Previous glossary block: ', left(c.previous_text, 600)),
            concat('Passage: ', c.chunk_text),
            concat('Next glossary block: ', left(c.next_text, 600))
        ], '\n') as embedding_text
    from chunks as c
)
select c.*, to_hex(sha256(to_json_string(c))) as content_hash
from contextualized as c

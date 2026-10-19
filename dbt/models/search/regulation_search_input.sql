{{ config(materialized='view') }}

with passages as (
    select
        'regulation' as document_type,
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
        p.applicable_season, p.rule_family, p.applicability_status,
        p.effective_from, p.effective_to,
        cast(null as string) as previous_text,
        cast(null as string) as next_text
    from {{ source('documents', 'regulation_sections') }} as s
    join {{ source('documents', 'regulations') }} as p on s.document_id = p.document_id
    where not coalesce(s._fivetran_deleted, false)
      and not coalesce(p._fivetran_deleted, false)
), contextualized as (
    select c.* except(previous_text, next_text),
        to_hex(sha256(to_json_string(struct(
            c.document_type, c.document_id, c.source_position
        )))) as passage_id,
        array_to_string([
            concat('Title: ', left(c.title, 240)),
            concat('Section: ', left(c.section, 160)),
            concat('Speaker label: ', left(c.speaker_label, 80)),
            concat('Question: ', left(c.question, 600)),
            concat('Previous glossary block: ', left(c.previous_text, 600)),
            concat('Passage: ', c.text),
            concat('Next glossary block: ', left(c.next_text, 600))
        ], '\n') as embedding_text
    from passages as c
)
select c.*, to_hex(sha256(to_json_string(c))) as content_hash
from contextualized as c

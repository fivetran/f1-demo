{{ config(materialized='view') }}

with passages as (
    {{ document_search_source('transcript', 'transcript_passages', 'transcripts') }}
    union all
    {{ document_search_source('regulation', 'regulation_sections', 'regulations') }}
    union all
    {{ document_search_source('glossary', 'glossary_sections', 'glossary') }}
), chunks as (
    select p.*, chunk.chunk_text, chunk.chunk_index
    from passages as p,
    -- Keep original whitespace and word boundaries. Avoid large bounded RE2
    -- repetitions: BigQuery evaluates those very slowly on this corpus.
    unnest(array(
        select as struct div(word_index, 120) as chunk_index,
            string_agg(word, '' order by word_index) as chunk_text
        from unnest(regexp_extract_all(p.text, r'\s*\S+\s*|\s+'))
            as word with offset as word_index
        group by chunk_index
    )) as chunk
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

-- Run in project __F1_GCP_PROJECT__, location US.
WITH candidates AS (
  SELECT base.*, m.meeting_name
  FROM AI.SEARCH(
    -- Structured prefilter: post-race transcripts
    (SELECT * FROM `f1.document_passages_search`
     WHERE document_type = 'transcript'
       AND conference_type = 'post-race'
    ),
    'embedding_text', 'tyre degradation',
    -- Vector search + keyword search
    mode => 'HYBRID', top_k => 20
  )
  JOIN `f1.meetings` AS m ON base.meeting_key = m.meeting_key
  WHERE m.year = 2025 -- Structured join and year filter
), reranked AS (
  SELECT meeting_name, title, chunk_text, source_url,
    -- Rerank the retrieved passages with a relevance score
    AI.GENERATE_DOUBLE(
      ('Score relevance from 0 to 1 for tyre degradation: ', chunk_text),
      connection_id => 'us.f1_document_embeddings',
      endpoint => 'gemini-2.5-flash'
    ).result AS relevance
  FROM candidates
)
SELECT * FROM reranked
WHERE relevance IS NOT NULL
ORDER BY relevance DESC
LIMIT 5;

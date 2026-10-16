-- Hybrid retrieval selects relevant evidence; distance is semantic distance,
-- not a calibrated confidence or a documented combined ranking score.
select base.document_id, base.source_position, base.chunk_index,
       base.title, base.speaker_label, base.question, base.chunk_text,
       base.source_url, distance
from ai.search(
    (select * from `__F1_GCP_PROJECT__.f1.document_passages_search`
     where document_type = 'transcript' and conference_type = 'post-race'),
    'embedding_text', 'tyre degradation and managing the tyres during the race',
    mode => 'HYBRID', top_k => 5
)

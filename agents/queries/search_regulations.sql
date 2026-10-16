-- Retrieve evidence across editions; assess applicability before applying a rule.
select base.document_id, base.source_position, base.chunk_index,
       base.title, base.rule_family, base.effective_from, base.effective_to,
       base.chunk_text, base.source_url, distance
from ai.search(
    (select * from `__F1_GCP_PROJECT__.f1.document_passages_search`
     where document_type = 'regulation'),
    'embedding_text', 'leaving the track and gaining a lasting advantage',
    mode => 'HYBRID', top_k => 5
)

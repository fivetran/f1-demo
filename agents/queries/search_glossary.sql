select base.document_id, base.source_position, base.chunk_index,
       base.title, base.chunk_text, base.embedding_text, base.source_url, distance
from ai.search(
    (select * from `__F1_GCP_PROJECT__.f1.document_passages_search`
     where document_type = 'glossary'),
    'embedding_text', 'dirty air and loss of downforce when following another car',
    mode => 'HYBRID', top_k => 5
)

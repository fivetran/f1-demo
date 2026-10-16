-- Each chunk repeats its full original text block; choose chunk 0 to read it once.
SELECT p.document_id, p.source_url, p.title, p.conference_type, p.association_method,
  m.meeting_name, p.source_position, p.speaker_label, p.question, p.text
FROM `__F1_GCP_PROJECT__.f1.document_passages_search` AS p
LEFT JOIN `__F1_GCP_PROJECT__.f1.meetings` AS m USING (meeting_key)
WHERE p.document_type = 'transcript'
  AND p.chunk_index = 0
  AND LOWER(COALESCE(p.text, '')) LIKE '%tyre%'
ORDER BY p.document_id, p.source_position
LIMIT 100

{{ config(materialized='ephemeral') }}
{{ document_search_source('transcript', 'transcript_passages', 'transcripts') }}

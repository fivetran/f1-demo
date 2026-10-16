{{ config(materialized='ephemeral') }}
{{ document_search_source('glossary', 'glossary_sections', 'glossary') }}

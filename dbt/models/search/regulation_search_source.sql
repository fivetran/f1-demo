{{ config(materialized='ephemeral') }}
{{ document_search_source('regulation', 'regulation_sections', 'regulations') }}

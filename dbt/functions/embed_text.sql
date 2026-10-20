(
    select if(
        response.status = '' and array_length(response.result) = 3072,
        response.result,
        error(concat('Embedding failed: ', coalesce(response.status, 'missing result')))
    )
    from (
        select ai.embed(content,
            connection_id => '{{ target.database }}.us.f1_document_embeddings',
            endpoint => 'gemini-embedding-2') as response
    )
)

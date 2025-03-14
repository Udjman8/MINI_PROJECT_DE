{{
    config(
        tags=['mart']
    )
}}
SELECT
     *
FROM
    {{ ref('product_rank') }}
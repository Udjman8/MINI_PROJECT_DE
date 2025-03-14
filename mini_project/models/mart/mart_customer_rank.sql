{{
    config(
        tags=['mart']
    )
}}
SELECT
     *
FROM
    {{ ref('customer_rank') }}
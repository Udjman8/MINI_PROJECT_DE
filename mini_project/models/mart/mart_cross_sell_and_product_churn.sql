{{
    config(
        tags=['mart']
    )
}}
SELECT
     *
FROM
    {{ ref('cross_sell_and_product_churn') }}
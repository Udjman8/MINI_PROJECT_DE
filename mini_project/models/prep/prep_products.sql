{{
    config(
        tags=['prep']
    )
}}
SELECT 
    PRODUCT_ID::VARCHAR AS PRODUCT_ID,
    LOWER(TRIM(PRODUCT_FAMILY)) AS PRODUCT_FAMILY,
    LOWER(TRIM(PRODUCT_SUB_FAMILY)) AS PRODUCT_SUB_FAMILY
FROM {{ ref('raw_products') }}
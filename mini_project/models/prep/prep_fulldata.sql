{{
    config(
        tags=['prep']
    )
}}
WITH CTE_1 AS(
    SELECT DISTINCT
        ST.CUSTOMER_ID,
        ST.PRODUCT_ID,
        ST.PAYMENT_MONTH,
        ST.REVENUE,
        ST.REVENUE_TYPE,
        ST.QUANTITY,
        CUST.COMPANY AS CUSTOMER_COMPANY,
        CUST.CUSTOMERNAME AS CUSTOMER_NAME,
        PROD.PRODUCT_FAMILY,
        PROD.PRODUCT_SUB_FAMILY
    FROM {{ ref('prep_transaction') }} ST
    LEFT JOIN {{ ref('prep_customers') }} CUST ON ST.CUSTOMER_ID = CUST.CUSTOMER_ID
    LEFT JOIN {{ ref('prep_products') }} PROD ON ST.PRODUCT_ID = PROD.PRODUCT_ID
)
SELECT
     *
FROM
    CTE_1
    WHERE REVENUE_TYPE = 1
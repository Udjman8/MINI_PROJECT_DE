{{
    config(
        tags=['prep']
    )
}}
WITH CTE_1 AS(
    SELECT DISTINCT
    LOWER(TRIM(COMPANY)) AS COMPANY,
    CUSTOMER_ID::NUMBER AS CUSTOMER_ID,
    LOWER(
        REGEXP_REPLACE(
            TRIM(REGEXP_SUBSTR(CUSTOMERNAME, '^[^(]+')), 
            ',', 
            ''
        )
    ) AS CUSTOMERNAME,  --  name without commas

    
FROM {{ ref('raw_customers') }}
)
SELECT
    C.COMPANY,
    C.CUSTOMER_ID,
    C.CUSTOMERNAME,
    T.country
FROM CTE_1 C LEFT JOIN {{source('RAW','Mapping')}} T ON C.CUSTOMER_ID = T.CUSTOMER_ID
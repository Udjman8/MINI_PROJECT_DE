{{
    config(
        tags=['raw']
    )
}}
SELECT 
     *
FROM 
     {{ source('RAW', 'Products') }} 
     WHERE PRODUCT_ID 
           IS NOT NULL
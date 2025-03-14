{{
    config(
        tags=['raw']
    )
}}
SELECT 
     *
FROM 
    {{ source('RAW', 'Transaction') }} 
    WHERE CUSTOMER_ID 
          IS NOT NULL
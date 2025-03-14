{{
    config(
        tags=['raw']
    )
}}
SELECT 
    * 
FROM 
    {{ source('RAW', 'Customers') }} 
    WHERE CUSTOMER_ID 
          IS NOT NULL
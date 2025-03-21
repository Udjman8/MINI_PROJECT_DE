
    SELECT DISTINCT
        CUSTOMER_ID::NUMBER AS CUSTOMER_ID,
        PRODUCT_ID::VARCHAR AS PRODUCT_ID,
        TO_DATE(PAYMENT_MONTH) AS PAYMENT_MONTH,
        REVENUE_TYPE::NUMBER AS REVENUE_TYPE,
        REVENUE::NUMBER(38,2) AS REVENUE,
        QUANTITY::NUMBER AS QUANTITY,
        LOWER(TRIM(COMPANIES)) AS COMPANIES
    FROM JOB_PORTAL.RAW.raw_transaction
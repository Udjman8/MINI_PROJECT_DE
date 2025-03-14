
 WITH customer_data AS (
    SELECT
        CUSTOMER_NAME,
        PRODUCT_ID,
        PRODUCT_FAMILY,
        PAYMENT_MONTH
    FROM
        JOB_PORTAL.PREP.prep_fulldata
),
max_payment_month AS (
    SELECT
        MAX(PAYMENT_MONTH) AS max_payment_month
    FROM
        JOB_PORTAL.PREP.prep_fulldata
),
full_table AS (
    SELECT
        c.CUSTOMER_NAME,
        c.PRODUCT_ID,
        c.PRODUCT_FAMILY,
        c.PAYMENT_MONTH,
        m.max_payment_month
    FROM
        customer_data c
    JOIN
        max_payment_month m ON 1=1
),
product_count AS (
    SELECT
        CUSTOMER_NAME,
        COUNT(DISTINCT PRODUCT_ID) AS product_count
    FROM
        customer_data
    GROUP BY
        CUSTOMER_NAME
),
product_churn AS (
    SELECT
        CUSTOMER_NAME,
        COUNT(DISTINCT CASE WHEN PAYMENT_MONTH < DATEADD(MONTH,-3,max_payment_month) THEN PRODUCT_ID END) AS Product_Churn
    FROM
        full_table
    GROUP BY
        CUSTOMER_NAME
),
ranked_customers AS (
    SELECT
        c.CUSTOMER_NAME,
        c.product_count,
        p.Product_Churn,
        (c.product_count-p.Product_Churn) AS Cross_Sell,
        DENSE_RANK() OVER (ORDER BY c.product_count-p.Product_Churn DESC) AS Cross_Sell_Rank,
        DENSE_RANK() OVER (ORDER BY p.Product_Churn DESC) AS Product_Churn_Rank
    FROM
        product_count c
    JOIN
        product_churn p ON c.CUSTOMER_NAME = p.CUSTOMER_NAME
)
SELECT
    CUSTOMER_NAME,
    product_count,
    Cross_Sell,
    Product_Churn,
    Cross_Sell_Rank,
    Product_Churn_Rank
FROM
    ranked_customers
ORDER BY
    Cross_Sell_Rank,
    Product_Churn_Rank
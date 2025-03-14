
  
    

        create or replace transient table JOB_PORTAL.RAW.lm_crb
         as
        (-- -- CRB Layer: KPIs for Last Month (LM)

-- WITH period_filters AS (
--     SELECT 
--         (SELECT MAX(PAYMENT_MONTH) - INTERVAL '1 MONTH' FROM JOB_PORTAL.MART.mart_job_portal) AS START_DATE,
--         (SELECT MAX(PAYMENT_MONTH) FROM JOB_PORTAL.MART.mart_job_portal) AS TODAY
-- )
-- ,
-- customer_activity AS (
--     SELECT 
--         CUSTOMER_ID, 
--         MIN(PAYMENT_MONTH) AS FIRST_PURCHASE, 
--         MAX(PAYMENT_MONTH) AS LAST_PURCHASE
--     FROM JOB_PORTAL.MART.mart_job_portal
--     GROUP BY CUSTOMER_ID
-- ),
-- revenue_changes AS (
--     SELECT 
--         CUSTOMER_ID, 
--         PAYMENT_MONTH, 
--         SUM(REVENUE) AS MONTHLY_REVENUE
--     FROM JOB_PORTAL.MART.mart_job_portal
--     WHERE PAYMENT_MONTH BETWEEN (SELECT START_DATE FROM period_filters) AND (SELECT TODAY FROM period_filters)
--     GROUP BY CUSTOMER_ID, PAYMENT_MONTH
-- ),
-- nrr_calculation AS (
--     SELECT 
--         CUSTOMER_ID, 
--         PAYMENT_MONTH,
--         MONTHLY_REVENUE,
--         LAG(MONTHLY_REVENUE) OVER (PARTITION BY CUSTOMER_ID ORDER BY PAYMENT_MONTH) AS PREV_MONTHLY_REVENUE
--     FROM revenue_changes
-- ),
-- revenue_contraction AS (
--     SELECT 
--         CUSTOMER_ID, 
--         PAYMENT_MONTH, 
--         MONTHLY_REVENUE AS CURRENT_REVENUE,
--         PREV_MONTHLY_REVENUE
--     FROM nrr_calculation
-- ),
-- product_ranking AS (
--     SELECT 
--         PRODUCT_ID,
--         SUM(REVENUE) AS TOTAL_REVENUE,
--         RANK() OVER (ORDER BY SUM(REVENUE) DESC) AS PRODUCT_RANK
--     FROM JOB_PORTAL.MART.mart_job_portal
--     WHERE PAYMENT_MONTH BETWEEN (SELECT START_DATE FROM period_filters) AND (SELECT TODAY FROM period_filters)
--     GROUP BY PRODUCT_ID
-- ),
-- customer_ranking AS (
--     SELECT 
--         CUSTOMER_ID,
--         SUM(REVENUE) AS TOTAL_REVENUE,
--         RANK() OVER (ORDER BY SUM(REVENUE) DESC) AS CUSTOMER_RANK
--     FROM JOB_PORTAL.MART.mart_job_portal
--     WHERE PAYMENT_MONTH BETWEEN (SELECT START_DATE FROM period_filters) AND (SELECT TODAY FROM period_filters)
--     GROUP BY CUSTOMER_ID
-- ),
-- grr_calculation AS (
--     SELECT 
--         CUSTOMER_ID,
--         PAYMENT_MONTH,
--         MONTHLY_REVENUE,
--         LAG(MONTHLY_REVENUE) OVER (PARTITION BY CUSTOMER_ID ORDER BY PAYMENT_MONTH) AS PREV_MONTHLY_REVENUE
--     FROM revenue_changes
-- )
-- SELECT 
--     'LM' AS PERIOD_TYPE,
--     COUNT(DISTINCT CASE WHEN customer_activity.FIRST_PURCHASE BETWEEN (SELECT START_DATE FROM period_filters) AND (SELECT TODAY FROM period_filters) THEN customer_activity.CUSTOMER_ID END) AS NEW_CUSTOMERS,
--     COUNT(DISTINCT CASE WHEN customer_activity.LAST_PURCHASE BETWEEN (SELECT START_DATE FROM period_filters) AND (SELECT TODAY FROM period_filters) THEN customer_activity.CUSTOMER_ID END) AS CHURNED_CUSTOMERS,
--     SUM(CASE WHEN revenue_contraction.CURRENT_REVENUE < revenue_contraction.PREV_MONTHLY_REVENUE THEN revenue_contraction.PREV_MONTHLY_REVENUE - revenue_contraction.CURRENT_REVENUE ELSE 0 END) AS REVENUE_LOST,
--     SUM(MONTHLY_REVENUE) / NULLIF(SUM(PREV_MONTHLY_REVENUE), 0) AS NRR,
--     SUM(grr_calculation.MONTHLY_REVENUE) / NULLIF(SUM(grr_calculation.PREV_MONTHLY_REVENUE), 0) AS GRR,
--     (SELECT COUNT(DISTINCT CUSTOMER_ID) FROM JOB_PORTAL.MART.mart_job_portal WHERE PAYMENT_MONTH BETWEEN (SELECT START_DATE FROM period_filters) AND (SELECT TODAY FROM period_filters)) AS NEW_LOGOS,
--     (SELECT PRODUCT_ID FROM product_ranking WHERE PRODUCT_RANK = 1) AS TOP_PRODUCT,
--     (SELECT CUSTOMER_ID FROM customer_ranking WHERE CUSTOMER_RANK = 1) AS TOP_CUSTOMER
-- FROM customer_activity
-- JOIN revenue_changes USING (CUSTOMER_ID)
-- JOIN revenue_contraction USING (CUSTOMER_ID)
-- JOIN nrr_calculation USING (CUSTOMER_ID)
-- JOIN grr_calculation USING (CUSTOMER_ID)

WITH base_data AS (
    SELECT
        PRODUCT_ID,
        PAYMENT_MONTH,
        REVENUE,
        QUANTITY,
        CUSTOMER_COMPANY,
        CUSTOMER_NAME,
        PRODUCT_FAMILY,
        PRODUCT_SUB_FAMILY
    FROM JOB_PORTAL.MART.mart_job_portal  -- Reference to your source table
),

-- Get the last month available in the dataset
last_month AS (
    SELECT
        MAX(PAYMENT_MONTH) AS max_payment_month
    FROM base_data
),

-- Filter data for the last month
last_month_data AS (
    SELECT *
    FROM base_data
    WHERE PAYMENT_MONTH = (SELECT max_payment_month FROM last_month)
),

-- Calculate total revenue for the last month
monthly_revenue AS (
    SELECT
        PAYMENT_MONTH,
        SUM(REVENUE) AS total_revenue
    FROM last_month_data
    GROUP BY PAYMENT_MONTH
),

-- Identify new customers in the last month
new_customers AS (
    SELECT
        PAYMENT_MONTH,
        COUNT(DISTINCT CUSTOMER_NAME) AS new_customers
    FROM (
        SELECT
            CUSTOMER_NAME,
            PAYMENT_MONTH,
            ROW_NUMBER() OVER (PARTITION BY CUSTOMER_NAME ORDER BY PAYMENT_MONTH) AS rn
        FROM base_data
    ) AS ranked_customers
    WHERE rn = 1 AND PAYMENT_MONTH = (SELECT max_payment_month FROM last_month)
    GROUP BY PAYMENT_MONTH
),

-- Identify churned customers (assuming churn means no purchases in the last month)
churned_customers AS (
    SELECT
        b1.PAYMENT_MONTH,
        COUNT(DISTINCT b1.CUSTOMER_NAME) AS churned_customers
    FROM base_data b1
    LEFT JOIN base_data b2
        ON b1.CUSTOMER_NAME = b2.CUSTOMER_NAME
        AND b2.PAYMENT_MONTH > b1.PAYMENT_MONTH
    WHERE b1.PAYMENT_MONTH = (SELECT max_payment_month FROM last_month)
    AND b2.CUSTOMER_NAME IS NULL  -- No purchases in the following month
    GROUP BY b1.PAYMENT_MONTH
),

-- Calculate revenue lost due to contraction (assuming contraction means a decrease in revenue)
revenue_lost AS (
    SELECT
        b1.PAYMENT_MONTH,
        SUM(b1.REVENUE) - COALESCE(SUM(b2.REVENUE), 0) AS revenue_lost
    FROM base_data b1
    LEFT JOIN base_data b2
        ON b1.CUSTOMER_NAME = b2.CUSTOMER_NAME
        AND b2.PAYMENT_MONTH = DATEADD(month, 1, b1.PAYMENT_MONTH)  -- Compare with the next month
    WHERE b1.PAYMENT_MONTH = (SELECT max_payment_month FROM last_month)
    GROUP BY b1.PAYMENT_MONTH
),

-- Identify new logos (new customers in the last month)
new_logos AS (
    SELECT
        PAYMENT_MONTH,
        COUNT(DISTINCT CUSTOMER_NAME) AS new_logos
    FROM base_data
    WHERE PAYMENT_MONTH = (SELECT max_payment_month FROM last_month)
    GROUP BY PAYMENT_MONTH
),

-- Revenue by product
revenue_by_product AS (
    SELECT
        PRODUCT_ID,
        PAYMENT_MONTH,
        SUM(REVENUE) AS total_revenue
    FROM base_data
    WHERE PAYMENT_MONTH = (SELECT max_payment_month FROM last_month)
    GROUP BY PRODUCT_ID, PAYMENT_MONTH
),

-- Revenue by customer
revenue_by_customer AS (
    SELECT
        CUSTOMER_NAME,
        PAYMENT_MONTH,
        SUM(REVENUE) AS total_revenue
    FROM base_data
    WHERE PAYMENT_MONTH = (SELECT max_payment_month FROM last_month)
    GROUP BY CUSTOMER_NAME, PAYMENT_MONTH
)

-- Final output combining all metrics
SELECT
    lm.max_payment_month AS payment_month,
    COALESCE(m.total_revenue, 0) AS total_revenue,
    COALESCE(n.new_customers, 0) AS new_customers,
    COALESCE(c.churned_customers, 0) AS churned_customers,
    COALESCE(r.revenue_lost, 0) AS revenue_lost,
    COALESCE(l.new_logos, 0) AS new_logos,
    p.PRODUCT_ID,
    p.total_revenue AS product_revenue,
    c2.CUSTOMER_NAME,
    c2.total_revenue AS customer_revenue
FROM last_month lm
LEFT JOIN monthly_revenue m ON lm.max_payment_month = m.PAYMENT_MONTH
LEFT JOIN new_customers n ON lm.max_payment_month = n.PAYMENT_MONTH
LEFT JOIN churned_customers c ON lm.max_payment_month = c.PAYMENT_MONTH
LEFT JOIN revenue_lost r ON lm.max_payment_month = r.PAYMENT_MONTH
LEFT JOIN new_logos l ON lm.max_payment_month = l.PAYMENT_MONTH
LEFT JOIN revenue_by_product p ON lm.max_payment_month = p.PAYMENT_MONTH
LEFT JOIN revenue_by_customer c2 ON lm.max_payment_month = c2.PAYMENT_MONTH
ORDER BY lm.max_payment_month, p.PRODUCT_ID, c2.CUSTOMER_NAME
        );
      
  
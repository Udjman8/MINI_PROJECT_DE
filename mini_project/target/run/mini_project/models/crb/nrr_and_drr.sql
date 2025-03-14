
  
    

        create or replace transient table JOB_PORTAL.KPI.nrr_and_drr
         as
        (with prev as (
    select
        customer_id,
        revenue,
        lag(revenue) over (partition by customer_id order by PAYMENT_MONTH) as previous_revenue
    from JOB_PORTAL.PREP.prep_transaction
),
transactions AS (
 SELECT
        customer_id,
        SUM(revenue) AS total_revenue,  
        sum(previous_revenue) as prev_total_revenue,
        CASE WHEN total_revenue > prev_total_revenue THEN total_revenue-prev_total_revenue ELSE 0 END AS expansion_revenue,  
        CASE WHEN total_revenue < prev_total_revenue THEN prev_total_revenue-total_revenue ELSE 0 END AS contraction_revenue  
    FROM prev
    GROUP BY 1
)
SELECT
    customer_id,
    total_revenue,
    prev_total_revenue,
    expansion_revenue,
    contraction_revenue,
    CASE
        WHEN total_revenue = 0 THEN 0
        ELSE (((total_revenue)+(expansion_revenue - contraction_revenue)) / total_revenue)*100
    END AS net_revenue_retention_in_percentage,
    CASE
        WHEN total_revenue = 0 THEN 0
        ELSE (((total_revenue)-(expansion_revenue - contraction_revenue)) / total_revenue)*100
    END AS gross_revenue_retention_in_percentage
FROM transactions
        );
      
  
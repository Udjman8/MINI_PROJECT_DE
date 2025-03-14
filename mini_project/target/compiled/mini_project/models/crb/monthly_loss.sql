
WITH revenue_loss AS(
  SELECT 
    payment_month, 
    SUM(revenue) AS this_month_revenue, 
    LAG (
      SUM(revenue)
    ) OVER (
      ORDER BY 
        payment_month
    ) AS previous_month_revenue 
  FROM 
    JOB_PORTAL.PREP.prep_transaction 
  where 
    revenue_type = 1 
  GROUP BY 
    payment_month
) 
SELECT 
  PAYMENT_MONTH, 
  this_month_revenue, 
  PREVIOUS_MONTH_REVENUE, 
  This_month_revenue - PREVIOUS_MONTH_REVENUE AS MONTHLY_LOSS 
FROM 
  revenue_loss 
where 
  monthly_loss < 0 
ORDER BY 
  payment_month
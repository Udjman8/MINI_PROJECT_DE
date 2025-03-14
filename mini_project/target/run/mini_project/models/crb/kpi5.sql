
  
    

        create or replace transient table JOB_PORTAL.KPI.kpi5
         as
        (
WITH CTE_1 AS(
  SELECT 
    CUSTOMER_ID, 
    MIN(PAYMENT_MONTH) AS FIRST_MONTH 
  FROM 
    JOB_PORTAL.PREP.prep_transaction 
  GROUP BY 
    CUSTOMER_ID
) 
SELECT 
  DISTINCT DATE_TRUNC('YEAR', FIRST_MONTH) AS FISCAL_YEAR, 
  (
    COUNT(CUSTOMER_ID)
  ) AS NEW_CUSTOMERS 
FROM 
  CTE_1 
GROUP BY 
  FISCAL_YEAR
        );
      
  
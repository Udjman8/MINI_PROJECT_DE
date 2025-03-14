
  
    

        create or replace transient table JOB_PORTAL.MART.mart_cross_sell_and_product_churn
         as
        (
SELECT
     *
FROM
    JOB_PORTAL.KPI.cross_sell_and_product_churn
        );
      
  
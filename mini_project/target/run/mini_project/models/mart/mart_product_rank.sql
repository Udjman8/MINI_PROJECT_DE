
  
    

        create or replace transient table JOB_PORTAL.MART.mart_product_rank
         as
        (
SELECT
     *
FROM
    JOB_PORTAL.KPI.product_rank
        );
      
  
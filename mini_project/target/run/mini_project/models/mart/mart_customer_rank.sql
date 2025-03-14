
  
    

        create or replace transient table JOB_PORTAL.MART.mart_customer_rank
         as
        (
SELECT
     *
FROM
    JOB_PORTAL.KPI.customer_rank
        );
      
  
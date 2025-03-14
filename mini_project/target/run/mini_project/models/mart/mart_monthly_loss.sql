
  
    

        create or replace transient table JOB_PORTAL.MART.mart_monthly_loss
         as
        (
SELECT
     *
FROM
    JOB_PORTAL.KPI.monthly_loss
        );
      
  
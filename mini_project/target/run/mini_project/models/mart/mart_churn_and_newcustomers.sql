
  
    

        create or replace transient table JOB_PORTAL.MART.mart_churn_and_newcustomers
         as
        (
SELECT
     *
FROM
    JOB_PORTAL.KPI.churn_and_newcustomers
        );
      
  
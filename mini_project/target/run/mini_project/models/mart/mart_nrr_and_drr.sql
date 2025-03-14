
  
    

        create or replace transient table JOB_PORTAL.MART.mart_nrr_and_drr
         as
        (
SELECT
     *
FROM
    JOB_PORTAL.KPI.nrr_and_drr
        );
      
  
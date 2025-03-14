
  
    

        create or replace transient table JOB_PORTAL.MART.mart_fiscal_year_logos
         as
        (
SELECT
     *
FROM
    JOB_PORTAL.KPI.fiscal_year_logos
        );
      
  
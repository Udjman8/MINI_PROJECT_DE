
  
    

        create or replace transient table JOB_PORTAL.RAW.raw_customers
         as
        (
SELECT 
    * 
FROM 
    MINI_PROJECT.RAW.Customers 
    WHERE CUSTOMER_ID 
          IS NOT NULL
        );
      
  

  
    

        create or replace transient table JOB_PORTAL.RAW.raw_transaction
         as
        (
SELECT 
     *
FROM 
    MINI_PROJECT.RAW.Transaction 
    WHERE CUSTOMER_ID 
          IS NOT NULL
        );
      
  
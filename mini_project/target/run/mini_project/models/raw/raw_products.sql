
  
    

        create or replace transient table JOB_PORTAL.RAW.raw_products
         as
        (
SELECT 
     *
FROM 
     MINI_PROJECT.RAW.Products 
     WHERE PRODUCT_ID 
           IS NOT NULL
        );
      
  
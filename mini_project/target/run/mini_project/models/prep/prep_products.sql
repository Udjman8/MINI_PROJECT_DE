
  
    

        create or replace transient table JOB_PORTAL.PREP.prep_products
         as
        (
SELECT 
    PRODUCT_ID::VARCHAR AS PRODUCT_ID,
    LOWER(TRIM(PRODUCT_FAMILY)) AS PRODUCT_FAMILY,
    LOWER(TRIM(PRODUCT_SUB_FAMILY)) AS PRODUCT_SUB_FAMILY
FROM JOB_PORTAL.RAW.raw_products
        );
      
  
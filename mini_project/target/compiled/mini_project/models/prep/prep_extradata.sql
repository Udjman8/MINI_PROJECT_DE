SELECT CUSTOMER_ID, 
PRODUCT_ID, 
LAG(PAYMENT_MONTH) OVER(
  PARTITION BY CUSTOMER_ID 
  ORDER BY 
    PAYMENT_MONTH
) AS LAST_MONTH, 
PAYMENT_MONTH, 
REVENUE, 
SUM(REVENUE) OVER(
  PARTITION BY PAYMENT_MONTH 
  ORDER BY 
    PAYMENT_MONTH
) AS MONTH_REVENUE, 
CUSTOMER_NAME, 
PRODUCT_FAMILY, 
PRODUCT_SUB_FAMILY, 
LAG(PRODUCT_FAMILY) OVER(
  PARTITION BY CUSTOMER_ID, 
  PAYMENT_MONTH 
  ORDER BY 
    PAYMENT_MONTH
) AS LAST_PRODUCT, 
LAG(PRODUCT_SUB_FAMILY) OVER(
  PARTITION BY CUSTOMER_ID, 
  PAYMENT_MONTH 
  ORDER BY 
    PAYMENT_MONTH
) AS LAST_PRODUCT_SUB 
FROM 
  JOB_PORTAL.PREP.prep_fulldata 
ORDER BY 
  CUSTOMER_ID, 
  PAYMENT_MONTH
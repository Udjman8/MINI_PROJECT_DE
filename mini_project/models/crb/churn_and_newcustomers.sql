{{
    config(
        tags=['kpi']
    )
}}
WITH
  CTE_1 AS (
    SELECT
      MAX(PAYMENT_MONTH) AS EOP
    FROM
      {{ref('prep_transaction')}}
  ),
  CTE_2 AS (
    SELECT
      *
    FROM
      {{ref('prep_transaction')}}
      INNER JOIN CTE_1 AS CT ON 1 = 1
  ),
  CTE_3 AS (
    SELECT
      CUSTOMER_ID,
      MAX(PAYMENT_MONTH) AS LATEST,
      MIN(PAYMENT_MONTH) AS FIRST,
      DATEADD (MONTH, -3, EOP) AS L3M,
      EOP,
      CASE
        WHEN (FIRST <= L3M) THEN 0
        ELSE 1
      END AS IS_NEW,
      CASE
        WHEN (
          FIRST <= L3M
          AND LATEST < EOP
        ) THEN 1
        ELSE 0
      END AS IS_CHURN
    FROM
      CTE_2
    GROUP BY
      CUSTOMER_ID,
      EOP
  )
SELECT
  SUM(IS_CHURN) AS CHURNED_CUSTOMERS,
  SUM(IS_NEW) AS NEW_CUSTOMERS,
  EOP
FROM
  CTE_3
GROUP BY
  EOP
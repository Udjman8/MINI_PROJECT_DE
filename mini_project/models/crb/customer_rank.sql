{{
    config(
        tags=['kpi']
    )
}}
with
  cte_1 as (
    select
      T.customer_id,
      c.customername,
      c.country,
      sum(T.revenue) as revenue
    from
      {{ref('prep_transaction')}} T
      LEFT JOIN {{ref('prep_customers')}} c on T.customer_id = c.customer_id
    where
      T.revenue_type = 1
    group by
      T.customer_id,
      c.customername,
      c.country
  ),
  cte_2 as (
    select
      customer_id,
      customername,
      country,
      revenue,
      dense_rank() over (
        order by
          revenue desc
      )
    from
      cte_1
  )
select
  *
from
  cte_2
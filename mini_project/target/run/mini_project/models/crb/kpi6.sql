
  
    

        create or replace transient table JOB_PORTAL.KPI.kpi6
         as
        (
with
  cte_1 as (
    select
      product_id,
      sum(revenue) as revenue
    from
      JOB_PORTAL.PREP.prep_transaction
    where
      revenue_type = 1
    group by
      product_id
  ),
  cte_2 as (
    select
      product_id,
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
        );
      
  
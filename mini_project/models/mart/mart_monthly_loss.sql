{{
    config(
        tags=['mart']
    )
}}
SELECT
     *
FROM
    {{ ref('monthly_loss') }}
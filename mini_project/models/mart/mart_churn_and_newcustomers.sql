{{
    config(
        tags=['mart']
    )
}}
SELECT
     *
FROM
    {{ ref('churn_and_newcustomers') }}
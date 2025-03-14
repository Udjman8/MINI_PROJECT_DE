{{
    config(
        tags=['mart']
    )
}}
SELECT
     *
FROM
    {{ ref('fiscal_year_logos') }}
{{
    config(
        tags=['mart']
    )
}}
SELECT
     *
FROM
    {{ ref('nrr_and_drr') }}
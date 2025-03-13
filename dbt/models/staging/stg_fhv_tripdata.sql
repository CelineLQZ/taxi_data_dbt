{{ config(
    materialized='view'
) }}

WITH tripdata AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY dispatching_base_num, pickup_datetime) AS rn
    FROM {{ source('staging', 'fhv_tripdata_ext') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['dispatching_base_num', 'pickup_datetime']) }} AS tripid,
    dispatching_base_num,
    CAST(pickup_datetime AS TIMESTAMP) AS pickup_datetime,
    CAST(dropOff_datetime AS TIMESTAMP) AS dropoff_datetime,
    SAFE_CAST(PUlocationID AS INT64) AS pickup_locationid,
    SAFE_CAST(DOlocationID AS INT64) AS dropoff_locationid,
    SR_Flag,
    Affiliated_base_number
FROM tripdata
WHERE rn = 1
  AND dispatching_base_num IS NOT NULL 
  AND extract(year from pickup_datetime) = 2019
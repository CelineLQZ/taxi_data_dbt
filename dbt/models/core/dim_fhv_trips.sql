{{
    config(
        materialized='table'
    )
}}

with fhv_tripdata as (
    select * from {{ ref('stg_fhv_tripdata') }}
),

dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)

select fhv_tripdata.*,
        pickup_zone.borough as pickup_borough, 
        pickup_zone.zone as pickup_zone, 
        dropoff_zone.borough as dropoff_borough, 
        dropoff_zone.zone as dropoff_zone,
        EXTRACT(YEAR FROM fhv_tripdata.pickup_datetime) AS trip_year,
        EXTRACT(QUARTER FROM fhv_tripdata.pickup_datetime) AS trip_quarter,
        EXTRACT(MONTH FROM fhv_tripdata.pickup_datetime) AS trip_month
from fhv_tripdata
inner join dim_zones as pickup_zone
on fhv_tripdata.pickup_locationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on fhv_tripdata.dropoff_locationid = dropoff_zone.locationid
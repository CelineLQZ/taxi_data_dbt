{{
    config(
        materialized='table'
    )
}}

with trip_data as (
    select *,
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) AS trip_duration
    from {{ ref('dim_fhv_trips') }}
    where dropoff_datetime > pickup_datetime  -- Exclude incorrect records
),

p90_travel_time as (
    select 
        trip_year,
        trip_month,
        pickup_locationid,
        pickup_borough,
        pickup_zone,
        dropoff_locationid,
        dropoff_borough,
        dropoff_zone,
        APPROX_QUANTILES(trip_duration, 100)[OFFSET(90)] AS p90_trip_duration
    from trip_data
    group by 1,2,3,4,5,6,7,8
)

select * from p90_travel_time
order by trip_year, trip_month, pickup_locationid, dropoff_locationid

{{
    config(
        materialized='table'
    )
}}

with filtered_trips as (
    -- 过滤掉无效的订单
    select 
        service_type,
        trip_year,
        trip_month,
        fare_amount
    from {{ ref('dim_taxi_trips') }}
    where 
        fare_amount > 0
        and trip_distance > 0
        and payment_type_description IN ('Cash', 'Credit card')
),

percentile_calculations as (
    -- 计算不同的分位数，并使用 GROUP BY 保证去重
    select
        service_type,
        trip_year,
        trip_month,
        PERCENTILE_CONT(fare_amount, 0.97) OVER (
            PARTITION BY service_type, trip_year, trip_month
        ) AS p97_fare,
        PERCENTILE_CONT(fare_amount, 0.95) OVER (
            PARTITION BY service_type, trip_year, trip_month
        ) AS p95_fare,
        PERCENTILE_CONT(fare_amount, 0.90) OVER (
            PARTITION BY service_type, trip_year, trip_month
        ) AS p90_fare,
        ROW_NUMBER() OVER (PARTITION BY service_type, trip_year, trip_month ORDER BY fare_amount DESC) AS rn
    FROM filtered_trips
)

-- 只保留 rn = 1 的行，确保每个 service_type, trip_year, trip_month 只有一行
select 
    service_type,
    trip_year,
    trip_month,
    p90_fare,
    p95_fare,
    p97_fare
from percentile_calculations
where rn = 1
order by 1,2,3



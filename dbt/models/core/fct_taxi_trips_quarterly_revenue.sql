{{
    config(
        materialized='table'
    )
}}

WITH quarterly_revenue AS (
    SELECT 
        service_type,
        trip_year,
        trip_quarter,
        SUM(CAST(total_amount AS NUMERIC)) AS quarterly_revenue
    FROM {{ ref('dim_taxi_trips') }}
    GROUP BY service_type, trip_year, trip_quarter
)

SELECT 
    curr.service_type,
    curr.trip_year,
    curr.trip_quarter,
    curr.quarterly_revenue,
    prev.quarterly_revenue AS previous_year_quarter_revenue,
    
    -- 计算 YoY 增长率
    CASE 
        WHEN prev.quarterly_revenue IS NOT NULL AND prev.quarterly_revenue != 0 
        THEN ROUND((curr.quarterly_revenue - prev.quarterly_revenue) / prev.quarterly_revenue * 100, 2)
        ELSE NULL
    END AS yoy_growth_percentage

FROM quarterly_revenue AS curr
LEFT JOIN quarterly_revenue AS prev
    ON curr.service_type = prev.service_type 
    AND curr.trip_year = prev.trip_year + 1
    AND curr.trip_quarter = prev.trip_quarter

ORDER BY curr.service_type, curr.trip_year, curr.trip_quarter









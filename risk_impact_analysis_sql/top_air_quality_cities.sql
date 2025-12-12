/**************************************************************************************************
-- FILE: top_air_quality_cities.sql
-- PURPOSE: Identify top 5 cities with the highest air quality concerns and associated risks.
-- DESCRIPTION:
--    This query aggregates air quality data by city and country, calculates average AQI,
--    counts the number of days exceeding a critical AQI threshold (200), population exposure,
--    and average temperature. Only the top 5 cities with the highest average AQI are selected.
**************************************************************************************************/

SELECT
    country,
    city,
    ROUND(AVG(air_quality_index)::numeric, 0) AS average_aqi,
    COUNT(*) FILTER (WHERE air_quality_index > 200) AS days_above_200_aqi,
    SUM(population_exposure) AS total_population_exposure,
    ROUND(AVG(temperature)::numeric, 1) AS average_temperature
FROM weather_schemas.combined_data
WHERE date BETWEEN '2025-03-03' AND '2025-03-07'
GROUP BY country, city
HAVING AVG(air_quality_index) > 100
ORDER BY average_aqi DESC
LIMIT 5;

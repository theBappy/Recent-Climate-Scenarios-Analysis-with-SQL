/**************************************************************************************************
-- FILE: extreme_weather_weekly_impact.sql
-- PURPOSE: Identify cities experiencing extreme weather events in a given week
--          and report their economic and population impacts.
-- DESCRIPTION:
--    This query selects cities with extreme weather events between specified dates,
--    aggregating temperature, population exposure, economic impact, and infrastructure vulnerability.
-- NOTES:
--    - Only events not equal to 'None' are considered.
--    - Aggregated metrics provide insight into severity and potential impacts.
**************************************************************************************************/

SELECT
    country,
    city,
    extreme_weather_events,
    COUNT(*) AS event_count,
    ROUND(AVG(temperature)::numeric, 1) AS average_temperature,
    SUM(population_exposure) AS total_population_exposure,
    SUM(economic_impact_estimate) AS total_economic_impact,
    ROUND(AVG(infrastructure_vulnerability_score)::numeric, 0) AS average_vulnerability
FROM weather_schemas.combined_data
WHERE date BETWEEN '2025-03-03' AND '2025-03-07'
  AND extreme_weather_events != 'None'
GROUP BY country, city, extreme_weather_events
ORDER BY total_economic_impact DESC;

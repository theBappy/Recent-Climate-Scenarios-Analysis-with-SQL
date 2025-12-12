/**************************************************************************************************
-- FILE: biome_risk_analysis.sql
-- PURPOSE: Identify biome types most at risk from extreme weather events this week.
-- DESCRIPTION:
--    Aggregates weather data by biome type, counting locations affected, extreme weather events,
--    event types, average temperature, total economic impact, and average vulnerability.
--    Only considers data between 2025-03-03 and 2025-03-07.
**************************************************************************************************/

SELECT
    biome_type,
    COUNT(*) AS total_records,
    COUNT(DISTINCT country || '-' || city) AS locations_affected,
    COUNT(*) FILTER (WHERE extreme_weather_events != 'None') AS extreme_weather_count,
    STRING_AGG(DISTINCT extreme_weather_events, ', ') AS event_types,
    ROUND(AVG(temperature)::numeric, 1) AS average_temperature,
    SUM(economic_impact_estimate) AS total_economic_impact_estimate,
    ROUND(AVG(infrastructure_vulnerability_score)::numeric, 0) AS average_vulnerability
FROM weather_schemas.combined_data
WHERE date BETWEEN '2025-03-03' AND '2025-03-07'
GROUP BY biome_type
ORDER BY extreme_weather_count DESC;

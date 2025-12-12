/**************************************************************************************************
-- FILE: weather_data_analysis-1.sql
-- PURPOSE: Analyze combined weather data for monthly trends, country-wise averages, and extreme events.
-- DESCRIPTION:
--    This script performs key analytical queries on the weather_schemas.combined_data table.
--    It includes:
--       1. Monthly average temperature
--       2. Average temperature by country
--       3. Extreme weather events by month
--       4. Extreme weather events by country
--
-- NOTES:
--    - Average temperatures are rounded to 2 decimal points.
--    - Extreme weather events are counted only if the value is not 'None'.
--    - Month names are formatted and ordered chronologically.
--    - Queries are production-ready and repo-friendly.
**************************************************************************************************/

-- =============================================================
-- 1. Monthly Average Temperature
-- =============================================================
SELECT 
    TO_CHAR(date, 'Month') AS month_name,
    ROUND(AVG(temperature)::numeric, 2) AS avg_temperature
FROM weather_schemas.combined_data
GROUP BY TO_CHAR(date, 'Month'), EXTRACT(MONTH FROM date)
ORDER BY EXTRACT(MONTH FROM date);

-- =============================================================
-- 2. Average Temperature by Country
-- =============================================================
SELECT 
    country,
    ROUND(AVG(temperature)::numeric, 2) AS avg_temperature_by_country
FROM weather_schemas.combined_data
GROUP BY country
ORDER BY avg_temperature_by_country DESC;

-- =============================================================
-- 3. Extreme Weather Events by Month
-- =============================================================
SELECT
    TO_CHAR(date, 'Month') AS month_name,
    COUNT(*) AS event_count
FROM weather_schemas.combined_data
WHERE extreme_weather_events <> 'None'
GROUP BY TO_CHAR(date, 'Month'), EXTRACT(MONTH FROM date)
ORDER BY EXTRACT(MONTH FROM date);

-- =============================================================
-- 4. Extreme Weather Events by Country
-- =============================================================
SELECT
    country,
    COUNT(*) AS event_count
FROM weather_schemas.combined_data
WHERE extreme_weather_events <> 'None'
GROUP BY country
ORDER BY event_count DESC;

-- End of weather data analysis-1 script

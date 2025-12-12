/**************************************************************************************************
-- FILE: extreme_weather_by_temperature.sql
-- PURPOSE: Analyze extreme weather events by temperature range.
-- DESCRIPTION:
--    This script categorizes extreme weather events from the combined weather data table
--    into temperature ranges and counts the occurrences of each type of event.
--
-- NOTES:
--    - Temperature ranges are categorized as:
--          Very Cold (<10°C)
--          Cold (10-15°C)
--          Moderate (15-20°C)
--          Warm (20-25°C)
--          Hot (>25°C)
--    - Only extreme_weather_events not equal to 'None' are considered.
--    - Results are grouped by temperature range and extreme weather event type.
--    - Event counts are sorted descending within each temperature range.
**************************************************************************************************/

-- =============================================================
-- Extreme Weather Events by Temperature Range
-- =============================================================
SELECT
    CASE
        WHEN temperature < 10 THEN 'Very Cold (<10°C)'
        WHEN temperature BETWEEN 10 AND 15 THEN 'Cold (10-15°C)'
        WHEN temperature BETWEEN 15 AND 20 THEN 'Moderate (15-20°C)'
        WHEN temperature BETWEEN 20 AND 25 THEN 'Warm (20-25°C)'
        ELSE 'Hot (>25°C)'
    END AS temperature_range,
    extreme_weather_events,
    COUNT(*) AS event_count
FROM weather_schemas.combined_data
WHERE extreme_weather_events <> 'None'
GROUP BY temperature_range, extreme_weather_events
ORDER BY temperature_range, event_count DESC;

-- End of extreme weather by temperature analysis

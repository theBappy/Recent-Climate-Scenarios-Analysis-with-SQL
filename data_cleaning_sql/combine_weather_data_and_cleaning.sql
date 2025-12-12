/**************************************************************************************************
-- FILE: combined_weather_data_production.sql
-- PURPOSE: Create and clean a combined weather data table for multiple countries.
-- DESCRIPTION:
--    This script consolidates weather data from 7 country-specific tables into a single table
--    called combined_data in the weather_schemas schema. It performs data validation, column
--    standardization (snake_case), and fixes known null values.
--
--    Countries included:
--       1. Australia
--       2. Brazil
--       3. Canada
--       4. Germany
--       5. India
--       6. South Africa
--       7. USA
--
-- USAGE:
--    Execute this script in PostgreSQL (pgAdmin, psql, or ETL tool).
--    Ensure the schema weather_schemas and source country tables exist.
--
-- NOTES:
--    - UNION ALL preserves all rows.
--    - Column names are standardized to snake_case for consistency.
--    - Specific NULL fixes are applied for city and population_exposure.
**************************************************************************************************/

-- Drop combined_data table if exists
DROP TABLE IF EXISTS weather_schemas.combined_data;

-- Create the combined table using UNION ALL
CREATE TABLE weather_schemas.combined_data AS
SELECT * FROM weather_schemas.australia
UNION ALL
SELECT * FROM weather_schemas.brazil
UNION ALL
SELECT * FROM weather_schemas.canada
UNION ALL
SELECT * FROM weather_schemas.germany
UNION ALL
SELECT * FROM weather_schemas.india
UNION ALL
SELECT * FROM weather_schemas.south_africa
UNION ALL
SELECT * FROM weather_schemas.usa;

-- -----------------------------
-- Step 1: Basic validation
-- -----------------------------
-- Check total rows
SELECT COUNT(*) AS total_rows
FROM weather_schemas.combined_data;

-- Check distinct countries
SELECT country, COUNT(*) AS rows_per_country
FROM weather_schemas.combined_data
GROUP BY country
ORDER BY country;

-- Check duplicates based on record_id
SELECT record_id, COUNT(*) AS duplicate_count
FROM weather_schemas.combined_data
GROUP BY record_id
HAVING COUNT(*) > 1;

-- -----------------------------
-- Step 2: Standardize column names to snake_case
-- -----------------------------
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Record ID" TO record_id;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Date" TO date;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Country" TO country;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "City" TO city;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Temperature" TO temperature;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Humidity" TO humidity;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Precipitation" TO precipitation;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Air Quality Index" TO air_quality_index;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Extreme Weather Events" TO extreme_weather_events;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Climate Classification" TO climate_classification;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Climate Zone" TO climate_zone;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Biome Type" TO biome_type;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Heat Index" TO heat_index;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Wind Speed" TO wind_speed;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Wind Direction" TO wind_direction;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Season" TO season;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Population Exposur" TO population_exposure;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Economic Impact Estimate" TO economic_impact_estimate;
ALTER TABLE weather_schemas.combined_data RENAME COLUMN "Infrastructure Vulnerability Score" TO infrastructure_vulnerability_score;

-- -----------------------------
-- Step 3: Check for NULL values
-- -----------------------------
SELECT 
    COUNT(*) FILTER (WHERE record_id IS NULL) AS record_id_nulls,
    COUNT(*) FILTER (WHERE date IS NULL) AS date_nulls,
    COUNT(*) FILTER (WHERE country IS NULL) AS country_nulls,
    COUNT(*) FILTER (WHERE city IS NULL) AS city_nulls,
    COUNT(*) FILTER (WHERE temperature IS NULL) AS temperature_nulls,
    COUNT(*) FILTER (WHERE humidity IS NULL) AS humidity_nulls,
    COUNT(*) FILTER (WHERE precipitation IS NULL) AS precipitation_nulls,
    COUNT(*) FILTER (WHERE air_quality_index IS NULL) AS air_quality_index_nulls,
    COUNT(*) FILTER (WHERE extreme_weather_events IS NULL) AS extreme_weather_events_nulls,
    COUNT(*) FILTER (WHERE climate_classification IS NULL) AS climate_classification_nulls,
    COUNT(*) FILTER (WHERE climate_zone IS NULL) AS climate_zone_nulls,
    COUNT(*) FILTER (WHERE biome_type IS NULL) AS biome_type_nulls,
    COUNT(*) FILTER (WHERE heat_index IS NULL) AS heat_index_nulls,
    COUNT(*) FILTER (WHERE wind_speed IS NULL) AS wind_speed_nulls,
    COUNT(*) FILTER (WHERE wind_direction IS NULL) AS wind_direction_nulls,
    COUNT(*) FILTER (WHERE season IS NULL) AS season_nulls,
    COUNT(*) FILTER (WHERE population_exposure IS NULL) AS population_exposure_nulls,
    COUNT(*) FILTER (WHERE economic_impact_estimate IS NULL) AS economic_impact_estimate_nulls,
    COUNT(*) FILTER (WHERE infrastructure_vulnerability_score IS NULL) AS infrastructure_vulnerability_score_nulls
FROM weather_schemas.combined_data;

-- -----------------------------
-- Step 4: Fix known NULL values
-- -----------------------------
-- Fix population_exposure for a specific record
UPDATE weather_schemas.combined_data
SET population_exposure = 5275135
WHERE record_id = 'aus_1338';

-- Fix city for a specific record
UPDATE weather_schemas.combined_data
SET city = 'Toronto'
WHERE record_id = 'cnd_227';

-- -----------------------------
-- Step 5: Final validation
-- -----------------------------
-- Check for remaining NULLs after fix
SELECT 
    COUNT(*) FILTER (WHERE record_id IS NULL) AS record_id_nulls,
    COUNT(*) FILTER (WHERE date IS NULL) AS date_nulls,
    COUNT(*) FILTER (WHERE country IS NULL) AS country_nulls,
    COUNT(*) FILTER (WHERE city IS NULL) AS city_nulls,
    COUNT(*) FILTER (WHERE population_exposure IS NULL) AS population_exposure_nulls
FROM weather_schemas.combined_data;

-- Check duplicates after fixes
SELECT record_id, COUNT(*) AS duplicate_count
FROM weather_schemas.combined_data
GROUP BY record_id
HAVING COUNT(*) > 1;

-- Confirm distinct countries
SELECT DISTINCT country
FROM weather_schemas.combined_data
ORDER BY country;

-- Final row count
SELECT COUNT(*) AS total_rows
FROM weather_schemas.combined_data;

-- End of data cleaning

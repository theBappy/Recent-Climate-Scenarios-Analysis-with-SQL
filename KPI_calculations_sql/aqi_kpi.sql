/*=====================================================================================
    File:           aqi_kpi.sql
    Purpose:        KPI development for Air Quality Index (AQI)
    Description:    Computes:
                        - Current Month AQI
                        - Previous Month AQI
                        - Percent Difference
                        - Good / Bad KPI Indicators with arrows
    Author:         <your name>
    Last Updated:   <date>
======================================================================================*/

/*--------------------------------------------------------------------------------------
    1. PARAMETERS / CONFIGURATION
       Replace @current_month with a parameter or pass it from the BI tool / pipeline.
       Expected format: YYYY-MM-01  (first day of the month)
---------------------------------------------------------------------------------------*/

-- Example parameter (SQL Server style). Adjust as needed.
DECLARE @current_month DATE = '2024-08-01';   -- <-- MODIFY TO TARGET MONTH


/*--------------------------------------------------------------------------------------
    2. BASE DATA
       Ensure your source table includes:
        - Air Quality Index
        - Date
---------------------------------------------------------------------------------------*/
-- Example table:
-- SELECT * FROM air_quality_data;

/*--------------------------------------------------------------------------------------
    3. DERIVED DATE LOGIC
       Compute first day of previous month from @current_month.
---------------------------------------------------------------------------------------*/
WITH date_context AS (
    SELECT
        @current_month AS current_month,
        DATEADD(MONTH, -1, @current_month) AS previous_month
),


/*--------------------------------------------------------------------------------------
    4. MONTHLY AGGREGATES
       Computes average AQI for the current and previous months.
---------------------------------------------------------------------------------------*/
monthly_aqi AS (
    SELECT
        dc.current_month,
        dc.previous_month,

        -- Current Month AQI
        (
            SELECT AVG(aqd.air_quality_index)
            FROM air_quality_data aqd
            WHERE DATEFROMPARTS(YEAR(aqd.date), MONTH(aqd.date), 1) = dc.current_month
        ) AS current_month_aqi,

        -- Previous Month AQI
        (
            SELECT AVG(aqd.air_quality_index)
            FROM air_quality_data aqd
            WHERE DATEFROMPARTS(YEAR(aqd.date), MONTH(aqd.date), 1) = dc.previous_month
        ) AS previous_month_aqi

    FROM date_context dc
),


/*--------------------------------------------------------------------------------------
    5. PERCENT DIFFERENCE
       Formula:
            (Current − Previous) / Previous
---------------------------------------------------------------------------------------*/
difference_calc AS (
    SELECT
        current_month,
        previous_month,
        current_month_aqi,
        previous_month_aqi,

        CASE
            WHEN previous_month_aqi = 0 THEN NULL
            ELSE (current_month_aqi - previous_month_aqi) / previous_month_aqi
        END AS percent_difference
    FROM monthly_aqi
),


/*--------------------------------------------------------------------------------------
    6. KPI LABELING
       Applies 3% threshold rules:

       Good KPI:
            percent_difference < 0.03
       Bad KPI:
            percent_difference >= 0.03

       Arrows:
            ▲ for increase
            ▼ for decrease

---------------------------------------------------------------------------------------*/
kpi_output AS (
    SELECT
        current_month,
        previous_month,
        current_month_aqi,
        previous_month_aqi,
        percent_difference,

        -------------------------------------------------------------------------------
        -- Good Percentage KPI Output
        -------------------------------------------------------------------------------
        CASE
            WHEN percent_difference < 0.03 THEN
                CASE 
                    WHEN percent_difference > 0 THEN
                        CONCAT('▲ ', ROUND(percent_difference * 100, 2), '%')
                    ELSE
                        CONCAT('▼ ', ROUND(ABS(percent_difference) * 100, 2), '%')
                END
            ELSE ''
        END AS good_percentage_kpi,

        -------------------------------------------------------------------------------
        -- Bad Percentage KPI Output
        -------------------------------------------------------------------------------
        CASE
            WHEN percent_difference >= 0.03 THEN
                CASE 
                    WHEN percent_difference > 0 THEN
                        CONCAT('▲ ', ROUND(percent_difference * 100, 2), '%')
                    ELSE
                        CONCAT('▼ ', ROUND(ABS(percent_difference) * 100, 2), '%')
                END
            ELSE ''
        END AS bad_percentage_kpi

    FROM difference_calc
)

-- =====================================================================================
--  FINAL KPI RESULT
-- =====================================================================================
SELECT *
FROM kpi_output;

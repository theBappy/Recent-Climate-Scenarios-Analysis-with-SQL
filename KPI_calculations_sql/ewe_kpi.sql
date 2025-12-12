/*=====================================================================================
    File:           ewe_kpi.sql
    Purpose:        KPI development for Extreme Weather Events (EWE)
    Description:    Computes:
                        - Count of EWE
                        - Current Month EWE
                        - Previous Month EWE
                        - Percent Difference EWE
                        - Good / Bad KPI Indicators (▲ / ▼)
    Author:         <your name>
    Last Updated:   <date>
======================================================================================*/

/*--------------------------------------------------------------------------------------
    1. PARAMETERS
       Replace @current_month with a date parameter (first day of the month).
---------------------------------------------------------------------------------------*/

DECLARE @current_month DATE = '2024-08-01';   -- <-- set target month


/*--------------------------------------------------------------------------------------
    2. BASE TABLE
       Expected fields:
         - extreme_weather_events (string)
         - date
---------------------------------------------------------------------------------------*/

-- Example base table:
-- SELECT * FROM weather_events_data;


/*--------------------------------------------------------------------------------------
    3. DATE LOGIC
       Calculate previous month based on the selected current month.
---------------------------------------------------------------------------------------*/
WITH date_context AS (
    SELECT
        @current_month AS current_month,
        DATEADD(MONTH, -1, @current_month) AS previous_month
),


/*--------------------------------------------------------------------------------------
    4. FLAG EXTREME WEATHER EVENTS
       Count event as 1 if NOT "None", else 0.
---------------------------------------------------------------------------------------*/
ewe_flag AS (
    SELECT
        date,
        CASE 
            WHEN extreme_weather_events <> 'None' THEN 1 
            ELSE 0 
        END AS ewe_count
    FROM weather_events_data
),


/*--------------------------------------------------------------------------------------
    5. CURRENT AND PREVIOUS MONTH EWE
       Aggregate EWE counts per month.
---------------------------------------------------------------------------------------*/
monthly_ewe AS (
    SELECT
        dc.current_month,
        dc.previous_month,

        -- Current Month Count of EWE
        (
            SELECT SUM(e.ewe_count)
            FROM ewe_flag e
            WHERE DATEFROMPARTS(YEAR(e.date), MONTH(e.date), 1) = dc.current_month
        ) AS current_month_ewe,

        -- Previous Month Count of EWE
        (
            SELECT SUM(e.ewe_count)
            FROM ewe_flag e
            WHERE DATEFROMPARTS(YEAR(e.date), MONTH(e.date), 1) = dc.previous_month
        ) AS previous_month_ewe

    FROM date_context dc
),


/*--------------------------------------------------------------------------------------
    6. PERCENT DIFFERENCE
       Formula:
            (Current − Previous) / Previous
---------------------------------------------------------------------------------------*/
difference_calc AS (
    SELECT
        current_month,
        previous_month,
        current_month_ewe,
        previous_month_ewe,

        CASE
            WHEN previous_month_ewe = 0 THEN NULL
            ELSE (current_month_ewe - previous_month_ewe) * 1.0 / previous_month_ewe
        END AS percent_difference
    FROM monthly_ewe
),


/*--------------------------------------------------------------------------------------
    7. KPI LABELS (GOOD / BAD)
       Bad KPI:
            percent_difference > 0
       Good KPI:
            percent_difference < 0

       Arrow rules:
            ▲ = increase
            ▼ = decrease
---------------------------------------------------------------------------------------*/
kpi_output AS (
    SELECT
        current_month,
        previous_month,
        current_month_ewe,
        previous_month_ewe,
        percent_difference,

        -----------------------------------------------------------------------
        -- Bad KPI (More EWE = Bad)
        -----------------------------------------------------------------------
        CASE
            WHEN percent_difference > 0 THEN
                CONCAT('▲ ', ROUND(percent_difference * 100, 2), '%')
            ELSE ''
        END AS bad_kpi_ewe,

        -----------------------------------------------------------------------
        -- Good KPI (Less EWE = Good)
        -----------------------------------------------------------------------
        CASE
            WHEN percent_difference < 0 THEN
                CONCAT('▼ ', ROUND(ABS(percent_difference) * 100, 2), '%')
            ELSE ''
        END AS good_kpi_ewe

    FROM difference_calc
)


-- =====================================================================================
--  FINAL KPI OUTPUT
-- =====================================================================================
SELECT *
FROM kpi_output;

/*=====================================================================================
    File:           precipitation_intensity_kpi.sql
    Purpose:        KPI development for Precipitation Intensity
    Description:    Computes:
                        - Average Precipitation Intensity
                        - Current Month Precipitation Intensity
                        - Previous Month Precipitation Intensity
                        - Percent Difference
                        - Good / Bad KPI Indicators (▲ / ▼)
    Author:         <your name>
    Last Updated:   <date>
======================================================================================*/

/*--------------------------------------------------------------------------------------
    1. PARAMETER
       Replace @current_month with a date parameter (first day of month).
---------------------------------------------------------------------------------------*/

DECLARE @current_month DATE = '2024-08-01';   -- <-- update for deployment


/*--------------------------------------------------------------------------------------
    2. BASE TABLE
       Expected fields:
         - precipitation (numeric)
         - date
---------------------------------------------------------------------------------------*/

-- Example:
-- SELECT * FROM precipitation_data;


/*--------------------------------------------------------------------------------------
    3. DATE CONTEXT
       Determine previous month from current month.
---------------------------------------------------------------------------------------*/
WITH date_context AS (
    SELECT
        @current_month AS current_month,
        DATEADD(MONTH, -1, @current_month) AS previous_month
),


/*--------------------------------------------------------------------------------------
    4. MONTHLY PRECIPITATION INTENSITY
       Average precipitation per month.
---------------------------------------------------------------------------------------*/
monthly_precip AS (
    SELECT
        dc.current_month,
        dc.previous_month,

        -- Current Month Precipitation Intensity
        (
            SELECT AVG(p.precipitation)
            FROM precipitation_data p
            WHERE DATEFROMPARTS(YEAR(p.date), MONTH(p.date), 1) = dc.current_month
        ) AS current_month_precip,

        -- Previous Month Precipitation Intensity
        (
            SELECT AVG(p.precipitation)
            FROM precipitation_data p
            WHERE DATEFROMPARTS(YEAR(p.date), MONTH(p.date), 1) = dc.previous_month
        ) AS previous_month_precip

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
        current_month_precip,
        previous_month_precip,

        CASE
            WHEN previous_month_precip = 0 THEN NULL
            ELSE (current_month_precip - previous_month_precip) * 1.0 / previous_month_precip
        END AS percent_difference
    FROM monthly_precip
),


/*--------------------------------------------------------------------------------------
    6. KPI THRESHOLD LOGIC
       Thresholds:
           - Bad:  <= -2%   OR   >= 2%
           - Good: between -2% and +2%
       Arrows:
           ▲ = increase
           ▼ = decrease
---------------------------------------------------------------------------------------*/
kpi_output AS (
    SELECT
        current_month,
        previous_month,
        current_month_precip,
        previous_month_precip,
        percent_difference,

        -------------------------------------------------------------------------------
        -- BAD KPI (outside ±2%)
        -------------------------------------------------------------------------------
        CASE
            WHEN percent_difference <= -0.02 OR percent_difference >= 0.02 THEN
                CASE
                    WHEN percent_difference > 0 THEN
                        CONCAT('▲ ', ROUND(percent_difference * 100, 2), '%')
                    ELSE
                        CONCAT('▼ ', ROUND(ABS(percent_difference) * 100, 2), '%')
                END
            ELSE
                ''
        END AS bad_precip_kpi,

        -------------------------------------------------------------------------------
        -- GOOD KPI (within ±2%)
        -------------------------------------------------------------------------------
        CASE
            WHEN percent_difference > -0.02 AND percent_difference < 0.02 THEN
                CASE
                    WHEN percent_difference > 0 THEN
                        CONCAT('▲ ', ROUND(percent_difference * 100, 2), '%')
                    ELSE
                        CONCAT('▼ ', ROUND(ABS(percent_difference) * 100, 2), '%')
                END
            ELSE
                ''
        END AS good_precip_kpi

    FROM difference_calc
)


-- =====================================================================================
--  FINAL KPI OUTPUT
-- =====================================================================================
SELECT *
FROM kpi_output;

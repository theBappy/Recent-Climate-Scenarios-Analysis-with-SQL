/*=====================================================================================
    File:           temperature_kpi.sql
    Purpose:        KPI development for Temperature
    Description:    Computes:
                        - Avg Temperature
                        - Current Month Temperature
                        - Previous Month Temperature
                        - Percent Difference
                        - Good / Bad KPI Indicators (▲ / ▼)
    Author:         <your name>
    Last Updated:   <date>
======================================================================================*/

/*--------------------------------------------------------------------------------------
    1. PARAMETER
       Replace @current_month with the first day of the target month.
---------------------------------------------------------------------------------------*/

DECLARE @current_month DATE = '2024-08-01';   -- <-- modify for deployment


/*--------------------------------------------------------------------------------------
    2. BASE TABLE
       Expected fields:
            - temperature  (numeric)
            - date         (date/datetime)
---------------------------------------------------------------------------------------*/

-- Example:
-- SELECT * FROM temperature_data;


/*--------------------------------------------------------------------------------------
    3. DATE LOGIC
       Determine previous month.
---------------------------------------------------------------------------------------*/
WITH date_context AS (
    SELECT
        @current_month AS current_month,
        DATEADD(MONTH, -1, @current_month) AS previous_month
),


/*--------------------------------------------------------------------------------------
    4. MONTHLY TEMPERATURE (Aggregated)
---------------------------------------------------------------------------------------*/
monthly_temp AS (
    SELECT
        dc.current_month,
        dc.previous_month,

        -- Current Month Avg Temperature
        (
            SELECT AVG(t.temperature)
            FROM temperature_data t
            WHERE DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1) = dc.current_month
        ) AS current_month_temp,

        -- Previous Month Avg Temperature
        (
            SELECT AVG(t.temperature)
            FROM temperature_data t
            WHERE DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1) = dc.previous_month
        ) AS previous_month_temp

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
        current_month_temp,
        previous_month_temp,

        CASE
            WHEN previous_month_temp = 0 THEN NULL
            ELSE (current_month_temp - previous_month_temp) * 1.0 / previous_month_temp
        END AS percent_difference
    FROM monthly_temp
),


/*--------------------------------------------------------------------------------------
    6. KPI LABELING
       Logic:
           - BAD KPI: absolute change >= 3%
           - GOOD KPI: absolute change < 3%

       Threshold = ±0.03  (3%)
       Arrows:
           ▲ increase
           ▼ decrease
---------------------------------------------------------------------------------------*/
kpi_output AS (
    SELECT
        current_month,
        previous_month,
        current_month_temp,
        previous_month_temp,
        percent_difference,

        ---------------------------------------------------------------------------
        -- BAD KPI (outside ±3%)
        ---------------------------------------------------------------------------
        CASE
            WHEN percent_difference >= 0.03 OR percent_difference <= -0.03 THEN
                CASE
                    WHEN percent_difference > 0 THEN
                        CONCAT('▲ ', ROUND(percent_difference * 100, 2), '%')
                    ELSE
                        CONCAT('▼ ', ROUND(ABS(percent_difference) * 100, 2), '%')
                END
            ELSE ''
        END AS bad_temp_kpi,

        ---------------------------------------------------------------------------
        -- GOOD KPI (within ±3%)
        ---------------------------------------------------------------------------
        CASE
            WHEN percent_difference > -0.03 AND percent_difference < 0.03 THEN
                CASE
                    WHEN percent_difference > 0 THEN
                        CONCAT('▲ ', ROUND(percent_difference * 100, 2), '%')
                    ELSE
                        CONCAT('▼ ', ROUND(ABS(percent_difference) * 100, 2), '%')
                END
            ELSE ''
        END AS good_temp_kpi

    FROM difference_calc
)


-- =====================================================================================
-- FINAL OUTPUT
-- =====================================================================================
SELECT *
FROM kpi_output;

/*=====================================================================================
    File:           temperature_variability_kpi.sql
    Purpose:        KPI development for Temperature Variability (STDEV)
    Description:    Computes:
                        - Temperature Variability (STDEV)
                        - Current Month Variability
                        - Previous Month Variability
                        - Percent Difference
                        - Good / Bad KPI Indicators (▲ / ▼)
    Author:         <your name>
    Last Updated:   <date>
======================================================================================*/

/*--------------------------------------------------------------------------------------
    1. PARAMETER
       Replace @current_month with first day of target month.
---------------------------------------------------------------------------------------*/
DECLARE @current_month DATE = '2024-08-01';   -- <-- adjust as needed


/*--------------------------------------------------------------------------------------
    2. BASE TABLE
       Expected fields:
            - temperature  (numeric)
            - date         (date/datetime)
---------------------------------------------------------------------------------------*/

-- Example:
-- SELECT * FROM temperature_data;


/*--------------------------------------------------------------------------------------
    3. DATE CONTEXT
       Determine previous month
---------------------------------------------------------------------------------------*/
WITH date_context AS (
    SELECT
        @current_month AS current_month,
        DATEADD(MONTH, -1, @current_month) AS previous_month
),


/*--------------------------------------------------------------------------------------
    4. MONTHLY TEMPERATURE VARIABILITY
       Compute standard deviation (STDEV) per month
---------------------------------------------------------------------------------------*/
monthly_variability AS (
    SELECT
        dc.current_month,
        dc.previous_month,

        -- Current Month Variability
        (
            SELECT STDEV(t.temperature)
            FROM temperature_data t
            WHERE DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1) = dc.current_month
        ) AS current_month_variability,

        -- Previous Month Variability
        (
            SELECT STDEV(t.temperature)
            FROM temperature_data t
            WHERE DATEFROMPARTS(YEAR(t.date), MONTH(t.date), 1) = dc.previous_month
        ) AS previous_month_variability

    FROM date_context dc
),


/*--------------------------------------------------------------------------------------
    5. PERCENT DIFFERENCE
       Formula: (Current − Previous) / Previous
---------------------------------------------------------------------------------------*/
difference_calc AS (
    SELECT
        current_month,
        previous_month,
        current_month_variability,
        previous_month_variability,

        CASE
            WHEN previous_month_variability = 0 THEN NULL
            ELSE (current_month_variability - previous_month_variability) * 1.0 / previous_month_variability
        END AS percent_difference
    FROM monthly_variability
),


/*--------------------------------------------------------------------------------------
    6. KPI LABELING
       Thresholds:
           - Bad KPI: >= 1% (0.01)
           - Good KPI: < 1% (0.01)
       Arrows:
           ▲ = increase
           ▼ = decrease
---------------------------------------------------------------------------------------*/
kpi_output AS (
    SELECT
        current_month,
        previous_month,
        current_month_variability,
        previous_month_variability,
        percent_difference,

        ---------------------------------------------------------------------------
        -- BAD KPI (>= 1%)
        ---------------------------------------------------------------------------
        CASE
            WHEN percent_difference >= 0.01 THEN
                CASE
                    WHEN percent_difference > 0 THEN
                        CONCAT('▲ ', ROUND(percent_difference * 100, 2), '%')
                    ELSE
                        CONCAT('▼ ', ROUND(ABS(percent_difference) * 100, 2), '%')
                END
            ELSE ''
        END AS bad_temp_variability_kpi,

        ---------------------------------------------------------------------------
        -- GOOD KPI (< 1%)
        ---------------------------------------------------------------------------
        CASE
            WHEN percent_difference < 0.01 THEN
                CASE
                    WHEN percent_difference > 0 THEN
                        CONCAT('▲ ', ROUND(percent_difference * 100, 2), '%')
                    ELSE
                        CONCAT('▼ ', ROUND(ABS(percent_difference) * 100, 2), '%')
                END
            ELSE ''
        END AS good_temp_variability_kpi

    FROM difference_calc
)


-- =====================================================================================
-- FINAL OUTPUT
-- =====================================================================================
SELECT *
FROM kpi_output;

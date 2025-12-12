

# 🌍 Recent Climate Isssue Analysis
<img width="1024" height="1024" alt="Frame 95" src="https://github.com/user-attachments/assets/5aca266a-29e5-43c3-873d-5accec71a66e" />

---
A global research institution is studying the impact of climate change across different regions. The institution requires a **centralized system** to: <r> 
## **Project Overview**

- 🌡️ Track key climate indicators (temperature, precipitation, air quality)  
- 🌪️ Monitor extreme weather events (hurricanes, heatwaves, droughts)  
- 🏗️💰 Analyze economic and infrastructural impacts of climate events  

**Goal:** Provide researchers and policymakers with **accurate, timely insights** into climate trends and vulnerabilities.

---

## **Business Problem**

### **1️⃣ Tracking Climate Trends**
- Data is scattered across multiple sources  
- Difficulty in analyzing temperature, air quality, and precipitation over time  

### **2️⃣ Generating Reports Efficiently**
- Manual reporting consumes time ⏳  
- Delays decision-making  

### **3️⃣ Assessing Climate Risks**
- No structured model to assess economic and infrastructure impact  
- Hard to prioritize mitigation strategies  

---

## **Proposed Solution**

A **data-driven climate monitoring solution** that delivers:

- 💾 **Centralized Data Repository**  
- 📝 **Automated KPI & reporting system**  
- 📈 **Real-time climate dashboards**  
- 🏗️ **Economic & infrastructure impact models**  

**Outcome:** Faster climate insights for informed decisions.  

---

## **Data Analysis Scope**

- **Countries:** Australia, Canada, USA, India, Germany, Brazil, South Africa  
- **Tasks:**  
  - ETL  
  - Data cleaning  
  - Data normalization  
  - KPI calculations  
  - Tableau dashboards  

---

## **Risk Analysis**

- **Tasks:**  
  - Infrastructure Impact 
  - Economic Hazards  
  - Extreme Events  

---

## **Tableu Viz**

- **All kpi's and risk analytical filtering viz**  
  - Visit Link: https://public.tableau.com/app/profile/the.bappy/viz/RecentClimateChangeAnalysis/Dashboard1  

---

## **Folder Structure**

<table border="1" cellpadding="8" cellspacing="0">
<tr style="background-color:#4CAF50; color:white;"><th>Folder</th><th>Description</th></tr>

<tr><td>backup_data</td><td>Backup of raw datasets for recovery</td></tr>

<tr><td>data_cleaning_sql <span style="color:#f34b7d;">💻 SQL</span></td>
<td>Scripts for data cleaning and normalization</td></tr>

<tr><td>icon_used 🖼️</td><td>Icons used in dashboards & documentation</td></tr>

<tr><td>KPI_calculations_sql <span style="color:#f34b7d;">💻 SQL</span></td>
<td>SQL scripts for KPI generation</td></tr>

<tr><td>pblm_statement_with_metadata 📄</td>
<td>Problem statement & metadata</td></tr>

<tr><td>queries_validation <span style="color:#f34b7d;">💻 SQL</span></td>
<td>SQL scripts to validate data accuracy</td></tr>

<tr><td>risk_impact_analysis_sql <span style="color:#f34b7d;">💻 SQL</span></td>
<td>Economic & infrastructure risk analysis queries</td></tr>

<tr><td>tableu_viz 📊 Tableau</td>
<td>Tableau dashboards of climate trends</td></tr>

<tr><td>weather_data_csv 📁 CSV</td>
<td>Raw CSV datasets</td></tr>

</table>

---

🧩 Business Problem<br>
1️⃣ Climate Trends Are Hard to Track<br>
Data exists in multiple unconnected sources<br>
Hard to analyze multi-year weather anomalies<br>
2️⃣ Manual Reporting Creates Delays<br>
No automation<br>
High dependency on manual work<br>
3️⃣ Climate Risk Analysis Is Limited<br>
No structured economic impact framework<br> 
Hard to categorize high-risk regions<br>
<br>
✅ Proposed Solution<br>
💾 Centralized Data Warehouse<br>
📘 Automated KPI Reporting<br>
📊 Interactive Tableau Dashboards<br>
🏗️ Economic & Infrastructure Impact Analysis<br>

**Version:** 1.0  
**Date:** 12-Dec-2025  
**Prepared by:** theBappy  


## **Example KPI**

### **1️⃣ Clean & Normalize Temperature Data**
```sql
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

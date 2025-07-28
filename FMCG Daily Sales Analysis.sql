SELECT *
FROM fmcg_2022_2024;

/* find which region has more sales */
SELECT region,
	ROUND(sum(price_unit * units_sold), 2) AS total_sales,
    count(region)
FROM fmcg_2022_2024
GROUP BY region
ORDER BY total_sales DESC;

/* see which category more sales  */
SELECT category,
	ROUND(sum(price_unit * units_sold), 2) AS total_sales,
    count(category)
FROM fmcg_2022_2024
GROUP BY category
ORDER BY total_sales ASC;

-- Project starts
SELECT *
FROM fmcg_2022_2024;

/* Phase 1: Data Quality Audit, Data Cleaning */
-- a. Check for NULL values for specific key columns

SELECT count(*)
FROM fmcg_2022_2024
WHERE price_unit IS NULL or TRIM(price_unit) = '';

SELECT count(*)
FROM fmcg_2022_2024
WHERE `date` IS NULL or TRIM(price_unit) = '';

SELECT count(*)
FROM fmcg_2022_2024
WHERE `sku` IS NULL or TRIM(price_unit) = '';
-- Conclusion: No NULL or missing values for key columns above


-- b. Check for duplicate values for specific key columns
SELECT `date`, sku, `channel`, region, count(*)
FROM fmcg_2022_2024
GROUP BY `date`, sku, `channel`, region
HAVING count(*) > 1;
-- Conclusion: No duplicated values for key columns above

-- c. Scan for unreasonable values like negative price or having a value of not 0 or 1 for promotion_flag
SELECT *
FROM fmcg_2022_2024
WHERE price_unit < 0 
	OR promotion_flag NOT IN ('0', '1');
-- Conclusion: No unreasonable values in the dataset

-- d. Check if the data types for each column is correct
DESCRIBE fmcg_2022_2024;

-- Most are correct except `date` is stored as text, need to change data type
-- Double check: Convert textdate to proper date type
UPDATE fmcg_2022_2024
SET `date` = str_to_date(`date`, '%Y-%m-%d')
WHERE str_to_date(`date`, '%Y-%m-%d') IS NOT NULL;

-- Alter column datatype
ALTER TABLE fmcg_2022_2024
MODIFY `date` DATE;

-- Double check that `date` data type has been changed
-- d. Check if the data types for each column is correct
DESCRIBE fmcg_2022_2024;

/* Data cleaning complete. Now move on to Exploratory Data Analysis (EDA) */

/* Phase 2: SQL EDA */

-- a. Monthy sales volume trends over time
SELECT YEAR(date) AS Year, MONTH(date) AS Month,
	SUM(units_sold) as total_units_sold
FROM fmcg_2022_2024
GROUP BY YEAR(date), MONTH(date)
ORDER By Year, Month;
-- At first glance, 2022 Jan & Feb had worse sales at 4 figure volume. Where 2023 & 2024 May - July had the highest volume

-- Top and bottom SKUs and Brands
-- For Top 10:
SELECT sku, SUM(units_sold) as total_units_sold
FROM fmcg_2022_2024
GROUP BY sku
ORDER BY total_units_sold DESC
LIMIT 10;
-- YO-029, -005, -012 are the top 3 at around 170,000 each

-- For Bottom 10:
SELECT sku, SUM(units_sold) as total_units_sold
FROM fmcg_2022_2024
GROUP BY sku
ORDER BY total_units_sold ASC
LIMIT 10;
-- MI-008, -011, -002 are the bottom 3 at around 85,000 each


-- b. Channel and region performance
SELECT channel, region, SUM(units_sold) as total_units_sold
FROM fmcg_2022_2024
GROUP BY channel, region
ORDER BY total_units_sold DESC;
-- Across all channels and regions, the sales volume are very similar at around 420,000

-- c. Overview Promotion Impact
-- Check that for the days having promotion, whether it is boosting the sales per daily basis
SELECT sku, promotion_flag, SUM(units_sold) as total_units_sold
FROM fmcg_2022_2024
GROUP BY sku, promotion_flag
ORDER BY sku ASC;
-- At first glance, it seems that promotions do not boost but decreases sale volume. But this is not a good comparison.
-- We can further filter on the number of days each item is sold with or without promotions, then calculate the sales volume per day

WITH promotion_sales AS (
	SELECT sku, promotion_flag, SUM(units_sold) as total_units_sold, count(date) as number_of_days
	FROM fmcg_2022_2024
	GROUP BY sku, promotion_flag
	ORDER BY sku ASC
)
SELECT *, 
ROUND((total_units_sold / number_of_days), 2) as units_per_day
FROM promotion_sales;
-- It is now clearly seen that on the days having promotions, the sales volume nearly doubled.
-- We can further check how much difference the average unit price that made such a big jump in sales.

WITH promotion_sales AS (
	SELECT sku, promotion_flag, ROUND(AVG(price_unit), 2) as avg_price, SUM(units_sold) as total_units_sold, count(date) as number_of_days
	FROM fmcg_2022_2024
	GROUP BY sku, promotion_flag
	ORDER BY sku ASC
)
SELECT *, 
ROUND((total_units_sold / number_of_days), 2) as units_per_day
FROM promotion_sales
WHERE sku IN ('YO-029', 'YO-005', 'YO-012', 'MI-008', 'MI-011', 'MI-002')
ORDER BY sku, total_units_sold ASC;
-- Surprisingly, there is not much difference in the avg_price between the days of having or not having a promotion.
-- On some days the promotional price is even higher than normal price, yet the sales doubled up.
-- This shows that consumers are driven by the attractive promotional marketing campaigns instead of actually comparing the prices.


-- (Archived) d. Detect sales spikes / Outliers by comparing week-over-week sales
-- Export as csv for Power BI to visualize
WITH weekly_data AS (
	SELECT YEAR(`date`) as year,WEEK(`date`) as week, sku, region, sum(units_sold) as weekly_sales
	FROM fmcg_2022_2024
	GROUP BY year, week, sku, region
)
SELECT year, week, sku, region, weekly_sales,
	weekly_sales - LAG(weekly_sales) OVER (PARTITION BY sku, region ORDER BY year, week) as weekly_diff
FROM weekly_data
ORDER BY year, week;


-- d. RFM Analysis
WITH customer_rfm AS (
    SELECT 
        sku,
        region,
        DATEDIFF(CURDATE(), MAX(date)) AS recency,
        COUNT(DISTINCT date) AS frequency,
        SUM(price_unit * units_sold) AS monetary
    FROM fmcg_2022_2024
    GROUP BY sku, region
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM customer_rfm
)
SELECT *, 
    CONCAT(r_score, f_score, m_score) AS rfm_segment
FROM rfm_scores;





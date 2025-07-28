# FMCG 2022-2024 Daily Sales Insights | MySQL & Power BI

## Executive Summary

This project analyzes **FMCG sales data from 2022-2024** to reveal actionable insights for retail strategy and marketing optimization. Key findings show that **promotions nearly double daily sales volume** despite minimal price differences, **regional performance remains surprisingly consistent** across all channels, and **specific SKUs dominate with 170,000+ units sold** while others lag at 85,000 units.

**Business Impact**: Enables data-driven promotion strategies, inventory optimization, and regional resource allocation.

## Table of Contents

- [Executive Summary](#executive-summary)
- [Business Context & Project Workflow](#business-context--project-workflow)
- [Dataset Overview](#dataset-overview)
- [Data Quality & Reliability](#data-quality--reliability)
- [Analysis 1: Sales Trends & Seasonality](#analysis-1-sales-trends--seasonality)
- [Analysis 2: Regional and Category Performance](#analysis-2-regional-and-category-performance)
- [Analysis 3: Promotion Effectiveness](#analysis-3-promotion-effectiveness)
- [Analysis 4: Outlier & Anomaly Detection](#analysis-4-outlier--anomaly-detection)
- [Interactive Exploration](#interactive-exploration)
- [Key Insights & Business Recommendations](#key-insights--business-recommendations)
- [Skills Demonstrated](#skills-demonstrated)
- [Project Files & Access](#project-files--access)
- [Conclusion](#conclusion)

## Business Context & Project Workflow
FMCG companies struggle with promotion ROI measurement, regional performance gaps, and inventory optimization across multiple channels. This analysis transforms raw sales data into strategic insights for marketing and operations teams.

### Integrated Analytical Approach
This project leverages **MySQL for data foundation** and **Power BI for strategic visualization** - each tool applied where it delivers maximum value:

- **MySQL handles**: Data quality audits, temporal aggregations, promotion impact calculations, and outlier detection
- **Power BI extends**: Interactive trend exploration, comparative visualizations, executive dashboards, and scenario analysis

**Workflow**: Raw Data → SQL Cleaning & Validation → SQL Business Logic → Power BI Interactive Insights → Strategic Recommendations

This integrated approach ensures robust data integrity while delivering executive-ready visualizations for immediate business action.

## Dataset Overview

**Source**: [Kaggle - FMCG Daily Sales Data 2022-2024](https://www.kaggle.com/datasets/beatafaron/fmcg-daily-sales-data-to-2022-2024/data?select=FMCG_2022_2024.csv)

Below is a screenshot of how the raw dataset looks like.

<img width="1080" height="161" alt="image" src="https://github.com/user-attachments/assets/d3bd76dc-a647-4810-bf92-e71d3bf65370" />

**Key Statistics**: 3-year timespan (2022-2024) | 170,000+ daily transactions | Multi-dimensional product hierarchy | 3 sales channels | 3 regional markets

This synthetic dataset simulates real-world FMCG sales scenarios with comprehensive business dimensions:

**Product Hierarchy**: SKU → Brand → Segment → Category  
**Sales Channels**: Retail, Discount, E-commerce  
**Geographic Coverage**: Central, North, and South regions (Poland)  
**Key Metrics**: Daily sales quantities, unit prices, promotion flags, stock levels, delivery lead times


## Data Quality & Reliability

Before conducting business analysis, comprehensive data quality validation ensures reliable insights. This audit covers NULL values, duplicates, unreasonable entries, and proper data types.

### a. NULL Values Assessment

**Key Columns Validation**: Price, Date, and SKU integrity check

```sql
-- Check for NULL or empty price values
SELECT count(*)
FROM fmcg_2022_2024
WHERE price_unit IS NULL or TRIM(price_unit) = '';
```

Below is the output:

<img width="198" height="134" alt="image" src="https://github.com/user-attachments/assets/32945315-ae88-43ab-8d57-ed598554f36a" />

**Result**: `0` - It means no missing price data.

The same query was applied to date and sku columns, and the results were 0 for both queries. There was no NULL or missing values in the dataset.

### b. Duplicate Records Detection

```sql
-- Identify potential duplicates across key business dimensions
SELECT date, sku, channel, region, count()
FROM fmcg_2022_2024
GROUP BY date, sku, channel, region
HAVING count() > 1;
```

Below is the output: 

<img width="538" height="140" alt="image" src="https://github.com/user-attachments/assets/dfdaeea1-349e-406f-ac3d-815552f5121b" />

No results are shown. It means there are no duplicated rows across the dataset.

### c. Unreasonable Values Validation

```sql
-- Scan for negative price and having a value of other than 0 or 1 on promotion_flag
SELECT *
FROM fmcg_2022_2024
WHERE price_unit < 0
OR promotion_flag NOT IN ('0', '1');
```
Below is the output:

<img width="1764" height="132" alt="image" src="https://github.com/user-attachments/assets/62d74557-42a3-4d0d-ab80-908686c59314" />

No results are shown. There are no unreasonable values across the dataset.

### d. Data Type Optimization

```sql
-- Check current data types
DESCRIBE fmcg_2022_2024;
```
Below is the output:

<img width="610" height="246" alt="image" src="https://github.com/user-attachments/assets/fa702f97-059a-45e2-ad7b-fbb4cc0f75c5" />

It shows that the 'date' column is stored as `text` instead of the proper `date` column.

So, I converted the dates to proper format:

```sql
-- Convert text dates to proper date format
UPDATE fmcg_2022_2024
SET date = str_to_date(date, '%Y-%m-%d')
WHERE str_to_date(date, '%Y-%m-%d') IS NOT NULL;

-- Alter column to DATE data type
ALTER TABLE fmcg_2022_2024
MODIFY date DATE;
```

Below is the output:

<img width="602" height="242" alt="image" src="https://github.com/user-attachments/assets/d1ffb716-781b-49f0-8ff2-547e760981fb" />

It is obvious that the data type of 'date' has been changed.

### Data Quality Conclusion
1. **Zero NULL values** in critical business columns  
2. **No duplicate transactions** across key dimensions  
3. **All values within business logic** parameters  
4. **Optimized data types** for efficient analysis  

The dataset is now clean and ready for further analysis.

## Analysis 1: Sales Trends & Seasonality

### Business Question
Understanding sales patterns over time and identifying high/low performing products is crucial for inventory planning, marketing campaigns, and resource allocation. I analyzed monthly sales trends from 2022-2024 and SKU performance to reveal seasonal patterns and product concentration.

### Monthly Sales Volume Analysis

I started by examining sales trends across the three-year period to identify seasonal patterns and year-over-year changes.

```sql
-- Monthly sales volume trends over time
SELECT YEAR(date) AS Year, MONTH(date) AS Month,
SUM(units_sold) as total_units_sold
FROM fmcg_2022_2024
GROUP BY YEAR(date), MONTH(date)
ORDER By Year, Month;
```
Below is the output (partial data):

<img width="424" height="722" alt="image" src="https://github.com/user-attachments/assets/4d46ef84-95a4-4967-a42b-a95cac7a6eb6" />


The SQL results immediately revealed seasonal patterns. At first glance, 2022 January and February had worse sales at 4-figure volume, while 2023 and 2024 May-July periods showed the highest volume across all years.

**Power BI Enhancement**: I created a line chart with months on the x-axis, total units sold on the y-axis, and separate lines for each year as the legend. This visualization confirmed the SQL findings and revealed additional insights that weren't immediately obvious from the raw data.

<img width="798" height="571" alt="image" src="https://github.com/user-attachments/assets/ab031032-b894-49ca-9d23-8c52a9240273" />

The Power BI line chart showed a clear **mid-year sales peak between June-August** across all three years, validating the SQL observation about May-July being the strongest periods. However, the visualization uncovered an important trend difference: while 2022 sales continued trending upward from October-December, both 2023 and 2024 showed declining sales toward Q4.

### SKU Performance Analysis

I then identified the top and bottom performing products to understand sales concentration and potential inventory optimization opportunities.

```sql
-- Top 10 performing SKUs
SELECT sku, SUM(units2022_2024
GROUP BY sku
ORDER BY total_units_sold DESC
LIMIT 10;

-- Bottom 10 performing SKUs
SELECT sku, SUM(units_sold) as total_units_sold
FROM fmcg_2022_2024
GROUP BY sku
ORDER BY total_units_sold ASC
LIMIT 10;
```

Below are the outputs - Top 10:

<img width="350" height="378" alt="image" src="https://github.com/user-attachments/assets/b29cad2c-c798-4dc9-bf9b-cad16654f4c6" />

Bottom 10:

<img width="350" height="380" alt="image" src="https://github.com/user-attachments/assets/f5ac7849-3bcd-4762-bc81-71f41bb37c3c" />

The SQL analysis showed clear performance concentration. YO-029, YO-005, and YO-012 emerged as the top 3 performers with around 170,000 units each, while MI-008, MI-011, and MI-002 were the bottom 3 at around 85,000 units each.

**Power BI Enhancement**: I created a bubble chart where each SKU is represented by a bubble, with total units sold on the x-axis, average price on the y-axis, and bubble size representing total revenue contribution. This multi-dimensional view provided richer context than the SQL rankings alone.

<img width="887" height="583" alt="image" src="https://github.com/user-attachments/assets/8acc21d7-8a4f-421f-b06f-3778099fcdf6" />

The bubble chart visually confirmed the SQL findings - the three largest bubbles (representing highest revenue) appeared on the right side of the chart, corresponding to the top-performing SKUs identified in SQL. Conversely, the small bubbles clustered on the left side matched the bottom performers from the SQL analysis.

### Business Insights & Recommendations

- **Summer Peak Optimization**: The consistent June-August sales surge across all years suggests strong seasonal demand. I recommend increasing inventory levels and marketing spend during Q2 to capitalize on this pattern.
- **Q4 Trend Concern**: The declining Q4 performance in 2023-2024 (contrasting with 2022's growth) indicates potential market saturation or competitive pressure. This warrants investigation into promotional strategies or product refresh cycles.
- **SKU Rationalization Opportunity**: Bottom-performing SKUs like the MI series may require strategic review - either through enhanced marketing, price adjustments, or potential discontinuation to optimize inventory costs.

## Analysis 2: Regional and Category Performance

### Business Question
Understanding performance variations across sales channels and geographic regions is essential for resource allocation, inventory distribution, and channel strategy optimization. I analyzed sales performance by channel-region combinations and product hierarchy to identify potential market opportunities and operational efficiencies.

### Channel and Regional Sales Analysis

I examined sales distribution across all channel-region combinations to identify high-performing markets and potential geographic expansion opportunities.

```sql
-- Channel and regional performance analysis
SELECT channel, region, SUM(units_sold) as total_units_sold
FROM fmcg_2022_2024
GROUP BY channel, region
ORDER BY total_units_sold DESC;
```

Below is the output:

<img width="526" height="338" alt="image" src="https://github.com/user-attachments/assets/3b2efa5a-c8a5-4a6a-8974-4cf94fe0df97" />

The SQL results revealed a striking pattern. Across all channels and regions, the sales volumes were remarkably similar at around 420,000 units each. This uniformity was initially surprising, as most FMCG markets typically show significant regional or channel variations.

**Power BI Enhancement**: I created a decomposition tree visualization starting with total units sold at the root, then drilling down through channel, region, brand, and finally SKU levels. This interactive hierarchy allowed me to explore the underlying drivers of performance across different business dimensions.

The image below shows the decomposition tree drilling down **E-commerce -> PL-South -> SnBrand2**:

<img width="1080" height="779" alt="image" src="https://github.com/user-attachments/assets/dc19d8a3-656c-48aa-8e53-4f169dbc4d02" />

The image below shows the decomposition tree drilling down **Discount -> PL-Central -> SnBrand2**:

<img width="1262" height="924" alt="image" src="https://github.com/user-attachments/assets/8ba03f41-b9a7-4bc6-9aee-bcd29bdcab6e" />

The decomposition tree confirmed and extended the SQL findings in a fascinating way. Not only were the channel-region totals consistent at ~420,000 units, but **the ranking of brands and SKUs remained remarkably similar across all channel-region combinations**. This means that SnBrand2 (identifie Retail-North, E-commerce-South, and Discount-Central equally, while SN-010 consistently ranked as the top SKU regardless of channel or region.

### Business Insights & Recommendations
- **Competitive Landscape Stability**: The consistent brand and SKU rankings across all combinations suggest a stable competitive environment with limited regional competitive variations.
- **Operational Efficiency Opportunity**: Since all channel-region combinations perform identically, inventory allocation can be simplified using uniform distribution ratios rather than complex regional forecasting models.
- **Data Context Note**: It's important to note that this analysis is based on a simulated dataset designed to replicate real-world FMCG scenarios. The highly uniform performance patterns across all dimensions may be a result of the data generation methodology, where variables were intentionally balanced to create consistent distributions across channels and regions.



## Analysis 3: Promotion Effectiveness

### Business Question
Understanding the true impact of promotional campaigns on sales performance is critical for marketing budget allocation and campaign optimization. I analyzed promotional effectiveness across all SKUs to determine whether promotions genuinely drive sales growth and identify the underlying drivers of promotional success.

### Initial Promotion Impact Assessment

I began by examining the relationship between promotional activities and total sales volume to establish a baseline understanding of promotional effectiveness.

```sql
-- Overview promotion impact analysis
SELECT sku, promotion_flag, SUM(units_sold) as total_units_sold
FROM fmcg_2022_2024
GROUP BY sku, promotion_flag
ORDER BY sku ASC;
```

Below is the output (partial data shown, promotion_flag of `0` indicates no promotion and `1` indicates having promotion):

<img width="500" height="436" alt="image" src="https://github.com/user-attachments/assets/d91095c7-4350-4da0-baed-94fa93fc6966" />

At first glance, the SQL results seemed counterintuitive. It appeared that promotions did not boost sales but actually decreased sale volume. However, I recognized that this was not a good comparison because it didn't account for the different number of days each SKU was promoted versus non-promoted.

### Normalized Daily Sales Analysis

I refined the analysis by calculating sales per day to account for the varying promotional periods across different SKUs.

```sql
-- Normalized promotional impact analysis
WITH promotion_sales AS (
SELECT sku, promotion_flag, SUM(units_sold) as total_units_sold, count(date) as number_of_days
FROM fmcg_2022_2024
GROUP BY sku, promotion_flag
ORDER BY sku ASC
)
SELECT *,
ROUND((total_units_sold / number_of_days), 2) as units_per_day
FROM promotion_sales;
```

Below is the output (partial data shown): 

<img width="838" height="432" alt="image" src="https://github.com/user-attachments/assets/5d6f59c3-e187-47bb-87e8-d00abed7ff0c" />

<img width="2026" height="1152" alt="image" src="https://github.com/user-attachments/assets/ad926f0e-faa5-4a3a-afdd-c3f02d888709" />

The normalized results `units_per_day` revealed the true promotional impact. It was now clearly seen that on the days having promot all SKUs. This finding completely contradicted the initial misleading impression from the raw totals.

### Price Impact Investigation

To understand whether the sales increase was driven by price reductions, I examined the average unit prices during promotional and non-promotional periods. This time round, I focused on the top and bottom 3 SKUs found from Analysis 1.

```sql
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
```
Below is the output:

<img width="956" height="432" alt="image" src="https://github.com/user-attachments/assets/5f34d720-54ea-456d-8b7e-60e568ce3146" />

The price analysis yielded a surprising finding. There was not much difference in the average price between the days of having or not having a promotion. On some days, the promotional price was even higher than normal price, yet the sales still doubled. This unexpected result suggested that the sales increase was not driven by price reductions. I proceeded to visualize this using Power BI and checked their statistical significance.

**Power BI Enhancement**: Since Power BI doesn't have a built-in box plot visualization, I utilized **Python** within Power BI using **matplotlib and seaborn** modules to create comprehensive box plot distributions. This advanced integration allowed me to perform **statistical analysis** that wasn't possible with standard Power BI visuals alone.

Below is the output: 

<img width="1514" height="878" alt="image" src="https://github.com/user-attachments/assets/4709ecc0-0505-46c4-aa86-27b1e83aca1b" />

The Power BI box plot clearly showed that having promotion resulted in significantly higher sales than no promotion, even when prices were similar across both conditions. The visualization made the distribution differences immediately apparent, with promotional days showing consistently higher median values and broader ranges than non-promotional periods.

Additionally, I included statistical significance testing for each SKU and found that all of them had p<0.001. This means the data differences were not random, and the promotional effect was statistically significant across all products analyzed.

### Business Insights & Recommendations

- **Marketing Over Price**: The analysis proves that consumers are driven by attractive promotional marketing campaigns rather than actually comparing prices. This psychological effect represents a powerful lever for driving sales volume.
- **Systematic Promotional Planning**: With statistical significance across all SKUs (p<0.001), promotional campaigns can be confidently scaled across the entire product portfolio.










# FMCG 2022-2024 Daily Sales Insights | MySQL & Power BI

## Executive Summary

This project analyzes **FMCG sales data from 2022-2024** to reveal actionable insights for retail strategy and marketing optimization. Key findings show that **promotions nearly double daily sales volume** despite minimal price differences, **regional performance remains surprisingly consistent** across all channels, and **specific SKUs dominate with 170,000+ units sold** while others lag at 85,000 units.

**Business Impact**: Enables data-driven promotion strategies, inventory optimization, and regional resource allocation.

## Table of Contents

- [Executive Summary](#executive-summary)
- [Business Context & Project Workflow](#business-context--project-workflow)
- [Dataset Overview](#dataset-overview)
- [Data Quality & Reliability](#data-quality--reliability)
- [Sales Trends & Seasonality](#sales-trends--seasonality)
- [Regional and Category Performance](#regional-and-category-performance)
- [Promotion Effectiveness](#promotion-effectiveness)
- [Outlier & Anomaly Detection](#outlier--anomaly-detection)
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

It shows that the 'date' column is stored as `text` instead pf the proper `date` column.

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






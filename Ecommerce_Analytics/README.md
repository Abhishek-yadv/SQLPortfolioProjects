
# Data Cleaning Process Overview

The data cleaning process for the `salesdata` table involves several steps to ensure the data is accurate, consistent, and ready for analysis. Below is the steps involved in this process:

Datasets Overview:
The datasets is taken from [Superzop](https://www.superzop.com/), a B2B e-commerce startup revolutionizing staples procurement and have mission to directly source staples from farmers and mills for B2B customers like small retailers and restaurants.This datasets include details on stores, customers, and orders,date,ASM,DSM,area and more.. 

## Data Investigation 👀

- Examine the structure of the dataset, including the number of rows and columns.
- Check for any obvious issues such as unexpected data types or missing values.
- Investigate any columns with unusual patterns or unexpected values that may require further attention during cleaning.

## Handling Missing Values 🕵️‍♂️

- Identify columns with missing values.
- Decide whether to remove rows with missing values or impute missing values using appropriate techniques (e.g., mean, median, mode imputation).
- Implement SQL queries to handle missing values based on the chosen approach.

## Removing Duplicates 🚫

- Identify duplicate rows based on a combination of relevant columns.
- Use SQL queries with window functions or common table expressions (CTEs) to identify and remove duplicate rows.

## Standardizing Data Formats 📅

- Ensure that date, time, and other formatted columns are consistent across the dataset.
- Convert data types and formats using SQL functions (e.g., CONVERT, CAST, FORMAT).

## Handling Inconsistent Data 🔄

- Identify columns with inconsistent data (e.g., different spellings, abbreviations, or capitalization).
- Use SQL queries with CASE statements, string functions, or regular expressions to standardize inconsistent data.

## Creating Derived Columns ➕

- Identify the need for new columns based on the analysis requirements.
- Use SQL queries to create derived columns from existing columns (e.g., calculating age from date of birth, extracting month or year from date columns).

## Filtering and Subsetting Data 🔍

- Identify and remove irrelevant or unnecessary columns.
- Subset the data based on specific criteria (e.g., filtering for a particular hotel, date range, or customer type).

## Data Validation ✅

- Implement checks and constraints to ensure data integrity and validity.
- Use SQL queries to identify and handle outliers or invalid data points.

The `salesdata` dataset is initially imported as a CSV file into MySQL to begin the data cleaning process. Throughout the cleaning process, steps taken and any assumptions made are documented to ensure transparency and reproducibility. Once the data cleaning process is complete, the cleaned and transformed dataset will be ready for further analysis, such as exploring descriptive statistics, building predictive models, or generating insights and recommendations for business decision-making.









Sure, here's the markdown formatting with proper descriptions for the first part of the SQL queries:

```markdown
# Time Series Analysis

## Sales Revenue Over Time
This query retrieves the monthly sales revenue based on the ordered value.

```sql
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    ROUND(SUM(Ordered_Value), 2) AS monthly_sales
FROM salesdata
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY year, MONTH(Order_Date);
```

## Sales Revenue by Delivered Value Over Time
This query retrieves the monthly sales revenue based on the delivered value.

```sql
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    ROUND(SUM(Delivered_Value), 2) AS monthly_sales
FROM salesdata
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY year, MONTH(Order_Date);
```

## Tracking Changes in Cancellation/Undelivered Value Over Time
This query tracks the monthly changes in the undelivered value (cancellations).

```sql
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    ROUND(ABS(SUM(Undelivered_value) - 
	LAG(SUM(Undelivered_value), 1, 0) OVER (ORDER BY YEAR(Order_Date), MONTH(Order_Date))),2) AS last_monthly_sales
FROM salesdata
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY MONTH(Order_Date);
```

## View All Data
This query selects all data from the `salesdata` table.

```sql
SELECT *
FROM SALESDATA
```

## Number of Sales Representatives Over Time
This query retrieves the number of distinct sales representatives for each month.

```sql
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    COUNT(DISTINCT SalesMan) AS Number_Of_Salesmans
FROM salesdata
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY year, MONTH(Order_Date);
```

## Days with Highest Sales Value Over Time
This query retrieves the top 10 days with the highest sales value based on the ordered value.

```
SELECT Top 10 Order_Date, ROUND(SUM(Ordered_Value),2) AS TotalRevenue
FROM SalesData
GROUP BY Order_Date
ORDER BY TotalRevenue DESC;
```

## Months with Highest Sales
This query retrieves the top 3 months with the highest sales based on the ordered value.

```
SELECT TOP 3 DATENAME(month, Order_Date) AS Month, ROUND(SUM(Ordered_Value), 2) AS TotalRevenue
FROM SalesData
GROUP BY DATENAME(month, Order_Date)
ORDER BY TotalRevenue DESC;
```

## Months with Lowest Sales
This query retrieves the top 3 months with the lowest sales based on the ordered value.

```
SELECT TOP 3 DATENAME(month, Order_Date) AS Month, ROUND(SUM(Ordered_Value), 2) AS TotalRevenue
FROM SalesData
GROUP BY DATENAME(month, Order_Date)
ORDER BY TotalRevenue ASC;
```


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

## Handling Inconsistent Data 🔄

- Identify columns with inconsistent data (e.g., different spellings, abbreviations, or capitalization).
- Use SQL queries with CASE statements, string functions, or regular expressions to standardize inconsistent data.

## Standardizing Data Formats 📅

- Ensure that date, time, and other formatted columns are consistent across the dataset.
- Convert data types and formats using SQL functions (e.g., CONVERT, CAST, FORMAT).

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


Here's the formatted version with concise descriptions for the provided SQL queries:


# Data Investigation 👀

## Checking Table Structure and Data Types
```sql
-- Checking table structure and column details
EXEC sp_columns salesdata;

-- Checking columns and their data types
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'salesdata';
```

## Checking Data Sample
```sql
-- Retrieving a sample of data
SELECT TOP 10 *
FROM salesdata
ORDER BY NEWID();
```

## Identifying Unique Values in Categorical Columns
```sql
Retrieving distinct values from categorical columns
SELECT DISTINCT Area FROM salesdata;
SELECT DISTINCT ASM FROM salesdata;
SELECT DISTINCT DASM FROM salesdata;
SELECT DISTINCT SalesMan FROM salesdata;
```

## Table Size and Date Range
```sql
Counting the number of rows
SELECT COUNT(*) AS num_rows
FROM salesdata;

Counting the number of columns
SELECT COUNT(*) AS num_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'salesdata';

Retrieving the date range of the data
SELECT MAX(Order_Date), MIN(Order_Date)
FROM salesdata;
```

## Handling Missing Values
```sql
-- Checking for missing/null values
SELECT
    SUM(CASE WHEN Store_ID IS NULL THEN 1 ELSE 0 END) AS store_ids,
    SUM(CASE WHEN Store_Name IS NULL THEN 1 ELSE 0 END) AS names,
    SUM(CASE WHEN Area IS NULL THEN 1 ELSE 0 END) AS areas,
    SUM(CASE WHEN ASM IS NULL THEN 1 ELSE 0 END) AS asm,
    SUM(CASE WHEN DASM IS NULL THEN 1 ELSE 0 END) AS dasm,
    SUM(CASE WHEN SalesMan IS NULL THEN 1 ELSE 0 END) AS salesmen,
    SUM(CASE WHEN Customer_No IS NULL THEN 1 ELSE 0 END) AS customer_nos,
    SUM(CASE WHEN Order_Number IS NULL THEN 1 ELSE 0 END) AS order_numbers,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS order_dates,
    SUM(CASE WHEN TimeStamp IS NULL THEN 1 ELSE 0 END) AS timestamps,
    SUM(CASE WHEN Ordered_Value IS NULL THEN 1 ELSE 0 END) AS ordered_values,
    SUM(CASE WHEN Delivered_Value IS NULL THEN 1 ELSE 0 END) AS delivered_values,
    SUM(CASE WHEN Sugar IS NULL THEN 1 ELSE 0 END) AS sugar,
    SUM(CASE WHEN FMCG IS NULL THEN 1 ELSE 0 END) AS fmcg,
    SUM(CASE WHEN Delivered_Amt_without_Sugar_FMCG IS NULL THEN 1 ELSE 0 END) AS null_delivered_amt_without_sugar_fmcg
FROM salesdata;
```

## Observations and Conclusions

- The column DASM has around 40% null values, which may represent cases where a District Area Sales Manager is not available, and the Regional Sales Manager (RSM) handles the responsibility.
- Replace NULL values in the DASM column with 'RSM' (Regional Sales Manager).
- Change the data type of the Order_Date column to DATE.
- Change the data type of the Customer_No column to DATETIME2.
- Change the data type of the TimeStamp column to DATETIME2.
- Change the data type of the Customer_Number column to INTEGER.
- Rename the TimeStamp column to avoid conflicts with the reserved word 'TIMESTAMP' in SQL Server.
- The values in the Order_Number column need to be split because they contain both the Store ID and Order Number, separated by a delimiter '/'.
- The Order_Number column should be of the INTEGER data type instead of VARCHAR.
- The Area column could be merged into one entity rather than separating it into east, west, south, or north, but the company has already fixed it based on the potential business.
- The Delivered_Value is sometimes higher than the Ordered_Value due to manual data entry by drivers, and this needs to be fixed.
- The Order_Amount for Sugar and FMCG (other than staples and dry fruits) is very low and frequently contains zeros, which could be avoided as it is not the company's core product and has a low profit margin.
- The analysis will focus on overall sales, which is the company's core business (staples).
- The dataset contains 12,740 rows and 15 columns, spanning the date range from 01-02-2023 to 31-10-2023.

Here's the formatted version with concise descriptions for the data preprocessing queries:

```markdown
# Data Preprocessing

## Handling Inconsistent Data

```sql
-- Rename TIMESTAMP column
EXEC sp_rename 'salesdata.TIMESTAMP', 'Time_stamp', 'COLUMN';

-- Updating Order_Number
UPDATE salesdata
SET Order_Number = SUBSTRING(Order_Number, CHARINDEX('/', Order_Number) + 1, LEN(Order_Number));
```

## Standardizing Data Formats

```sql
-- Convert Order_Date data type to DATE
UPDATE salesdata
SET Order_Date = CONVERT(DATE, Order_Date, 105);

ALTER TABLE salesdata
ALTER COLUMN Order_Date DATE;

-- Convert Time_Stamp column data type to DATETIME2
UPDATE salesdata
SET Time_Stamp = CONVERT(DATETIME2, Time_Stamp, 105);

ALTER TABLE salesdata
ALTER COLUMN Time_Stamp DATETIME2;

-- Change data type of Order_Number to INT
ALTER TABLE salesdata
ALTER COLUMN Order_Number INT;

-- Change data type of Customer_No to BIGINT
UPDATE salesdata
SET Customer_No = CONVERT(BIGINT, Customer_No, 105);

-- Handle non-numeric values in Customer_No
UPDATE salesdata
SET Customer_No = CASE WHEN ISNUMERIC(Customer_No) = 0 THEN '0' ELSE Customer_No END;

ALTER TABLE salesdata
ALTER COLUMN Customer_No BIGINT;
```

## Creating Derived Columns

```sql
-- Correct Delivered_Value column
UPDATE salesdata
SET Delivered_Value = (
    CASE
        WHEN Delivered_Value = FLOOR(Ordered_Value) OR Delivered_Value = CEILING(Ordered_Value) THEN Ordered_Value
        ELSE Delivered_Value
    END
)

-- Add Undelivered_Value column
ALTER TABLE salesdata
ADD Undelivered_Value FLOAT;

UPDATE salesdata
SET Undelivered_Value = ROUND(ABS((Delivered_Value - Ordered_Value)), 2)

-- Handle NULL values in Undelivered_Value
UPDATE salesdata
SET Undelivered_Value = 0 WHERE Undelivered_Value IS NULL;
```

## Filtering and Subsetting Data

```sql
-- Drop unnecessary columns
ALTER TABLE salesdata
DROP COLUMN Delivered_Amt_without_Sugar_FMCG,
DROP COLUMN FMCG,
DROP COLUMN Sugar;
```

## Data Cleaned and Ready for Analysis

```sql
-- Check the data
SELECT * FROM salesdata;

-- View data types and columns
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'salesdata';
```

------------- Now Data Has Been Cleaned And ready for analysys --------------------

# Time Series Analysis

#### Sales Revenue Over Time
```sql
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    ROUND(SUM(Ordered_Value), 2) AS monthly_sales
FROM salesdata
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY year, MONTH(Order_Date);
```

#### Sales Revenue by Delivered Value Over Time
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
#### Total Order Cancellation order value
This query retrieves the monthly sales revenue based on the delivered value.

```sql
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    ROUND(SUM(Ordered_Value), 2) AS monthly_sales
FROM salesdata
WHERE Delivered_Value = 0
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY year, MONTH(Order_Date);

```

#### Tracking Changes in Cancellation Value Over Time
This query tracks the monthly changes in the undelivered value (cancellations).

```sql
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    ROUND(ABS(SUM(Undelivered_value) - 
	LAG(SUM(Undelivered_value), 1, 0) OVER (ORDER BY YEAR(Order_Date), MONTH(Order_Date))),2) AS last_monthly_sales
FROM salesdata
WHERE Delivered_Value = 0
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY MONTH(Order_Date);
```

#### Number of Sales Representatives Over Time
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

#### Days with Highest Sales Value Over Time
This query retrieves the top 10 days with the highest sales value based on the ordered value.

```sql
SELECT Top 10 Order_Date, ROUND(SUM(Ordered_Value),2) AS TotalRevenue
FROM SalesData
GROUP BY Order_Date
ORDER BY TotalRevenue DESC;
```

#### Months with Highest Sales
This query retrieves the top 3 months with the highest sales based on the ordered value.

```sql
SELECT TOP 3 DATENAME(month, Order_Date) AS Month, ROUND(SUM(Ordered_Value), 2) AS TotalRevenue
FROM SalesData
GROUP BY DATENAME(month, Order_Date)
ORDER BY TotalRevenue DESC;
```

#### Months with Lowest Sales
This query retrieves the top 3 months with the lowest sales based on the ordered value.

```sql
SELECT TOP 3 DATENAME(month, Order_Date) AS Month, ROUND(SUM(Ordered_Value), 2) AS TotalRevenue
FROM SalesData
GROUP BY DATENAME(month, Order_Date)
ORDER BY TotalRevenue ASC;
```



# Store Analysis

#### Top-Performing Stores
This query retrieves the top 10 stores with the highest total sales based on the delivered value.

```sql
SELECT TOP 10 Store_Name, SUM(delivered_Value) AS TotalSales, Area, ASM
FROM SalesData
GROUP BY Store_Name, Area, ASM
ORDER BY TotalSales DESC;
```

#### Stores with Most Returned/Cancelled Orders
This query retrieves the top 10 stores with the highest total undelivered value (cancelled orders).

```sql
SELECT TOP 10 Store_Name, SUM(Undelivered_Value) AS Total_Undelivered, Area, ASM
FROM salesdata
GROUP BY Store_Name, Area, ASM
ORDER BY Total_Undelivered DESC;
```

# Area Sales Analysis

#### Total Sales by Area
This query retrieves the total sales (ordered value) for each area.

```sql
SELECT Area, ROUND(SUM(Ordered_Value), 2) AS total_sales
FROM salesdata
GROUP BY Area
ORDER BY total_sales DESC;
```

#### Top-Performing Areas by Total Sales
This query retrieves the top 10 best-performing areas by total sales (ordered value), along with their sales rank.

```sql
SELECT TOP 10
    Area,
    ROUND(SUM(Ordered_Value), 2) AS total_sales,
    RANK() OVER (ORDER BY SUM(Ordered_Value) DESC) AS sales_rank
FROM salesdata
GROUP BY Area;
```

#### Worst-Performing Areas by Total Sales
This query retrieves the top 10 worst-performing areas by total sales (ordered value).

```sql
SELECT TOP 10 Area, SUM(Ordered_Value) AS total_sales
FROM salesdata
GROUP BY Area
ORDER BY total_sales ASC;
```

#### Areas with Most Cancellations
This query retrieves the top 10 areas with the highest total ordered value for undelivered orders (cancellations).

```sql
SELECT TOP 10 Area, SalesMan, ASM, ROUND(SUM(Ordered_Value), 2) AS Total_ordered
FROM salesdata
WHERE delivered_value = 0
GROUP BY AREA, SalesMan, ASM
ORDER BY ROUND(SUM(Ordered_Value), 2) DESC;
```

#### Top Loyal Stores by Delivered Value
This query retrieves the top 10 stores with the highest total delivered value.

```sql
SELECT TOP 10 Store_Name, SUM(Delivered_Value) AS total_delivered
FROM salesdata
GROUP BY Store_Name
ORDER BY total_delivered DESC
```

#### Stores with Most Fake Orders
This query retrieves the top 10 stores with the highest total ordered value for undelivered orders (fake orders).

```sql
SELECT TOP 10 Store_Name, ROUND(SUM(Ordered_Value), 2) AS Total_ordered
FROM salesdata
WHERE delivered_value = 0
GROUP BY Store_Name
ORDER BY ROUND(SUM(Ordered_Value), 2) DESC;
```

# Sales Representative Analysis

#### Sales Performance by Salesman
This query retrieves the sales performance of each salesman, including the number of customers, total ordered value, and total delivered value.

```sql
SELECT
    s.SalesMan,
    COUNT(DISTINCT o.Customer_No) AS NumberOfCustomers,
    SUM(o.Ordered_Value) AS TotalOrderedValue,
    SUM(o.Delivered_Value) AS TotalDeliveredValue
FROM salesdata o
JOIN (
    SELECT DISTINCT SalesMan
    FROM salesdata
) s ON o.SalesMan = s.SalesMan
GROUP BY s.SalesMan
ORDER BY TotalOrderedValue DESC;
```

Here's the continuation of the markdown formatting with descriptions for the remaining SQL queries:

```markdown
## Top-Performing Sales Representatives by Ordered Value
This query retrieves the top 10 sales representatives with the highest total sales based on the delivered value.

```sql
SELECT TOP 10 SalesMan, ROUND(SUM(Delivered_Value), 2) AS total_sales
FROM salesdata
GROUP BY SalesMan
ORDER BY total_sales DESC;
```

#### Sales Representatives with Highest Cancellations
This query retrieves the top 10 sales representatives with the highest total undelivered value (cancellations).

```sql
SELECT TOP 10 SalesMan, ROUND(SUM(Undelivered_Value), 2) AS Undeliver_value
FROM salesdata
GROUP BY SalesMan
ORDER BY Undeliver_value DESC;
```

#### Loss-Making Sales Representatives
This query retrieves the top 10 sales representatives with the highest total undelivered value (cancellations) and whose delivered value is below the average.

```sql
SELECT TOP 10 SalesMan, ROUND(SUM(Undelivered_Value), 2) AS Undeliver_value
FROM salesdata
GROUP BY SalesMan
HAVING delivered_Value < (SELECT ROUND(AVG(delivered_Value), 2) FROM Salesdata)
ORDER BY Undeliver_value DESC;
```

#### Sales Representatives with Most Fake Orders
This query retrieves the top 10 sales representatives with the highest total ordered value for undelivered orders (fake orders).

```sql
SELECT TOP 10 SalesMan, ASM, ROUND(SUM(Ordered_Value), 2) AS Total_ordered
FROM salesdata
WHERE delivered_value = 0
GROUP BY SalesMan, ASM
ORDER BY ROUND(SUM(Ordered_Value), 2) DESC;
```

#### Best-Performing Area Sales Managers (ASMs)
This query retrieves the best-performing area sales managers (ASMs) based on the total ordered value and delivered value, along with the number of salesmen under each ASM.

```sql
SELECT
    ASM,
    COUNT(DISTINCT SalesMan) AS NumberOfSalesmen,
    SUM(Ordered_Value) AS TotalOrderedValue,
    SUM(Delivered_Value) AS TotalDeliveredValue
FROM salesdata
GROUP BY ASM
ORDER BY TotalOrderedValue DESC;
```

# Sales Distribution and Outliers

#### Sales Distribution of Order Values
This query calculates the first quartile (Q1), median, and third quartile (Q3) of the ordered values.

```sql
SELECT 
    PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS Q1,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS median,
    PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS Q3
FROM salesdata;
```

#### Outliers in Delivered Values
This query identifies the order numbers and delivered values that are outliers (more than 20 standard deviations above the mean).

```sql
DECLARE @AvgDeliveredValue FLOAT, @StdevDeliveredValue FLOAT;

SELECT @AvgDeliveredValue = AVG(Delivered_Value),
       @StdevDeliveredValue = STDEV(Delivered_Value)
FROM salesdata;

SELECT Order_Number, Delivered_Value
FROM salesdata
WHERE Delivered_Value > @AvgDeliveredValue + 20 * @StdevDeliveredValue;
```

# Superzop End To End Sales Analysis

## Part 1 Data Cleaning Process
### Overview
The data cleaning process for the `salesdata` table involves several steps to ensure the data is accurate, consistent, and ready for analysis. Below is full description about the steps I have taken throughout in this process:

Overview Of Datasets:
The datasets is taken from [Superzop](https://www.superzop.com/), a B2B e-commerce startup revolutionizing staples procurement and have mission to directly source staples from farmers and mills for B2B customers like small retailers and restaurants.This datasets include details on stores, customers, and orders,date,ASM,DSM,area and more.. 

## Data Investigation 👀

- Examine the structure of the dataset, including the number of rows and columns.
- Check for any obvious issues such as unexpected data types or missing values.
- Investigate any columns with unusual patterns or unexpected values that may require further attention during cleaning.

## Handling Missing Values 🕵️‍♂️

- Identify columns with missing values.
- Decide whether to remove rows with missing values or impute missing values using appropriate techniques (e.g., mean, median, mode imputation).
- Implement SQL queries to handle missing values based on the chosen approach.

## Handling Duplicates 🚫

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

The `salesdata` dataset is initially imported as a CSV file into MSSQL SERVER to begin the data cleaning process. Throughout the cleaning process, steps taken and any assumptions made are step wise documented to for better readability. Once the data cleaning process is complete, the cleaned and transformed dataset will be ready for further analysis, such as sales analysis across area, sales representatives, stores, ASM and recommendations for business decision-making.


## Data Investigation 

#### Checking Table Structure and Data Types
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

#### Checking Data Sample
```sql
SELECT TOP 10 *
FROM salesdata
ORDER BY NEWID();
```

#### Identifying Unique Values in Categorical Columns
```sql
SELECT DISTINCT Area FROM salesdata;
SELECT DISTINCT ASM FROM salesdata;
SELECT DISTINCT DASM FROM salesdata;
SELECT DISTINCT SalesMan FROM salesdata;
```

#### Table Size and Date Range
```sql
-- Number of rows
SELECT COUNT(*) AS num_rows
FROM salesdata;

-- Number of columns
SELECT COUNT(*) AS num_columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'salesdata';

-- Retrieving the date range of the data
SELECT MAX(Order_Date), MIN(Order_Date)
FROM salesdata;
```

## Handling Missing Values
```sql
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

## Handling Duplicates 🚫
```sql
SELECT Store_ID,
    Order_Number,
    COUNT(*) AS duplicate_count
FROM salesdata
GROUP BY Store_ID, Order_Number
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
```

### Observations and Conclusions

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

## Data Validation

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

---------------------------- Now Data Has Been Cleaned And ready for analysis ----------------------------

## Part 2 Sales Analysis

/****** A Quick Sales Overview and Summary ********/


```sql
SELECT 
    	ROUND(SUM(Ordered_Value), 2) AS Total_Ordered,
	ROUND(SUM(Delivered_Value), 2) AS Total_Delivered_Value,
	ROUND(SUM(Undelivered_value), 2) AS Total_Undelivered_values
FROM salesdata;
```

This query provides a summary of total ordered, delivered, and undelivered values. Additionally:

```sql
-- Total FakeOrder value
SELECT 
ROUND(SUM(Ordered_Value), 2) AS Total_Cancellation
FROM salesdata
WHERE Delivered_Value = 0;
```

Conclusion: Overall revenue is 787612350.92. Delivered value is 648748741.47 and Undelivered value is 124733011.7, in which 58674265.11 is Faked Ordered value.

## Time Series Analysis

### Sales Performance Over Time

```sql
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    ROUND(SUM(Ordered_Value), 2) AS monthly_sales,
    ROUND(SUM(Delivered_Value), 2) AS Delivered_Value_sales,
    ROUND(SUM(Undelivered_value), 2) AS Undelivered_value_sales,
	Rank() OVER (Order BY SUM(Ordered_Value) DESC) AS RN
FROM salesdata
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY year, MONTH(Order_Date);
```

Conclusion: In The month of March, highest sales followed by May, September has the least followed by December.

### Tracking changes in Cancellation 

```sql
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    ROUND(SUM(Ordered_Value), 2) AS Cancelled_order,
    RANK() OVER(ORDER BY SUM(Ordered_Value)) AS RN
FROM salesdata
WHERE Delivered_Value = 0
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY year, MONTH(Order_Date);
```

Conclusion: There is no improvement seen over time. It's seen in October and November, but in those months, the company has not full stocks.

### Tracking changing in cancellation over each month

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

Conclusion: Order cancellation is going up month by month.

### Number of Sales Representatives Over Time

```sql
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    ROUND(SUM(Ordered_Value), 2) AS Ordered_Sales,
    COUNT(DISTINCT SalesMan) AS Number_Of_Salesmans
FROM salesdata
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY year, MONTH(Order_Date);
```

Conclusion: The number of hiring increased in November and December, but overall sales decreased in comparison to past months.

### Days with Highest Sales Value Over Time

```sql
SELECT TOP 10 Order_Date, ROUND(SUM(Ordered_Value),2) AS TotalRevenue
FROM SalesData
GROUP BY Order_Date
ORDER BY TotalRevenue DESC;
Conclusion: The biggest spike in sales is near the holi festival.
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


/************  Area Sales Analysis  **************/
```markdown
## Total sales (ordered value) by area

```sql
SELECT Area, ROUND(SUM(Ordered_Value),2) AS total_sales
FROM salesdata
GROUP BY Area
ORDER BY total_sales DESC;
```

Area such as Mira road, Nalasopara East, Thane West Vasai have the highest sales that are part of western Mumbai. Conclusion: Western coastal area has high potential.

## Top best performing area by Total sales (ordered value)

```sql
SELECT TOP 10
    Area,
    ROUND(SUM(Ordered_Value),2) AS total_sales,
    RANK() OVER (ORDER BY SUM(Ordered_Value) DESC) AS sales_rank
FROM salesdata
GROUP BY Area;
```

## Top 10 worst performing area by Total sales (ordered value)

```sql
SELECT TOP 10 Area, SUM(Ordered_Value) AS total_sales
FROM salesdata
GROUP BY Area
ORDER BY total_sales ASC;
```

## Area Where cancellation occurs most

```sql
SELECT TOP 10 Area, SalesMan, ASM, ROUND(SUM(Ordered_Value),2) AS Total_ordered
FROM salesdata
WHERE delivered_value = 0
GROUP BY AREA, SalesMan, ASM
ORDER BY ROUND(SUM(Ordered_Value),2) DESC;
```

Highest Fake ordered placed in Nalasopara around (1888456.69 + 1529436.78).

# Store Analysis

## Top Loyals stores by delivered value

```sql
SELECT TOP 10 Store_Name, SUM(Ordered_Value) as Total_Ordered, SUM(Delivered_Value) AS Total_delivered
FROM salesdata
GROUP BY Store_Name
ORDER BY total_delivered DESC;
```

## Stores That place most fake orders

```sql
SELECT TOP 10 Store_Name, ROUND(SUM(Ordered_Value),2) AS Total_ordered, Area
FROM salesdata
WHERE delivered_value = 0
GROUP BY Store_Name, Area
ORDER BY ROUND(SUM(Ordered_Value),2) DESC;
```

# Sales Representative Analysis

## Sales Performance by Salesman

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

Conclusion: Rajendra Patel has the highest sales with just 172 customers and Mohammed has 404 customers.

## Area Penetration Performance by Salesman

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
ORDER BY NumberOfCustomers DESC;
```

Neeraj Sahu has 416 followed by Mohammad Saeed Shaikh 404.

## Average Salesman Penetration In Market

```sql
WITH CTE AS(
    SELECT 
    s.SalesMan,
    COUNT(DISTINCT o.Customer_No) AS NumberOfCustomers,
    SUM(o.Ordered_Value) AS TotalOrderedValue,
    SUM(o.Delivered_Value) AS TotalDeliveredValue
FROM salesdata o
JOIN (
    SELECT DISTINCT SalesMan
    FROM salesdata)
	s ON o.SalesMan = s.SalesMan
GROUP BY s.SalesMan)

SELECT AVG(NumberOfCustomers) AS Average_Shops
FROM CTE
ORDER BY AVG(NumberOfCustomers) DESC;
```

Salesman AVG Shops Penetration In Market is 145.

## Top performing sales representative performance by Ordered Value

```sql
SELECT TOP 10 SalesMan, ROUND(SUM(Delivered_Value),2) AS total_sales
FROM salesdata
GROUP BY SalesMan
ORDER BY total_sales DESC;
```

## Sales representative who has the highest deliver return in value term

```sql
SELECT TOP 10 SalesMan, ROUND(SUM(Undelivered_Value),2) AS Undeliver_value
FROM salesdata
GROUP BY SalesMan
ORDER BY Undeliver_value DESC;
```

## Salesman who placed Fake Orders most

```sql
SELECT TOP 10 SalesMan, ASM, ROUND(SUM(Ordered_Value),2) AS Total_ordered
FROM salesdata
WHERE delivered_value = 0
GROUP BY SalesMan, ASM
ORDER BY ROUND(SUM(Ordered_Value),2) DESC;
```


Here's the README markdown file in the requested style:

```markdown
# ASM (Area Sales Manager) Analysis

#### Analysis of Sales Performance by ASM

```sql
SELECT
    ASM,
    ROUND(COUNT(DISTINCT SalesMan),2) AS NumberOfSalesmen,
    ROUND(SUM(Ordered_Value),2) AS TotalOrderedValue,
    ROUND(SUM(Delivered_Value),2) AS TotalDeliveredValue,
    ROUND(SUM(Ordered_Value)/COUNT(DISTINCT SalesMan),2) AS Per_Salesman
FROM salesdata
GROUP BY ASM
ORDER BY Per_Salesman DESC;
```
**Conclusion:** Bikas is the best leader overall with an average sale per salesperson of 19,370,302.76 rupees over time.

#### Best Performing ASM by Overall Delivered Value

```sql
SELECT
    ASM,
    ROUND(COUNT(DISTINCT SalesMan),2) AS NumberOfSalesmen,
    ROUND(SUM(Ordered_Value),2) AS TotalOrderedValue,
    ROUND(SUM(Delivered_Value),2) AS TotalDeliveredValue,
    Rank() OVER (Order by SUM(Delivered_Value) DESC) as Rn
FROM salesdata
GROUP BY ASM
ORDER BY TotalDeliveredValue DESC;
```
**Conclusion:** Darshan has the overall highest sales followed by Vikash Singh. Leaders needing improvement are Sanjeev Vedak, Amresh Singh, and Prithwi.

# Statistical Analysis

#### Sales Distribution of Order Values

```sql
SELECT 
    PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS Q1,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS median,
    PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS Q3
FROM salesdata;
```
**Conclusion:** Quartile 1, median, and Quartile 3 of order values are 3210.26, 3959.7, and 5786.01 respectively.

#### Outliers in Delivered Values

```sql
DECLARE @AvgDeliveredValue FLOAT, @StdevDeliveredValue FLOAT;
SELECT @AvgDeliveredValue = AVG(Delivered_Value),
       @StdevDeliveredValue = STDEV(Delivered_Value)
FROM salesdata;
SELECT Order_Number, Delivered_Value
FROM salesdata
WHERE Delivered_Value > @AvgDeliveredValue + 3 * @StdevDeliveredValue;
```
**Conclusion:** There are no outliers seen in the table.
```

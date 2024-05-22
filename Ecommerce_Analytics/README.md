# 🛒Superzop End To End Sales Analysis

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
#### Checking table structure and column details
```sql
EXEC sp_columns salesdata;
```

![1](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/288c124f-9db3-4f47-bdd8-aeba642db60d)

#### Checking columns and their data types
```sql
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'salesdata';
```
![2](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/9176af3b-cc66-4a51-91f8-89c8d301b000)

#### Checking Data Sample
```sql
SELECT TOP 10 *
FROM salesdata
ORDER BY Store_ID;
```
![3](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/5f46c8d6-dc68-4297-a1ba-edbb570b0c01)

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
```
![4](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/6a4a2980-ce75-4067-aea6-b7dc8bee737b)

```sql
-- Date range of the data
SELECT MAX(Order_Date) AS Last_Date, MIN(Order_Date) AS First_Date
FROM salesdata;
```
![5](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/495f5c6a-5370-4396-a503-0e601bc3c77c)

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
![6](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/a07d0e1e-ea8a-4fd1-a5dc-1a5c088f5999)

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
![7](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/39d32495-86b4-4955-bc2c-6f0157801055)

-- In this table order amount is diffrent for duplicate order number so it should not be consider as duplicate but database mangement team need to fix it.

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
```
![1](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/0c5e678c-167d-4f0a-ac1e-82b6db99435d)

```sql
-- View data types and columns
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'salesdata';
```


![2](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/d3df24b2-27de-441e-ad1c-5ba0cec6f372)

---------------------------- Now Data Has Been Cleaned And ready for analysis ----------------------------

# Part 2 Analysis

## A Quick Sales Overview and Summary 


```sql
SELECT 
     ROUND(SUM(Ordered_Value), 2) AS Total_Ordered,
     ROUND(SUM(Delivered_Value), 2) AS Total_Delivered_Value,
     ROUND(SUM(Undelivered_value), 2) AS Total_Undelivered_values
FROM salesdata;
```
![1](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/8e0816ca-61d2-4945-adf6-398cffcebb91)

```sql
-- Total FakeOrder value
SELECT 
ROUND(SUM(Ordered_Value), 2) AS Total_Cancellation
FROM sales data
WHERE Delivered_Value = 0;
```
![2](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/83659277-6663-4f79-b786-67d9878a27c7)

Conclusion: Overall revenue is 787612350.92. Delivered value is 648748741.47 and Undelivered value is 124733011.7, in which 58674265.11 is Faked Ordered value.

## Time Series Analysis
#### Sales Performance Over Time
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
![3](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/ae4bc45a-5d52-4fb6-bc3e-8358076a24c3)

Conclusion: In The month of March, highest sales followed by May, September has the least followed by December.

#### Tracking changes in Cancellation 
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
![4](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/b7a98f5d-d1a9-4114-b703-afea624862c8)

Conclusion: There is no improvement seen over time. It's seen in October and November, but in those months, the company has not full stocks.

#### Tracking changing in cancellation over each month
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
![5](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/7a24a3b6-bc2d-42af-8aac-14b42d2e3c09)

Conclusion: Order cancellation is going up month by month.

#### Number of Sales Representatives Over Time
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
![6](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/b58bbd34-8739-4e88-8b9a-954da8043afc)

Conclusion: The number of hiring increased in November and December, but overall sales decreased in comparison to past months.

#### Days with Highest Sales Value Over Time
```sql
SELECT TOP 10 Order_Date, ROUND(SUM(Ordered_Value),2) AS TotalRevenue
FROM SalesData
GROUP BY Order_Date
ORDER BY TotalRevenue DESC;
```
![7](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/1f2cc37a-0b02-461b-8fb8-1e3c3c51618a)

Conclusion: The biggest spike in sales seems near the holi festival.

## Store Analysis
#### Top-Performing Stores
```sql
SELECT TOP 10 Store_Name, SUM(delivered_Value) AS TotalSales, Area, ASM
FROM SalesData
GROUP BY Store_Name, Area, ASM
ORDER BY TotalSales DESC;
```
![b1](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/be165a74-0be6-4f00-8024-661253b2aeac)

#### Stores with Most Returned/Cancelled Orders
```sql
SELECT TOP 10 Store_Name, SUM(Undelivered_Value) AS Total_Undelivered, Area, ASM
FROM salesdata
GROUP BY Store_Name, Area, ASM
ORDER BY Total_Undelivered DESC;
```
![b2](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/b9518a7c-0b6d-4d0b-9ce3-c9551fbed639)

##  Area Sales Analysis 
#### Total sales (ordered value) by area
```sql
SELECT Area, ROUND(SUM(Ordered_Value),2) AS total_sales
FROM salesdata
GROUP BY Area
ORDER BY total_sales DESC;
```
![8](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/6bc24924-f39e-4fe2-96db-48ae4f906b2b)

Area such as Mira road, Nalasopara East, Thane West Vasai have the highest sales that are part of western Mumbai. Conclusion: Western coastal area has high potential.

#### Top best performing area by Total sales (ordered value)
```sql
SELECT TOP 10
    Area,
    ROUND(SUM(Ordered_Value),2) AS total_sales,
    RANK() OVER (ORDER BY SUM(Ordered_Value) DESC) AS sales_rank
FROM salesdata
GROUP BY Area;
```
![9](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/3a8523c3-7b92-4af6-a4f3-c1aa1543422b)

#### Top 10 worst performing area by Total sales (ordered value)
```sql
SELECT TOP 10 Area, SUM(Ordered_Value) AS total_sales
FROM salesdata
GROUP BY Area
ORDER BY total_sales ASC;
```
![10](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/de32eb68-6bc5-4371-9c0b-9aacc9f72776)

#### Area Where cancellation occurs most
```sql
SELECT TOP 10 Area, SalesMan, ASM, ROUND(SUM(Ordered_Value),2) AS Total_ordered
FROM salesdata
WHERE delivered_value = 0
GROUP BY AREA, SalesMan, ASM
ORDER BY ROUND(SUM(Ordered_Value),2) DESC;
```
![11](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/c18dfb2c-0754-4312-84ee-6bc328e9799f)

Highest Fake ordered placed in Nalasopara around (1888456.69 + 1529436.78).

## Store Analysis
#### Top Loyals stores by delivered value
```sql
SELECT TOP 10 Store_Name, SUM(Ordered_Value) as Total_Ordered, SUM(Delivered_Value) AS Total_delivered
FROM salesdata
GROUP BY Store_Name
ORDER BY total_delivered DESC;
```
![12](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/fab68572-d31f-49b9-b8a7-81c1e6787077)

#### Stores That place most fake orders
```sql
SELECT TOP 10 Store_Name, ROUND(SUM(Ordered_Value),2) AS Total_ordered, Area
FROM salesdata
WHERE delivered_value = 0
GROUP BY Store_Name, Area
ORDER BY ROUND(SUM(Ordered_Value),2) DESC;
```
![13](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/0fedb499-c8f9-4a2f-b9d2-dda2ee89d908)

## Sales Representative Analysis
#### Sales Performance by Salesman
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
![14](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/37915c62-13e2-4622-acda-78d837711caf)

Conclusion: Rajendra Patel has the highest sales with just 172 customers and Mohammed has 404 customers.

#### Area Penetration Performance by Salesman
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
![15](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/047e8813-9c31-4f97-bd33-142e39288c7f)

Neeraj Sahu has 416 followed by Mohammad Saeed Shaikh 404.

#### Average Salesman Penetration In Market
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
![16](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/c89e3494-f828-4edb-9880-1ee55b2b5dd8)

Salesman AVG Shops Penetration In Market is 145.

#### Top performing sales representative performance by Ordered Value
```sql
SELECT TOP 10 SalesMan, ROUND(SUM(Delivered_Value),2) AS total_sales
FROM salesdata
GROUP BY SalesMan
ORDER BY total_sales DESC;
```
![17](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/7e0c50c2-6b7a-422e-a066-eeabcb577ccb)

#### Sales representative who has the highest deliver return in value term
```sql
SELECT TOP 10 SalesMan, ROUND(SUM(Undelivered_Value),2) AS Undeliver_value
FROM salesdata
GROUP BY SalesMan
ORDER BY Undeliver_value DESC;
```
![18](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/2726bc7e-65e9-40bd-8428-4b74d587c1aa)

#### Salesman who placed Fake Orders most
```sql
SELECT TOP 10 SalesMan, ASM, ROUND(SUM(Ordered_Value),2) AS Total_ordered
FROM salesdata
WHERE delivered_value = 0
GROUP BY SalesMan, ASM
ORDER BY ROUND(SUM(Ordered_Value),2) DESC;
```
![19](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/612e61ed-9d8c-44ed-bffe-e12d7d442603)


## ASM (Area Sales Manager) Analysis
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
![20](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/27493352-d486-40da-b162-1ca28bdc76ac)

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
![21](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/89e780aa-6b59-4976-8b60-2bb9c1971c14)

**Conclusion:** Darshan has the overall highest sales followed by Vikash Singh. Leaders needing improvement are Sanjeev Vedak, Amresh Singh, and Prithwi.

## Statistical Analysis
#### Sales Distribution of Order Values
```sql
SELECT 
    PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS Q1,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS median,
    PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS Q3
FROM salesdata;
```
![22](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/17c71c71-7c89-42ce-b439-1d52a1ae2ae1)

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
![23](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/bbcee848-ccf6-4c71-9107-6f17400021ad)

**Conclusion:** There are no outliers seen in the table.


## Analysis Key Findings

### Sales Summary

- Total ordered value: ₹787,612,350.92
- Total delivered value: ₹648,748,741.47
- Total undelivered value: ₹124,733,011.70
- Fake orders value: ₹58,674,265.11

### Time Series Analysis

- Highest sales month: March
- Lowest sales months: September and December
- Order cancellations increased month by month
- Sales representatives hiring increased in November and December, but overall sales decreased compared to previous months
- Biggest sales spikes occurred near the Holi festival

### Area Sales Analysis

- Western coastal areas (Mira Road, Nalasopara East, Thane West Vasai) have the highest sales potential
- Nalasopara witnessed the most fake orders (₹1,888,456.69 + ₹1,529,436.78)

### Store Analysis

- Top 10 loyal stores by delivered value
- Top 10 stores that placed the most fake orders

### Sales Representative Analysis

- Rajendra Patel had the highest sales with just 172 customers
- Mohammad had 404 customers
- Neeraj Sahu had the highest number of customers (416)
- Average market penetration (number of shops) per salesman: 145

### ASM (Area Sales Manager) Analysis

- Best-performing ASM overall: Bikas (average sale of ₹19,370,302.76 per salesman)
- ASM with the highest overall delivered value: Darshan
- ASMs needing improvement: Sanjeev Vedak, Amresh Singh, Prithwi

### Statistical Analysis

- Order value distribution:
  - First quartile (Q1): ₹3,210.26
  - Median: ₹3,959.70
  - Third quartile (Q3): ₹5,786.01
  - No significant outliers detected in delivered values
  
Recommendations:

1. **Focus on Western Coastal Areas**: The analysis revealed that areas like Mira Road, Nalasopara East, and Thane West Vasai have the highest sales potential. SuperZop should consider expanding its operations and increasing its presence in these high-performing areas to capitalize on the existing demand.

2. **Address Fake Orders and Cancellations**: The analysis identified a significant number of fake orders and an increasing trend in order cancellations, particularly in areas like Nalasopara. SuperZop should investigate the root causes of these issues and implement measures to prevent fake orders and reduce cancellations, such as improving supply chain management, enhancing customer communication, and implementing stricter order verification processes.

3. **Optimize Sales Representative Performance**: The analysis highlighted the varying performance of sales representatives. SuperZop should closely monitor and provide additional training and support to underperforming representatives, particularly those with high undelivered values or fake orders. Additionally, the company should recognize and incentivize top-performing representatives like Rajendra Patel and Mohammad Saeed Shaikh to retain and motivate them.

4. **Strengthen Area Sales Manager (ASM) Leadership**: The analysis identified ASMs like Sanjeev Vedak, Amresh Singh, and Prithwi as requiring improvement in their performance. SuperZop should evaluate the reasons behind their underperformance and provide them with the necessary resources, training, and support to enhance their leadership abilities and drive better results from their teams.

5. **Analyze Sales Spikes and Seasonal Trends**: The analysis revealed that sales spikes occurred around the Holi festival. SuperZop should further investigate these seasonal trends and consider implementing targeted marketing campaigns or promotions to capitalize on these high-demand periods.

6. **Identify and Address Outliers**: The analysis identified outliers in delivered values. SuperZop should investigate these outliers to understand the underlying causes and take appropriate actions, such as addressing supply chain issues, improving order fulfillment processes, or implementing better inventory management practices.

7. **Monitor and Adjust Hiring Strategies**: The analysis showed that hiring more sales representatives in November and December did not lead to an increase in sales compared to previous months. SuperZop should evaluate its hiring strategies and ensure that new hires are properly trained, supported, and aligned with the company's sales objectives.


## THANKS FOR WATCHING! 🎉
### Haven't Imagined You Will Arrive Here. 🌟

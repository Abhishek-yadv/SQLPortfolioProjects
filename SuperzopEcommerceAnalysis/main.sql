/******** SuperZop End to End Sales Analysis **********/

/********************************************/
/********* Part 1 Data Preperation *********/

/***** Data Exploration and Understanding ********/
-- Cheking table structure and data types:
EXEC sp_columns salesdata;

-- Cheking columns and their data types 
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'salesdata';

-- Cheking data sample:
SELECT TOP 10 *
FROM salesdata
order by Rand();

-- Identify unique values in categorical columns
SELECT DISTINCT Area FROM salesdata;
SELECT DISTINCT ASM FROM salesdata;
SELECT DISTINCT DASM FROM salesdata;
SELECT DISTINCT SalesMan FROM salesdata;

-- Table size
SELECT COUNT(*) AS num_rows
FROM salesdata;
SELECT COUNT(*) AS num_columns
FROM information_schema.columns
WHERE table_name = 'salesdata';

-- Date range of data
SELECT MAX(order_date), MIN(order_date) 
FROM salesdata;

/*********** Handling Missing Values **************/
-- Missing Values:
SELECT 
    SUM(CASE WHEN Store_ID IS NULL THEN 1 ELSE 0 END) AS store_ids,
    SUM(CASE WHEN Store_Name IS NULL THEN 1 ELSE 0 END) AS names,
    SUM(CASE WHEN Area IS NULL THEN 1 ELSE 0 END) AS areas,
    SUM(CASE WHEN ASM IS NULL THEN 1 ELSE 0 END) AS asm,
    SUM(CASE WHEN DASM IS NULL THEN 1 ELSE 0 END) AS dasm,
    SUM(CASE WHEN SalesMan IS NULL THEN 1 ELSE 0 END) AS salesmen,
    SUM(CASE WHEN Customer_No IS NULL THEN 1 ELSE 0 END) AS ustomer_nos,
    SUM(CASE WHEN Order_Number IS NULL THEN 1 ELSE 0 END) AS order_numbers,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS order_dates,
    SUM(CASE WHEN TimeStamp IS NULL THEN 1 ELSE 0 END) AS timestamps,
    SUM(CASE WHEN Ordered_Value IS NULL THEN 1 ELSE 0 END) AS ordered_values,
    SUM(CASE WHEN Delivered_Value IS NULL THEN 1 ELSE 0 END) AS delivered_values,
    SUM(CASE WHEN Sugar IS NULL THEN 1 ELSE 0 END) AS sugar,
    SUM(CASE WHEN FMCG IS NULL THEN 1 ELSE 0 END) AS fmcg,
    SUM(CASE WHEN Delivered_Amt_without_Sugar_FMCG IS NULL THEN 1 ELSE 0 END) AS null_delivered_amt_without_sugar_fmcg
FROM salesdata;

-- There is null value in dasm, delivered_values, sugar, fmcg

/*********** Handling Duplicates Values **************/
SELECT Store_ID,
    Order_Number,
    COUNT(*) AS duplicate_count
FROM salesdata
GROUP BY Store_ID, Order_Number
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 🔎 Observations and Conclusions:
-- The column DASM have almost 40 percent value is null there is many in company when DISTRIC Area Sales Manager not availbale then it's handle by reginal sales manager
-- So replace NULL VALYE IN DASM WITH RSM(reginal sales manager)
-- Change Order Date data type to Date.
-- Change customer No column datatype to datetime2
-- Changes column TimeStamp datatype to datetime2.
-- Changes column Customer number to integer
-- Rename column timestamp otherwise it could conflict due to timestamp is reserved word in msqlserver
-- The values in column Order number need to be split because it contains Store ID along with Order number with delimeter '/'.
-- The columns Order number should be int instead of varchar.
-- Area could be merged in one entity rather than east west or south north but comapy has fixed it based on potential of business
-- so for big data it make sense to do but i do not think it would be better here so skip it. 
-- Delivery amount seeing higher than order amount due to manual data entry of driver so it needed to fix.
-- Order amount of sugar and FMCG(other than staples and dryfruits) is very less frequent and contains zero
-- Due to high cost here comapre to local delership and it's not company core product and very less profit margin 
-- so it could be avoided we are going to do overall sales analysis that's what company core business staples
-- There are 12740 rows and 15 columns between the date of 01-02-2023 and 31-10-2023


/************* Handling Inconsistent Data ****************/
-- Rename TIMESTAMP columns
EXEC sp_rename 'salesdata.TIMESTAMP', 'Time_stamp', 'COLUMN';

-- Updating Order_Number 
UPDATE salesdata
SET Order_Number = SUBSTRING(Order_Number, CHARINDEX('/', Order_Number) + 1, LEN(Order_Number));


/************* Standardizing Data Formats ****************/
-- Convert Order Date Datatype.
UPDATE salesdata
SET Order_Date = CONVERT(DATE, Order_Date, 105);


ALTER TABLE salesdata
ALTER COLUMN Order_Date DATE;


-- Convert column TimeStamp Datatype.
UPDATE salesdata
SET Time_Stamp= CONVERT(DATETIME2, Time_Stamp, 105);


ALTER TABLE salesdata
ALTER COLUMN time_stamp DATETIME2;


-- Change DataType of Order_number to int
ALTER TABLE salesdata
ALTER COLUMN Order_Number INT;

-- Change Customer_No column datatype to int
UPDATE salesdata
SET Customer_No = CONVERT(INT, Customer_No, 105);
-- it's throwing error The conversion of the varchar value '7666239349' overflowed an int column.


ALTER TABLE salesdata
ALTER COLUMN Customer_No INT;
-- it's throwing error The conversion of the varchar value '7666239349' overflowed an int column.

-- let's check size of 
SELECT MAX(Customer_No), MIN(Customer_No)
FROM salesdata; -- 9998959049	1561240549 It might be occuring due to int handle size of data -2,147,483,648 to 2,147,483,647

-- let's try big int
UPDATE salesdata
SET Customer_No = CONVERT(BIGINT, Customer_No, 105);
-- Now Error Msg 8114, Level 16, State 5, Line 136 Error converting data type varchar to bigint.
-- Now seems there are some value that can not be converted to bigint
SELECT Customer_No
FROM salesdata
WHERE ISNUMERIC(Customer_No) = 0;
-- results return column value 98194 5449 like so it's occuring due to space in int

-- Let's replace it
UPDATE salesdata
SET Customer_No = CASE WHEN ISNUMERIC(Customer_No) = 0 THEN '0' ELSE Customer_No END;

ALTER TABLE salesdata
ALTER COLUMN Customer_No BIGINT;


/************** Creating Derived Columns: ***************/
-- Correct Delivered_value column otherwise it could lead negative value during creating  Undelivered_value column which is not the case in business 
UPDATE salesdata
SET Delivered_Value = (
    CASE
        WHEN Delivered_Value = FLOOR(Ordered_Value) OR Delivered_Value = CEILING(Ordered_Value) THEN Ordered_Value
        ELSE Delivered_Value
    END)

-- Check first before updating
SELECT 
Ordered_Value,
Delivered_Value,
CASE
    WHEN (Delivered_Value = FLOOR(Ordered_Value)) OR (Delivered_Value = CEILING(Ordered_Value)) THEN Ordered_Value
    ELSE Delivered_Value
END
FROM salesdata


-- Add column Undelivered_value
ALTER TABLE salesdata
ADD Undelivered_value float;

UPDATE salesdata
SET Undelivered_value = ROUND(ABS((Delivered_Value - Ordered_Value)),2)


SELECT *
FROM salesdata
WHERE Undelivered_value IS NULL -- 2108
-- There are ordered that does not got delivered almost 2108 that's null value it should be need to be 0

SELECT * FROM SALESDATA;

UPDATE salesdata
SET Undelivered_value = 0 WHERE Undelivered_value IS NULL


/************** Filtering and Subsetting Data ***************/
ALTER TABLE salesdata
DROP COLUMN Delivered_Amt_without_Sugar_FMCG
DROP COLUMN FMCG
DROP COLUMN Sugar;

/************** Data Validation ***************/
SELECT * FROM salesdata

-- View data type and columns
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'salesdata';

SELECT
    Store_ID,
    Order_Number,
    COUNT(*) AS duplicate_count
FROM salesdata
GROUP BY Store_ID, Order_Number
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

/************ Now Data Has Been Cleaned And ready for analysys **************/


/********************************************/
/********* Part 2 Sales Analysys *********/

/****** A Quick Sales Overview and Summary ********/
SELECT 
    ROUND(SUM(Ordered_Value), 2) AS Total_Ordered,
	ROUND(SUM(Delivered_Value), 2) AS Total_Delivered_Value,
	ROUND(SUM(Undelivered_value), 2) AS Total_Undelivered_values
FROM salesdata;

-- Total FakeOrder value
SELECT 
    ROUND(SUM(Ordered_Value), 2) AS Total_Cancellation
FROM salesdata
WHERE Delivered_Value = 0

-- Conclusion: Overall revenue 787612350.92 Delivered value 648748741.47 and Undelivered 124733011.7 in which 58674265.11 is Faked Ordered value

/************  Time Series Analysis  **************/
-- Sales Performance Over The time
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

--  Conclusion: In The month of March highest sales followed by and May, Septamber has least followed by december.

-- Tracking changes in Cancellation 
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    ROUND(SUM(Ordered_Value), 2) AS Cancelled_order,
	RANK() OVER(ORDER BY SUM(Ordered_Value)) AS RN
FROM salesdata
WHERE Delivered_Value = 0
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY year, MONTH(Order_Date);
-- Conclusion: There is no improment is seeing over time It's seeing in oct and nivember but that's minth compnay has not full stocks


-- Tracking changing in canclalation over each month for is there any improment
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
    ROUND(ABS(SUM(Undelivered_value) - 
	LAG(SUM(Undelivered_value), 1, 0) OVER (ORDER BY YEAR(Order_Date), MONTH(Order_Date))),2) AS last_monthly_sales
FROM salesdata
WHERE Delivered_Value = 0
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY MONTH(Order_Date);
-- Conclusion Order cancellation is going up month by month

-- Number of Sales Representative over the time
SELECT 
    YEAR(Order_Date) AS Year,
    DATENAME(month, Order_Date) AS Month,
	ROUND(SUM(Ordered_Value), 2) AS Ordered_Sales,
    COUNT(DISTINCT SalesMan) AS Number_Of_Salesmans
FROM salesdata
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(month, Order_Date)
ORDER BY year, MONTH(Order_Date);

-- Conclusion: NUmber of hiring increase in november and december but overall sales decrese in comparasion to past months

-- Days Which have highest Sales value Over the time
SELECT Top 10 Order_Date, ROUND(SUM(Ordered_Value),2) AS TotalRevenue
FROM SalesData
GROUP BY Order_Date
ORDER BY TotalRevenue DESC;
-- Conclusion: Biggest spike days is near holi festival

/************  Area Sales Analysis  **************/
/* Total sales (ordered value) by area */
SELECT Area, ROUND(SUM(Ordered_Value),2) AS total_sales
FROM salesdata
GROUP BY Area
ORDER BY total_sales DESC;
-- Area such as Mira road, Nalasopara East, Thane West Vasai have highest sales that is part of western mumbai
-- Conclusion: Western coastal area has high potential

/* Top best performing area by Total sales (ordered value) */
SELECT TOP 10
    Area,
    ROUND(SUM(Ordered_Value),2) AS total_sales,
    RANK() OVER (ORDER BY SUM(Ordered_Value) DESC) AS sales_rank
FROM salesdata
GROUP BY Area;

/* Top 10 worsts performing area by Total sales (ordered value) */
SELECT TOP 10 Area, SUM(Ordered_Value) AS total_sales
FROM salesdata
GROUP BY Area
ORDER BY total_sales ASC;

/* Area Where cancallation occurs most */
SELECT TOP 10 Area, SalesMan,ASM, ROUND(SUM(Ordered_Value),2) AS Total_ordered
FROM salesdata
WHERE delivered_value = 0
GROUP BY AREA, SalesMan, ASM
ORDER BY ROUND(SUM(Ordered_Value),2) DESC;
-- Highest Fake ordered placed in Nalasopara around (1888456.69 + 1529436.78)


/**************  Store analysis ****************/
-- Top Loyals stores by delivered value
SELECT TOP 10 Store_Name, SUM(Ordered_Value) as Total_Ordered, SUM(Delivered_Value) AS Total_delivered
FROM salesdata
GROUP BY Store_Name
ORDER BY total_delivered DESC

-- Stores That places most fake orders
SELECT TOP 10 Store_Name, ROUND(SUM(Ordered_Value),2) AS Total_ordered, Area
FROM salesdata
WHERE delivered_value = 0
GROUP BY Store_Name, Area
ORDER BY ROUND(SUM(Ordered_Value),2) DESC;


/************** Sales representative Analysis ****************/
-- Sales Performance by Salesman:
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
-- Conclusion : Rajendra Patel has highest sales with just 172 customers and mohammed have 404 custmers.

-- Area Penetration Performance by Salesman:
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
-- Neeraj Sahu has 416 followed by Mohammad Saeed Shaikh 404

-- AVG Salesman Penetration In Market
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
ORDER BY AVG(NumberOfCustomers) DESC
-- Salesman AVG Shops Penetration In Market is 145

-- Top performing sales representative performance by Ordered Value
SELECT TOP 10 SalesMan, ROUND(SUM(Delivered_Value),2) AS total_sales
FROM salesdata
GROUP BY SalesMan
ORDER BY total_sales DESC;

-- Sales representative who have highest deliver returnd in value term
SELECT TOP 10 SalesMan, ROUND(SUM(Undelivered_Value),2) AS Undeliver_value
FROM salesdata
GROUP BY SalesMan
ORDER BY Undeliver_value DESC;


-- Salesman who placed Fake Orders most
SELECT TOP 10 SalesMan,ASM, ROUND(SUM(Ordered_Value),2) AS Total_ordered
FROM salesdata
WHERE delivered_value = 0
GROUP BY SalesMan, ASM
ORDER BY ROUND(SUM(Ordered_Value),2) DESC;


/************** ASM (Area sales Manager) Analysis ****************/
SELECT
    ASM,
    ROUND(COUNT(DISTINCT SalesMan),2) AS NumberOfSalesmen,
    ROUND(SUM(Ordered_Value),2) AS TotalOrderedValue,
    ROUND(SUM(Delivered_Value),2) AS TotalDeliveredValue,
	ROUND(SUM(Ordered_Value)/COUNT(DISTINCT SalesMan),2) AS Per_Salesman
FROM salesdata
GROUP BY ASM
ORDER BY Per_Salesman DESC;
-- Conclusion: Bikas is best leader overall who Per SE has average sale of  19370302.76 ruppess over the time

-- Best Perfoming ASM By Overall Delivered Value
SELECT
    ASM,
    ROUND(COUNT(DISTINCT SalesMan),2) AS NumberOfSalesmen,
    ROUND(SUM(Ordered_Value),2) AS TotalOrderedValue,
    ROUND(SUM(Delivered_Value),2) AS TotalDeliveredValue,
	Rank() OVER (Order by SUM(Delivered_Value) DESC) as Rn
FROM salesdata
GROUP BY ASM
ORDER BY TotalDeliveredValue DESC;
-- Conclusion: Darshan has overall highest sales followed by Vikash singh
-- Leaders need to be imporoved : Sanjeev Vedak Amresh Singh Prithwi


/************** Stastical Analysis ****************/
-- Sales distribution of Order values
SELECT 
    PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS Q1,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS median,
    PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY Ordered_Value) OVER() AS Q3
FROM salesdata;
-- Conclusion: Quartile, Quartile3(median), Quartile3 OF order value amount are 3210.26, 3959.7,5786.01 respectally


-- Outliers in delivered values
DECLARE @AvgDeliveredValue FLOAT, @StdevDeliveredValue FLOAT;
SELECT @AvgDeliveredValue = AVG(Delivered_Value),
       @StdevDeliveredValue = STDEV(Delivered_Value)
FROM salesdata;
SELECT Order_Number, Delivered_Value
FROM salesdata
WHERE Delivered_Value > @AvgDeliveredValue + 3 * @StdevDeliveredValue;
-- Conclusion: There are not outliers seens in table



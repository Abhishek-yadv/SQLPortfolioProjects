# 🏨 Hotel Booking Demand - Data Cleaning

## Data Cleaning

Data cleaning is the process of fixing or removing incorrect, corrupted, incorrectly formatted, duplicate, or incomplete data within a dataset. It is crucial to clean the data before analyzing it to ensure that the results obtained and insights uncovered are reliable.

There is no one absolute way to define the steps involved in the process of data cleaning, as the process varies from dataset to dataset. However, the following components should always be taken care of:

- Completeness
- Accuracy
- Validity
- Consistency
- Uniqueness


Introduction:

This dataset contains reservation details for both a city hotel and a resort hotel, detailing the timing of reservations, duration of visits, counts of adults, children, and babies, as well as the availability of parking spaces, among various other aspects.
The goal of this data cleaning project is to prepare and transform the Hotel Booking Demand dataset using SQL queries, ensuring that the data is clean, consistent, and ready for further analysis or modelling tasks.
***Dataset: [Kaggle](https://www.kaggle.com/datasets/jessemostipak/hotel-booking-demand/code?datasetId=511638&sortBy=voteCount) ***

This data cleaning process involve the following steps:
1. **Data Investigation**:
   - Examine the structure of the dataset, including the number of rows and columns.
   - Check for any obvious issues such as unexpected data types or missing values.
   - Investigate any columns with unusual patterns or unexpected values that may require further attention during cleaning.
   
2. **Handling Missing Values**:
   - Identify columns with missing values
   - Decide whether to remove rows with missing values or impute missing values using appropriate techniques (e.g., mean, median, mode imputation)
   - Implement SQL queries to handle missing values based on the chosen approach

3. **Removing Duplicates**:
   - Identify duplicate rows based on a combination of relevant columns
   - Use SQL queries with window functions or common table expressions (CTEs) to identify and remove duplicate rows

4. **Standardizing Data Formats**:
   - Ensure that date, time, and other formatted columns are consistent across the dataset
   - Convert data types and formats using SQL functions (e.g., `CONVERT`, `CAST`, `FORMAT`)

5. **Handling Inconsistent Data**:
   - Identify columns with inconsistent data (e.g., different spellings, abbreviations, or capitalization)
   - Use SQL queries with `CASE` statements, string functions, or regular expressions to standardize inconsistent data

6. **Creating Derived Columns**:
   - Identify the need for new columns based on the analysis requirements
   - Use SQL queries to create derived columns from existing columns (e.g., calculating age from date of birth, extracting month or year from date columns)

7. **Filtering and Subsetting Data**:
   - Identify and remove irrelevant or unnecessary columns
   - Subset the data based on specific criteria (e.g., filtering for a particular hotel, date range, or customer type)

8. **Data Validation**:
   - Implement checks and constraints to ensure data integrity and validity
   - Use SQL queries to identify and handle outliers or invalid data points

The dataset is present in the form of an csv File. which I imported it in the Mysql to continue with the process of Data Cleaning.
Throughout this data cleaning process,I have documented steps taken, any assumptions made.
After completing the data cleaning process, the cleaned and transformed Hotel Booking Demand dataset will be ready for further analysis,
such as exploring descriptive statistics, building predictive models, or generating insights and recommendations for the hotel business.



## 🔍 Data Investigation

#### Check the structure of the dataset
```sql
DESCRIBE hotel_bookings;
```
![l1](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/2350f381-714d-4b89-9e07-6f5a53129ed9)

#### Checking random data records
```sql
SELECT *
FROM hotel_bookings
ORDER BY RAND()
LIMIT 10;
```
![l2](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/7b6e7dc8-b603-4ffe-813e-597daa8fdcef)

#### Rows size in the table
```sql
SELECT COUNT(*) AS num_rows
FROM hotel_bookings;
```
![l3](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/d660e22b-662f-4f25-afbe-501a690f8e3a)

#### Columns size in the table
```sql
SELECT COUNT(*) AS num_columns
FROM information_schema.columns
WHERE table_name = 'hotel_bookings';
```
![l4](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/163c270d-baa8-43ae-9eda-513ccdbc8525)

## 🔎 Observations and Conclusions:

1. The columns `arrival_date_year`, `arrival_date_month`, and `arrival_date_day_of_month` should be merged into one new column named 'arrival_date'.
2. The values in `is_repeated_guest` should be 'yes' or 'no' instead of numbers.
3. Consider changing the column name of `adr` to `average_daily_rate` to avoid confusion.
4. The values in `required_car_parking_spaces` should be 'yes' or 'no' instead of numbers.
5. Total Number of rows in this table is 88876.
6. Total Number of columns in this table is 64.
7. `reservation_status_date` (object) should be converted to a datetime datatype.

## 🧼 Data Cleaning
#### Check the datatype of the dataset
```sql
DESCRIBE hotel_bookings;
```
![l5](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/43beee56-94eb-4c5f-8a99-f93338ba4da4)

#### Checking the null value in column
```sql
SET @custom_sql = 'SELECT NULL AS first_row';
SELECT @custom_sql := CONCAT(@custom_sql, ', SUM(CASE WHEN ', COLUMN_NAME, ' IS NULL THEN 1 ELSE 0 END) AS ', COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'hotel_bookings' AND TABLE_SCHEMA = (SELECT DATABASE());

SET @custom_sql := CONCAT(@custom_sql, ' FROM hotel_bookings');

PREPARE stmt FROM @custom_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
```
![l6](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/046f582b-ab6c-4f45-a8a9-b77a7fb83492)


#### Null value column percent
```sql
WITH Total_rows AS (SELECT COUNT(*)
FROM hotel_bookings),
Total_null AS 
(SELECT COUNT(*)
FROM hotel_bookings
WHERE country IS NULL)
SELECT (Total_null/Total_rows)*100 ;
```

✨ Data Cleansing Report:

1. Convert `reservation_status_date` to datetime datatype.
2. Remove rows with null values in `children`, `country`, and `agent` columns.
3. Drop `company` column as its null values take up more than 70% of rows.
4. Merge `arrival_date_year`, `arrival_date_month`, `arrival_date_day_of_month` into one `arrival_date` column with datetime datatype.
5. Drop columns `arrival_date_year`, `arrival_date_month`, `arrival_date_day_of_month`.
6. Move the `arrival_date` column to the right side of `lead_time`.
7. Convert `is_canceled` from numbers to 'Yes' or 'No'.
8. Change values in `is_repeated_guest` to 'Yes' or 'No'.
9. Change values in `required_car_parking_spaces` to 'Yes' or 'No'.
10. Rename column `adr` to `average_daily_rate`.

#### 1. Convert reservation_status_date from object to datetime.

```sql
ALTER TABLE hotel_bookings
MODIFY COLUMN reservation_status_date DATETIME;
```

#### 2. Remove rows with null values in `children`, `country`, and `agent` columns.
```sql
DELETE FROM hotel_bookings
WHERE children IS NULL OR country IS NULL OR agent IS NULL;
```

#### 3. Drop company column as its null values take up more than 70% of rows:
```sql
ALTER TABLE hotel_bookings
DROP COLUMN company;
```
#### 4. Merge `arrival_date_year`, `arrival_date_month`, `arrival_date_day_of_month` into one `arrival_date` column with datetime datatype.####
Add new column
```sql
ALTER TABLE hotel_bookings
ADD COLUMN arrival_date DATETIME;
```
#### Update arrival_date column
```sql
UPDATE hotel_bookings
SET arrival_date = CONCAT(arrival_date_year, '-', 
                           CASE arrival_date_month
                               WHEN 'January' THEN '01'
                               WHEN 'February' THEN '02'
                               WHEN 'March' THEN '03'
                               WHEN 'April' THEN '04'
                               WHEN 'May' THEN '05'
                               WHEN 'June' THEN '06'
                               WHEN 'July' THEN '07'
                               WHEN 'August' THEN '08'
                               WHEN 'September' THEN '09'
                               WHEN 'October' THEN '10'
                               WHEN 'November' THEN '11'
                               WHEN 'December' THEN '12'
                               ELSE '00' END,
                           '-', 
                           arrival_date_day_of_month);
```
#### 5. Drop columns `arrival_date_year`, `arrival_date_month`, `arrival_date_day_of_month`.
```sql
ALTER TABLE hotel_bookings
DROP COLUMN arrival_date_year,
DROP COLUMN arrival_date_month,
DROP COLUMN arrival_date_day_of_month
```

#### 6. Move the `arrival_date` column to the right side of `lead_time`.
```sql
ALTER TABLE hotel_bookings
CHANGE COLUMN arrival_date arrival_date Datetime AFTER lead_time;
```

#### 7. Convert `is_canceled` from numbers to 'Yes' or 'No'.
```sql
UPDATE hotel_bookings
SET is_canceled = CASE WHEN is_canceled = 1 THEN 'Yes' ELSE 'No' END;
```

#### 8. Change values in `is_repeated_guest` to 'Yes' or 'No'.
```sql
UPDATE hotel_bookings
SET is_repeated_guest = CASE WHEN is_repeated_guest = 1 THEN 'Yes' ELSE 'No' END;
```

### Notable: throwing an error due to compatibility of column datatype, so we should alter it
```sql
ALTER TABLE hotel_bookings
MODIFY COLUMN is_repeated_guest VARCHAR(3);
```

Now let's do it
```sql
UPDATE hotel_bookings
SET is_repeated_guest = CASE WHEN is_repeated_guest = 1 THEN 'Yes' ELSE 'No' END;
```

#### 9. Change values in `required_car_parking_spaces` to 'Yes' or 'No'.
```sql
ALTER TABLE hotel_bookings
MODIFY COLUMN required_car_parking_spaces VARCHAR(3);
```

```sql
UPDATE hotel_bookings
SET required_car_parking_spaces = CASE WHEN required_car_parking_spaces > 0 THEN 'Yes' ELSE 'No' END;
```

#### 10. Rename column `adr` to `average_daily_rate`.

```sql
ALTER TABLE hotel_bookings
RENAME COLUMN adr TO average_daily_rate;
```

## 📊 Final Result

```sql
/*************************/
/***Check Final Result **/
SELECT *
FROM hotel_bookings
ORDER BY RAND()
LIMIT 10;
```
![last](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/4546a7fc-b1f4-4953-88c1-4614e169dab9)
```sql
DESCRIBE hotel_bookings
```
![KASCHARALAST3](https://github.com/Abhishek-yadv/SQLPortfolioProjects/assets/68497250/f6360d77-8f9d-416a-9bdb-0b0728137c4c)

🎉 Now this Dataset has been cleaned and transformed 🚀

Sure, I can help you with that. Here's the README.md file in the same format as the provided sample, using the SQL code you provided:

# 🏨 Hotel Booking Demand - Data Cleaning

## Data Cleaning

Data cleaning is the process of fixing or removing incorrect, corrupted, incorrectly formatted, duplicate, or incomplete data within a dataset. It is crucial to clean the data before analyzing it to ensure that the results obtained and insights uncovered are reliable.

There is no one absolute way to define the steps involved in the process of data cleaning, as the process varies from dataset to dataset. However, the following components should always be taken care of:

- Completeness
- Accuracy
- Validity
- Consistency
- Uniqueness

## About the Dataset

This dataset encompasses reservation details for both a city hotel and a resort hotel, detailing the timing of reservations, duration of visits, counts of adults, children, and babies, as well as the availability of parking spaces, among various other aspects.

The dataset contains 88876 rows and 64 columns. The attributes included are hotel, arrival date, lead time, reservation status, and various other booking-related details.

## Cleaning up the Data

The dataset is provided in a tabular format. I imported it into a SQL database to continue with the process of data cleaning.

### 1. Convert `reservation_status_date` to datetime datatype

**Before:**

The `reservation_status_date` column was of the `object` datatype.

```sql
ALTER TABLE hotel_bookings
MODIFY COLUMN reservation_status_date DATETIME;
```

**After:**

The `reservation_status_date` column is now of the `datetime` datatype.

### 2. Remove rows with null values in specific columns

**Before:**

The dataset contained rows with null values in the `children`, `country`, and `agent` columns.

```sql
DELETE FROM hotel_bookings
WHERE children IS NULL OR country IS NULL OR agent IS NULL;
```

**After:**

Rows with null values in the `children`, `country`, and `agent` columns have been removed.

### 3. Drop the `company` column

**Before:**

The `company` column had more than 70% of its values as null.

```sql
ALTER TABLE hotel_bookings
DROP COLUMN company;
```

**After:**

The `company` column has been dropped from the dataset.

### 4. Merge `arrival_date` columns into one column

**Before:**

The arrival date was split into three separate columns: `arrival_date_year`, `arrival_date_month`, and `arrival_date_day_of_month`.

```sql
ALTER TABLE hotel_bookings
ADD COLUMN arrival_date DATETIME;

UPDATE hotel_bookings
SET arrival_date = CONCAT(arrival_date_year, '-',
                           CASE arrival_date_month
                               WHEN 'January' THEN '01'
                               ... -- [Omitted for brevity]
                           END,
                           '-',
                           arrival_date_day_of_month);

ALTER TABLE hotel_bookings
DROP COLUMN arrival_date_year,
DROP COLUMN arrival_date_month,
DROP COLUMN arrival_date_day_of_month;
```

**After:**

A new `arrival_date` column has been created with the datetime datatype, and the original three columns have been dropped.

### 5. Move the `arrival_date` column

**Before:**

The `arrival_date` column was positioned after the `arrival_date_day_of_month` column.

```sql
ALTER TABLE hotel_bookings
CHANGE COLUMN arrival_date arrival_date Datetime AFTER lead_time;
```

**After:**

The `arrival_date` column has been moved to the right side of the `lead_time` column.

### 6. Convert `is_canceled` to 'Yes' or 'No'

**Before:**

The `is_canceled` column had numerical values (0 or 1).

```sql
UPDATE hotel_bookings
SET is_canceled = CASE WHEN is_canceled = 1 THEN 'Yes' ELSE 'No' END;
```

**After:**

The `is_canceled` column now contains 'Yes' or 'No' values instead of numbers.

### 7. Change values in `is_repeated_guest` to 'Yes' or 'No'

**Before:**

The `is_repeated_guest` column had numerical values (0 or 1).

```sql
ALTER TABLE hotel_bookings
MODIFY COLUMN is_repeated_guest VARCHAR(3);

UPDATE hotel_bookings
SET is_repeated_guest = CASE WHEN is_repeated_guest = 1 THEN 'Yes' ELSE 'No' END;
```

**After:**

The `is_repeated_guest` column now contains 'Yes' or 'No' values instead of numbers.

### 8. Change values in `required_car_parking_spaces` to 'Yes' or 'No'

**Before:**

The `required_car_parking_spaces` column had numerical values.

```sql
ALTER TABLE hotel_bookings
MODIFY COLUMN required_car_parking_spaces VARCHAR(3);

UPDATE hotel_bookings
SET required_car_parking_spaces = CASE WHEN required_car_parking_spaces > 0 THEN 'Yes' ELSE 'No' END;
```

**After:**

The `required_car_parking_spaces` column now contains 'Yes' or 'No' values instead of numbers.

### 9. Rename column `adr` to `average_daily_rate`

**Before:**

The column name `adr` was not descriptive.

```sql
ALTER TABLE hotel_bookings
RENAME COLUMN adr TO average_daily_rate;
```

**After:**

The column has been renamed to `average_daily_rate` for better clarity.

***

#### ➡️ Have a final look at the Cleaned Data

```sql
SELECT *
FROM hotel_bookings
ORDER BY RAND()
LIMIT 10;
```

<br />

Now, the data has become more complete, accurate, consistent, and unique, and is ready for analysis and generating insights.

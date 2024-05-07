# 🏠 Data Cleaning using SQL : Nashville Housing Data

## Data Cleaning

Data cleaning is the process of fixing or removing incorrect, corrupted, incorrectly formatted, duplicate, or incomplete data within a dataset. It is important to clean the data before analyzing it so that the results obtained and insights uncovered are reliable.


There is no one absolute way to define the steps involved in the process of data cleaning as the process varies from dataset to dataset. However, the following components should always be taken care of.

- Completeness
- Accuracy
- Validity
- Consistency
- Uniqueness


## About the Dataset

This is a public dataset about the Houses present in the Nashville City of USA. And it is freely available on the website of Kaggle.
It contains more than **56000** rows and **31** columns. The attributes included are UniqueID of the house, its ParcelID and Address, Owner's Name and Address, Sale Date, Sale Price and Legal Reference and many more.

***Dataset: [Link](https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data)***


## Cleaning up the data

The dataset is present in the form of an Excel File. I imported it in the SQL Server to continue with the process of Data Cleaning.

### 1. Standardising the Date Format (Relevancy)

Currently, the `SaleDate` has the data type **DATETIME** and contains the timestamp which is irrelevant here.
So, I'll convert it into **DATE** to get rid of the timestamp.

**Before:**

![NH1 Uncleaned](https://user-images.githubusercontent.com/96012488/207054755-bd9c8c91-0142-49e9-ac3d-8aee6c91058d.png)

````sql
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);
````

**After:**

![NH 1 Cleaned](https://user-images.githubusercontent.com/96012488/207055312-013b8e3f-0486-446e-8b34-126a0418559f.png)

### 2. Populating null Property Address values (Completeness)

````sql
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL;
````

**Before:**

![NH 2 Uncleaned](https://user-images.githubusercontent.com/96012488/207055826-1474a1c1-47b2-472a-ae8e-a249ddb81710.png)

- Thus, we have a few properties whose addresses are not provided in the dataset.

After a little bit of exploring the dataset, I realized that properties having the same `ParcelID` have the same `PropertyAddress`. So, what we can do is for
the properties with null 'PropertyAddress' but a matching 'ParcelId' with some other property, we can fill the same 'PropertyAddress' as that of the matching Property.

- This can be done using **Self Join.**
 

➡️ Fetching relevant PropertyAddresses to fill the null values


- Here, we join the table `NashvilleHousing` with itself where the ParcelID are same but the UniqueID are different.

````sql
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) AS required_address
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
````

![NH 2 Cleaned (1)](https://user-images.githubusercontent.com/96012488/207056536-8dcd4320-94f0-4ef6-af6a-aa7cd49925a6.png)


➡️ Filling the null values with the relevant data


````sql
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
````

- Now we can see, there are no properties with vacant PropertyAddress column.

![NH 2 Cleaned (2)](https://user-images.githubusercontent.com/96012488/207057526-aa7e232d-6e9a-4725-bd55-fad84d4814db.png)

### 3. Breaking Out Address into Individual Columns (Address, City and State) 

**(a) Starting Out with `PropertyAddress`**

````sql
SELECT PropertyAddress
FROM NashvilleHousing;
````

**Before:**

![NH 3 Uncleaned ](https://user-images.githubusercontent.com/96012488/207066771-a3fe0f20-babc-4c0a-87c9-44dbdedc69bc.png)

- As we can see, there is a comma acting as a delimiter between the Address and the City Name in all the rows. Also, there are no other commas except for this one.
So, we can use **SUBSTRING** with **CHARINDEX** to divide `PropertyAddress` into `Address` and `City`.

➡️ Specifying what do we want

````sql
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashvilleHousing
````

![NH 3 Cleaned (1)](https://user-images.githubusercontent.com/96012488/207067947-b95e61fd-e142-4362-85f0-200afc998cb0.png)


➡️ Adding 2 new columns to the table

````sql
ALTER TABLE NashvilleHousing
ADD PropertyAddressNew NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR(255);
````

➡️ Filling those 2 new columns with the relevant values

````sql
UPDATE NashvilleHousing
SET PropertyAddressNew = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) FROM NashvilleHousing;

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));
````

![NH 3 Cleaned ](https://user-images.githubusercontent.com/96012488/207068020-edfecc8d-bc19-48b0-8679-916346b6e885.png)

**(b) Splitting the `OwnerAddress` column now**

- The same can be done for the column `OwnerAddress`. It contains three pieces of information: `Address`, `City` and the `State`.
- This time we'll do it using a function called **PARSENAME()**. 
- PARSENAME() can extract substrings from a string given the substrings are separated by Periods. Here, we have comma as the delimiter. So, we'll use **REPLACE()** to substitute the comma with a period.


````sql
Select OwnerAddress from NashvilleHousing;
````

![NH 4 Uncleaned](https://user-images.githubusercontent.com/96012488/207069442-5fa1df58-d79d-465b-8f05-be73b1467607.png)


 ➡️ Specifying what we want

````sql
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) State
FROM NashvilleHousing;
````

![NH 4 Cleaned (1)](https://user-images.githubusercontent.com/96012488/207240804-692ce99a-c45f-4684-baf5-9e9ffc775350.png)


➡️ Adding 3 new columns 

````sql
ALTER TABLE NashvilleHousing
ADD OwnerAddressNew NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerState NVARCHAR(255);
````

➡️ Filling the 3 columns with relevant values

````sql
UPDATE NashvilleHousing
SET OwnerAddressNew = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

UPDATE NashvilleHousing 
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);
````

![NH 4 Cleaned (2)](https://user-images.githubusercontent.com/96012488/207240775-fdab969c-2157-4026-bb75-46af74cf89ac.png)

### 4. Changing Y and N to Yes and No in 'Sold as Vacant' field (Consistency)

➡️ Checking what distinct values are there in SoldAsVacant Column

````sql
SELECT DISTINCT (SoldAsVacant)
FROM NashvilleHousing
````

➡️ Making relevant changes

````sql
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END;
````

### 5. Removing Duplicates (Uniqueness)

- Identifying duplicates using Row_Number function and CTE
- Deleting duplicates

````sql
With RowNumcte AS
(
SELECT  * ,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SaleDate,
			SaLePrice,
			LegalReference
			ORDER BY UniqueID) Rownum
FROM NashvilleHousing
) 
DELETE
FROM RowNumcte
WHERE Rownum>1;
````


### 6. Deleting Unused Columns

- As we already have the address,city and state as individual columns from the 'PropertyAddress' and 'OwnerAddress', we're gonna drop these two.
- Also, TaxDistrict doesn't seem to serve much purpose here, so we'll delete that too.

````sql
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict;
````

***

#### ➡️ Have a final look at the Cleaned Data

````sql
SELECT * 
FROM NashvilleHousing; 
````

<br />

Now, the data has become more complete and accurate to be used for analysis and generating insights. 






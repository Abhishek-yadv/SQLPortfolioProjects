/*********************************/
/* Cleaning Data in SQL Queries */

SELECT *
FROM PortfolioProject..NashvilleHousing$

-----------------------------------------------------------
/********************************/
-- Standardise Date Format

SELECT SaleDate, OwnerName
FROM PortfolioProject..NashvilleHousing$


/******/
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing$


/******/
UPDATE NashvilleHousing$
SET SaleDate = CONVERT(Date, SaleDate)


/******/
ALTER TABLE NashvilleHousing$
Add SaleDateConverted Date;


/******/
UPDATE NashvilleHousing$
SET SaleDateConverted = CONVERT(Date, SaleDate)


/******/
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing$


---------------------------------------------------------
/***************************************/
/*** Populate Property address data ***/

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing$
WHERE PropertyAddress IS NOT NULL


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing$
WHERE PropertyAddress IS NULL


SELECT *
FROM PortfolioProject..NashvilleHousing$
WHERE PropertyAddress IS NULL


SELECT *
FROM PortfolioProject..NashvilleHousing$
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT *
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] = b.[UniqueID ]
	 WHERE a.PropertyAddress IS NULL


SELECT *
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 WHERE a.PropertyAddress IS NULL


SELECT *
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NOT NULL


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) --/ ISNULL(a.PropertyAddress, NoAddress)
FROM PortfolioProject..NashvilleHousing$ a
JOIN PortfolioProject..NashvilleHousing$ b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]



---------------------------------------------------------------
---------------------------------------------------------------
/* Breaking out Address Indidual Columns (Address, City, State) */
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing$
-- WHERE PropertyAddress is null
-- ORDER BY ParcelID


/* A Delimeter is something that separate diffrent column or diffrent value */
/* For Us it's called comma */
/* CHARINDEX is basically searching for specific value */
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address --',' means we looking for comma and where loooking for is In PartyAddress
-- CHARINDEX(',', PropertyAddress) this is basically specifiing position it's not value not string it's number
-- it's starting from 1 and upto comma ','
FROM PortfolioProject..NashvilleHousing$


-- For example 
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address, --',' means we looking for comma and where loooking for is In PartyAddress
 CHARINDEX(',', PropertyAddress) AS count_till_del, Len(PropertyAddress) as Len_add
FROM PortfolioProject..NashvilleHousing$


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, --',' means we looking for comma and where loooking for is In PartyAddress
 (CHARINDEX(',', PropertyAddress) -1) AS count_till_del, Len(PropertyAddress) as Len_add -- Here it's okay to be not comma
FROM PortfolioProject..NashvilleHousing$


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
 CHARINDEX(',', propertyAddress)-1, Len(PropertyAddress) as Len
FROM PortfolioProject..NashvilleHousing$


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
 CHARINDEX(',', propertyAddress), Len(PropertyAddress) as Len
FROM PortfolioProject..NashvilleHousing$


SELECT PropertyAddress, LEN(PropertyAddress)
FROM PortfolioProject..NashvilleHousing$


/* Now we don't want to start from 1 position anymore, now we want to from where comma start */
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address -- +1 bcz we get rid of coomma rather than mentionaing it

FROM PortfolioProject..NashvilleHousing$


-- that's like this
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) , LEN(PropertyAddress)) AS Address -- +1 bcz we get rid of coomma rather than mentionaing it

FROM PortfolioProject..NashvilleHousing$


/******/
/** If you remove 1 here you will get start from comma can't rid of **/
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) , LEN(PropertyAddress)) AS Address

FROM PortfolioProject..NashvilleHousing$

/******/
/* we can't separate two values into from one column without creating two other columns */

ALTER TABLE NashvilleHousing$
Add PropertySplitAddress NVARCHAR(255);


UPDATE NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing$
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing$


/************************************************/
/***********************************************/
/* Even shorter Version to tackle delimeter */
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing$


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '/') , 1)
FROM PortfolioProject..NashvilleHousing$


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '-') , 1)
FROM PortfolioProject..NashvilleHousing$


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', ';') , 1)
FROM PortfolioProject..NashvilleHousing$


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..NashvilleHousing$


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..NashvilleHousing$


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
FROM PortfolioProject..NashvilleHousing$


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..NashvilleHousing$


ALTER TABLE NashvilleHousing$
Add OwnerSplitAddress NVARCHAR(255);


UPDATE NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing$
ADD OwnerSplitCity NVARCHAR(255);


UPDATE NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing$
Add OwnerSplitState NVARCHAR(255);


UPDATE NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);


ALTER TABLE NashvilleHousing$
Add OwnerSplitState NVARCHAR(255);

SELECT *
FROM NashvilleHousing$


-------------------------------------------------------------------
/*************************************************/
/* CHANGE Y and N to Yes and No in "Sold as vacant" field */
SELECT * FROM
PortfolioProject.dbo.NashvilleHousing$

SELECT Distinct(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing$


SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing$  -- Err bcz already know Msg agg func is invalid if not contained an agg function or GROUP BY CLAUSE
-- 8120, Level 16, State 1, Line 293 Column 'PortfolioProject..NashvilleHousing$.SoldAsVacant' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.


SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing$
GROUP BY SoldAsVacant


SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) 
FROM PortfolioProject..NashvilleHousing$
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant --  if already value as yes or no keep it as same soldvacant
	 END
FROM PortfolioProject..NashvilleHousing$



Update NashvilleHousing$
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing$


-- Now let's check
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing$
GROUP BY SoldAsVacant
ORDER BY 2



----------------------------------------------------------------------------
/****************************************************/
/* REMOVE DUPLICATES */
SELECT *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			    ORDER BY
				   UniqueID
				   ) row_num
FROM PortfolioProject..NashvilleHousing$


/* REMOVE DUPLICATES */
SELECT *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			    ORDER BY
				   UniqueID
				   ) row_num
FROM PortfolioProject..NashvilleHousing$
ORDER BY ParcelID



SELECT *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			    ORDER BY
				   UniqueID
				   ) row_num
FROM PortfolioProject..NashvilleHousing$
ORDER BY ParcelID
WHERE row_num > 1;
--That is bcz windows functions


WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			    ORDER BY
				   UniqueID
				   ) row_num
 
FROM PortfolioProject..NashvilleHousing$
-- Order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


/***********************************************************/
/* If we want to delete everything from that are duplicate*/
WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			    ORDER BY
				   UniqueID
				   ) row_num
 
FROM PortfolioProject..NashvilleHousing$
-- Order by ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
-- ORDER BY PropertyAddress

/********************************************/
/********** Now lets check duplicates ******/
WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			    ORDER BY
				   UniqueID
				   ) row_num
 
FROM PortfolioProject..NashvilleHousing$
-- Order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			    ORDER BY
				   UniqueID
				   ) row_num
 
FROM PortfolioProject..NashvilleHousing$
-- Order by ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
-- ORDER BY PropertyAddress


-----------------------------------------------------------------------------
/****************************************/
/*************** DELETE Unused Column **/
SELECT *
FROM PortfolioProject..NashvilleHousing$


ALTER TABLE PortfolioProject..NashvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

-- let's check
SELECT *
FROM PortfolioProject..NashvilleHousing$

ALTER TABLE PortfolioProject..NashvilleHousing$
DROP COLUMN SaleDate




/* 

Data Cleaning in SQL - An ETL Process

*/

SELECT *
FROM PortfolioProject...nashville_housing

-----------------------------------------------------------------------------------------------------

/* Standardization of Date Format */

SELECT SaleDate, 
	CONVERT(Date, SaleDate)
FROM PortfolioProject..nashville_housing

UPDATE nashville_housing
	SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE nashville_housing
ADD SaleDateConverted Date;

UPDATE nashville_housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------------
-- Populating Property Address Data --

SELECT *
FROM PortfolioProject..nashville_housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..nashville_housing a
	JOIN PortfolioProject..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..nashville_housing a
	JOIN PortfolioProject..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------------------------------------------------------

--Breaking the Property Address column into Address, City, State--

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..nashville_housing

ALTER TABLE nashville_housing
ADD PropertySplitAddress nvarchar(255);

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE nashville_housing
ADD PropertySplitCity nvarchar(255);

UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS OwnerSplitAddress,
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS OwnerSplitCity,
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS OwnerSplitState
FROM nashville_housing


ALTER TABLE nashville_housing
ADD OwnerSplitAddress nvarchar(255);

UPDATE nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE nashville_housing
ADD OwnerSplitCity nvarchar(255);

UPDATE nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE nashville_housing
ADD OwnerSplitState nvarchar(255);

UPDATE nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)





-----------------------------------------------------------------------------------------------------

--Changing Y and N to Yes and No in "sold as vacant field"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..nashville_housing

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

/*SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

Repeating the query to confirm the changes
*/

-----------------------------------------------------------------------------------------------------

--Removing Duplicates from Dataset--

WITH RowNumCTE AS(
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
FROM PortfolioProject..nashville_housing
--ORDER BY ParcelID--
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


WITH RowNumCTE AS(
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
FROM PortfolioProject..nashville_housing
--ORDER BY ParcelID--
)
SELECT *
FROM RowNumCTE
ORDER BY PropertyAddress

-----------------------------------------------------------------------------------------------------

/*
Deleting Unused Columns 

NOTE It's not ideal to delete data from a proprietary dataset, it's recommended you copy the dataset and work with the copied part.
If the need arises for part of the deleted data to be used you can easily refer to the original

*/

SELECT *
FROM PortfolioProject..nashville_housing


ALTER TABLE PortfolioProject..nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE PortfolioProject..nashville_housing
DROP COLUMN SaleDate
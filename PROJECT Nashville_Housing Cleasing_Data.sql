--- CLEASING DATA ---

--- NASHVILLE HOUSING DATA
USE Portfolio_Project;
SELECT TOP 5 * FROM Nashville_Housing

--- STANDARDIZE DATA FORMAT
SELECT SaleDateConverted, CAST(SaleDate AS DATE) 
FROM Nashville_Housing

UPDATE Nashville_Housing
SET SaleDate = CAST(SaleDate AS DATE)

ALTER TABLE Nashville_Housing
ADD SaleDateConverted DATE;

UPDATE Nashville_Housing
SET SaleDateConverted = CAST(SaleDate AS DATE)

--- POPULATE PROPERTY ADDRESS DATA
SELECT * FROM Nashville_Housing
--- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> B.[UniqueID] 
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM Nashville_Housing a
	JOIN Nashville_Housing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID] <> B.[UniqueID] 
	WHERE a.PropertyAddress IS NULL

--- BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMS (ADDRESS, CITY)
SELECT PropertyAddress FROM Nashville_Housing
--- WHERE PropertyAddress IS NULL
--- ORDER BY ParcelID

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS	City
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE Nashville_Housing
ADD PropertySplitCity NVARCHAR(255)

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

--- BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMS (ADDRESS, CITY, STATE)
SELECT OwnerAddress FROM Nashville_Housing
--- WHERE PropertyAddress IS NULL
--- ORDER BY ParcelID

SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE Nashville_Housing
SET OwnerSplitCity = 	PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitState NVARCHAR(255)

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--- CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
From Nashville_Housing

UPDATE Nashville_Housing
SET SoldAsVacant = 
				CASE 
					WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
				END

--- REMOVE DUPLICATES
WITH RowNumCTE AS
	(
	SELECT *, ROW_NUMBER() OVER(
								PARTITION BY 
									ParcelID, 
									PropertyAddress, 
									SalePrice,
									SaleDate,
									LegalReference
									ORDER BY 
										UniqueID
								) row_num
	FROM Nashville_Housing
	--- ORDER BY ParcelID 
	)
SELECT * FROM RowNumCTE
--- DELETE FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--- DELETE UNUSED COLUMNS
SELECT * FROM Nashville_Housing

ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

/* Cleaning data */

/*Populate Property Address data*/
SELECT first.ParcelID, first.PropertyAddress, second.ParcelID, second.PropertyAddress, ISNULL(first.PropertyAddress, second.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] first
JOIN NashvilleHousing second
ON first.ParcelID = second.ParcelID
AND first.UniqueID <> second.UniqueID
WHERE first.PropertyAddress IS NULL

UPDATE first
SET PropertyAddress = ISNULL(first.PropertyAddress, second.PropertyAddress)
FROM [PortfolioProject].[dbo].[NashvilleHousing] first
JOIN NashvilleHousing second
ON first.ParcelID = second.ParcelID
AND first.UniqueID <> second.UniqueID
WHERE first.PropertyAddress IS NULL



/* Breaking out address into individual columns (address, city, state) */

 SELECT *
 FROM [NashvilleHousing ]

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD LandAddress Nvarchar(255);

UPDATE NashvilleHousing
SET LandAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD LandCity Nvarchar(255);

UPDATE NashvilleHousing
SET LandCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM [NashvilleHousing ]



-- Separating Owner Address data

SELECT OwnerAddress
FROM [NashvilleHousing ]

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [NashvilleHousing ]

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM [NashvilleHousing ]



--Change the bit datatype used to store the SoldAsVacant data to varchar.

SELECT *
FROM [NashvilleHousing ]

ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant VARCHAR(10)

SELECT SoldAsVacant
, CASE when SoldAsVacant = '0' then 'No'
	   when SoldAsVacant = '1' then 'Yes'
ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE [NashvilleHousing ]
SET SoldAsVacant = CASE when SoldAsVacant = '0' then 'No'
	   when SoldAsVacant = '1' then 'Yes'
ELSE SoldAsVacant
END



/* Remove Duplicates */

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
	ORDER BY UniqueID) row_num
FROM [NashvilleHousing ]
)
DELETE
FROM RowNumCTE
WHERE row_num > 1  --104 rows were deleted



-- DELETE UNUSED COLUMNS

SELECT *
FROM [NashvilleHousing ]

ALTER TABLE [NashvilleHousing ]
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict






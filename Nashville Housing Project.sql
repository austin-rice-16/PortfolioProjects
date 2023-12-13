USE ProjectPortfolio


SELECT *
FROM ProjectPortfolio..NashvilleHousing

--------

--Standardizing Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE


--Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing a 
JOIN ProjectPortfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing a 
JOIN ProjectPortfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


--Breaking Out Address into Individual Columns


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE [dbo].[NashvilleHousing]
ADD PropertySplitAddress Nvarchar(255);

Update [dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [dbo].[NashvilleHousing]
ADD PropertySplitCity Nvarchar(255);

Update [dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--Now using ParseName instead of Substring to split the Owner's Address

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM ProjectPortfolio..NashvilleHousing


ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerSplitAddress Nvarchar(255);

Update [dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerSplitCity Nvarchar(255);

Update [dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [dbo].[NashvilleHousing]
ADD OwnerSplitState Nvarchar(255);

Update [dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectPortfolio..NashvilleHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM ProjectPortfolio..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Removing Duplicates
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
					) AS row_num

FROM ProjectPortfolio..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns


ALTER TABLE ProjectPortfolio..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

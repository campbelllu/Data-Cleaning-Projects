--Cleaning Data Project
--PortfolioProject.dbo.NashvilleHousingB is the data set that is being manipulated. NashvilleHousing Table is untouched by changes for revert purposes
-------------------------------------------------------------------
--Select All
SELECT *
FROM PortfolioProject..NashvilleHousingB

--------------------------------------------------------------
--Standardize Date Format
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) 

SELECT SaleDateConverted, SaleDate
FROM PortfolioProject..NashvilleHousing

-----------------------------------------------------------------
--Populate Property Address Data
SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingB a
JOIN PortfolioProject..NashvilleHousingB b
ON a.ParcelID = b.ParcelID AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingB a
JOIN PortfolioProject.dbo.NashvilleHousingB b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------
---- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousingB
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousingB


ALTER TABLE PortfolioProject.dbo.NashvilleHousingB
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingB
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.NashvilleHousingB
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingB
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousingB


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousingB


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousingB


ALTER TABLE PortfolioProject.dbo.NashvilleHousingB
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingB
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousingB
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingB
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousingB
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingB
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProject.dbo.NashvilleHousingB

-------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
--See what different statuses we have in the column and how often they occur
Select Distinct(SoldAsVacant), Count(SoldAsVacant) AS TheCount
From PortfolioProject.dbo.NashvilleHousingB
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousingB


Update PortfolioProject.dbo.NashvilleHousingB
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousingB
--ORDER BY ParcelID
                  )
DELETE --SELECT * to test, DELETE to remove duplicates  --Gets rid of these duplicates
From RowNumCTE
Where row_num > 1
Order by PropertyAddress  --commented when delete, used with select to test

Select *
From PortfolioProject.dbo.NashvilleHousingB

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
Select *
From PortfolioProject.dbo.NashvilleHousingB


ALTER TABLE PortfolioProject.dbo.NashvilleHousingB
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
SELECT *
FROM PortfolioProject2..NashvilleHousing
order by ParcelID

-- Standardize Date

SELECT SaleDateConverted, CONVERT(Date, SaleDate) as SaleDate
FROM PortfolioProject2..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

-- Populate Property Address

Select PropertyAddress
FROM PortfolioProject2..NashvilleHousing
Where PropertyAddress is null

-- ISNULL says if the first column you're checking is null then put it into a new column with the information grabbed from the second specified column
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
FROM PortfolioProject2..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address 
From PortfolioProject2..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255); 


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR(255); 

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
From PortfolioProject2..NashvilleHousing

-- PARSENAME only looks for periods instead of commast
SELECT
PARSENAME(REPLACE(OwnerAddress,',' , '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress,',' , '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress,',' , '.'), 1) as State
From PortfolioProject2..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress1 NVARCHAR(255); 

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity1 NVARCHAR(255); 

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress1 = PARSENAME(REPLACE(OwnerAddress,',' , '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity1 = PARSENAME(REPLACE(OwnerAddress,',' , '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',' , '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldasVacant)
FROM PortfolioProject2..NashvilleHousing
group by SoldasVacant
order by 2

Select SoldasVacant,
CASE when SoldasVacant = 'Y' THEN 'Yes'
WHEN SoldasVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject2..NashvilleHousing

UPDATE NashvilleHousing
SET SoldasVacant = CASE when SoldasVacant = 'Y' THEN 'Yes'
WHEN SoldasVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject2..NashvilleHousing

-- Removing Duplicate Data

WITH RowNUMCTE AS (
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
ORDER by UniqueID) row_num
FROM PortfolioProject2..NashvilleHousing
)

DELETE
FROM RowNUMCTE
Where row_num > 1


-- Delete Unused Columns

Select *
From PortfolioProject2..NashvilleHousing

ALTER TABLE PortfolioProject2..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, City, State, OwnerSplitAddress, Address

ALTER TABLE PortfolioProject2..NashvilleHousing
DROP COLUMN SaleDate

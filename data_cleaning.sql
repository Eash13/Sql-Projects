/*

Data CLeaning

*/

Select * 
From Projects.dbo.nashville_housing


-- Standardize Sale Date

Select Saledate, CONVERT(Date, SaleDate)
From Projects.dbo.nashville_housing

ALTER TABLE nashville_housing
Add SaleDateConverted Date;


Update nashville_housing
SET SaleDateConverted = CONVERT(Date,SaleDate)




-- Update Missing Property Address

Select *
From Projects.dbo.nashville_housing
Where PropertyAddress is null

Select *
From Projects.dbo.nashville_housing
order by ParcelID

Select a.ParcelID ,b.ParcelID, a.PropertyAddress, b.PropertyAddress , ISNULL(a.PropertyAddress ,b.PropertyAddress)
From Projects.dbo.nashville_housing a
Join Projects.dbo.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress ,b.PropertyAddress)
From Projects.dbo.nashville_housing a
Join Projects.dbo.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 




-- Splitting the Property Address into City State and Address


Select PropertyAddress 
From Projects.dbo.nashville_housing

Select SUBSTRING(PropertyAddress , 1, CHARINDEX(',',PropertyAddress) -1 ) as Address
	, SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress)) as City
From Projects.dbo.nashville_housing



ALTER TABLE nashville_housing
Add PropertySplitAddress Nvarchar(225);


Update nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1, CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE nashville_housing
Add PropertySplitCity Nvarchar(225);


Update nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress))


Select *
From Projects.dbo.nashville_housing



-- Splitting Owner Address into City, State and Address



Select OwnerAddress
From Projects.dbo.nashville_housing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From Projects.dbo.nashville_housing

ALTER TABLE nashville_housing
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE nashville_housing
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE nashville_housing
Add OwnerSplitState Nvarchar(255);

Update nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Update nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Update nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From Projects.dbo.nashville_housing




-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Projects.dbo.nashville_housing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Projects.dbo.nashville_housing

Update nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-- Remove Duplicates


WITH Temp AS(
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

From Projects.dbo.nashville_housing
)
Select *
From Temp
Where row_num > 1
Order by PropertyAddress


WITH Temp AS(
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

From Projects.dbo.nashville_housing
)
DELETE
From Temp
Where row_num > 1

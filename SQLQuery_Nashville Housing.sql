Select *
From Portfolioproject.dbo.NashvilleHousing



-- Cleaning Nashville Housing Data in SQL Queries --
-- Standardize Date Format --

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert (Date, Saledate)



-- Populate Property Address --

Select *
From PortfolioProject.dbo.NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, Isnull (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as a
Join PortfolioProject.dbo.NashvilleHousing as b
    On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress Is null

Update a
Set PropertyAddress = Isnull (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing as a
Join PortfolioProject.dbo.NashvilleHousing as b
    On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out Property Address into Individual Columns (Address, City) --

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select
Substring (PropertyAddress, 1, Charindex (',', PropertyAddress) -1 ) as Address,
Substring (PropertyAddress, Charindex (',', PropertyAddress) +1, Len (PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = Substring (PropertyAddress, 1, Charindex (',', PropertyAddress) -1 )

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = Substring (PropertyAddress, Charindex (',', PropertyAddress) +1, Len (PropertyAddress))



-- Breaking out Owner Address into Individual Columns (Address, City, State) --

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
Parsename (Replace (OwnerAddress, ',', '.'), 3) as OwnerSplitAddress,
Parsename (Replace (OwnerAddress, ',', '.'), 2) as OwnerSplitCity,
Parsename (Replace (OwnerAddress, ',', '.'), 1) as OwnerSplitState
From PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = Parsename (Replace (OwnerAddress, ',', '.'), 3) 

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = Parsename (Replace (OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = Parsename (Replace (OwnerAddress, ',', '.'), 1)



-- Change Y and N to Yes and No in "Sold as Vacant" Column --

Select Distinct (SoldAsVacant), Count (SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
End
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
     End



-- Remove Duplicates --

With RowNumCTE as(
Select *,
    Row_Number() Over (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
				   UniqueID
				   ) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

With RowNumCTE as(
Select *,
    Row_Number() Over (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
				   UniqueID
				   ) row_num
From PortfolioProject.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1



-- Remove Unused Columns --

Alter table NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, SaleDate
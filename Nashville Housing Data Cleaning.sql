/*

Cleaning Data in SQL Queries Nashville Housing Data Set

*/

select * from [Project Database].dbo.[Nashville Housing];


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate from [Project Database]..[Nashville Housing];

alter table [Project Database]..[Nashville Housing]
alter column Saledate date;



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select PropertyAddress,* from [Project Database].dbo.[Nashville Housing]
where PropertyAddress is null
order by ParcelID;

select  a.ParcelID, a.UniqueID, a.PropertyAddress, b.ParcelID, b.UniqueID , b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Project Database].dbo.[Nashville Housing] a
join [Project Database].dbo.[Nashville Housing] b 
on a.ParcelID = b.ParcelID
and a.UniqueID != b.UniqueID
--where a.PropertyAddress is null	

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Project Database].dbo.[Nashville Housing] a
join [Project Database].dbo.[Nashville Housing] b 
on a.ParcelID = b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress is null	


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

--PropertyAddress

select PropertyAddress from [Project Database]..[Nashville Housing];

select PropertyAddress, substring(propertyAddress, 1, (CHARINDEX(',',PropertyAddress)-1)) as address
					  , SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1), len(PropertyAddress)) as PropertyCity
from [Project Database]..[Nashville Housing];


alter table [Project Database]..[Nashville Housing]
add PropertySplitAddress varchar(255);

update [Project Database]..[Nashville Housing]
set PropertySplitAddress = substring(propertyAddress, 1, (CHARINDEX(',',PropertyAddress)-1))

alter table [Project Database]..[Nashville Housing]
add PropertySplitCity varchar(255);

update [Project Database]..[Nashville Housing]
set PropertySplitCity = SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1), len(PropertyAddress))


--OwnerAdress

select OwnerAddress from [Project Database]..[Nashville Housing];

select OwnerAddress,
	   PARSENAME(replace(OwnerAddress, ',', '.'), 3),
	   PARSENAME(replace(OwnerAddress, ',', '.'), 2),
	   PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from [Project Database]..[Nashville Housing];


alter table [Project Database]..[Nashville Housing]
add OwnerSplitAddress varchar(255);

update [Project Database]..[Nashville Housing]
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3);



alter table [Project Database]..[Nashville Housing]
add OwnerSplitCity varchar(255);

update [Project Database]..[Nashville Housing]
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2);



alter table [Project Database]..[Nashville Housing]
add OwnerSplitState varchar(255);

update [Project Database]..[Nashville Housing]
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1);



select OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from [Project Database]..[Nashville Housing];


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from [Project Database]..[Nashville Housing]
group by SoldAsVacant

select distinct(SoldAsVacant),
	   case when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
			end
from [Project Database]..[Nashville Housing]


update [Project Database]..[Nashville Housing]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with NashvilleCTE 
as(
select * , ROW_NUMBER() over(partition by ParcelID,
					PropertySplitAddress,
					PropertySplitCity,
					saleDate,
					salePrice,
					LegalReference
					order by UniqueId) as row_num
from [Project Database]..[Nashville Housing]
)
delete 
from NashvilleCTE
where row_num > 1;



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From [Project Database]..[Nashville Housing]

Alter table [Project Database]..[Nashville Housing]
drop column PropertyAddress, OwnerAddress


--Since Housing_data is now our cleaned dataset so some queries won't work which used some old columns so for running those queries
--Housing_data_uncleaned must be used.

select * from Housing_data

select count(distinct([UniqueID ]))
from Housing_data

--------------------------------------------
-- formatting date format to a simpler one
-- basically removing unecessary timestamps given and just formatting as a date column

select cast(SaleDate as date) as Sale_date
from dbo.Housing_data

update Housing_data
set sale_date = CAST(SaleDate as date)

alter table Housing_data
add sale_date date

Select * from Housing_data

----------------------------------------
-- populating property address
-- there are cells missing property addresses so we wiil be filling up those with the relative information about the same from the table only.

Select * from Housing_data
where ParcelID = '025 07 0 031.00'

select a.[UniqueID ],a.ParcelID , a.PropertyAddress ,b.ParcelID, b.PropertyAddress , ISNULL(b.PropertyAddress,a.PropertyAddress)
from Housing_data a 
join Housing_data b 
on a.[UniqueID ] <> b.[UniqueID ]
and a.ParcelID = b.ParcelID
where b.PropertyAddress is null

update b
set b.PropertyAddress = ISNULL(b.PropertyAddress,a.PropertyAddress)
from Housing_data a 
join Housing_data b 
on a.[UniqueID ] <> b.[UniqueID ]
and a.ParcelID = b.ParcelID
where b.PropertyAddress is null

select * from Housing_data where PropertyAddress is null -- check query

-----------------------------------------
-- breaking out address into sub parts
-- basically breaking out addresses as address , city , state so each aspect of address can be accessuble individually.

select * from Housing_data

select 
SUBSTRING(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress) -1) as address,
SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as city
from Housing_data

alter table Housing_data
add property_address nvarchar(255) , property_city nvarchar(255)

update Housing_data
set property_address = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',',PropertyAddress) -1),
 property_city = SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

 select * from Housing_data
-----------------------
-- basically a different approach what we did earlier to seperate our address

select PARSENAME(replace(PropertyAddress,',','.'),2),
PARSENAME(replace(PropertyAddress,',','.'),1)
from Housing_data

-----------------------
-------------------------------------------
-- Formatting "soldasvaccant" column
-- formatting Y and N with Yes and No to keep a consistent formatting along the table

select distinct(SoldAsVacant)
from Housing_data

select COUNT(SoldAsVacant),
case
 when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 end
from Housing_data
group by SoldAsVacant

update Housing_data
set SoldAsVacant = case
 when SoldAsVacant = 'Y' then 'Yes'
 when SoldAsVacant = 'N' then 'No'
 else SoldAsVacant
 end

 Select COUNT(SoldAsVacant)
 from Housing_data
 group by SoldAsVacant

 -----------------------------------------------
 -- removing duplicates
 -- although removing amy data from the table itself is not a good prectise but we are gonna do for practise purpose and I do have abckup of this data too.

 select * 
 from Housing_data

with row_num as (
select *, 
row_number() over 
( partition by 
ParcelID,LegalReference,sale_date,SalePrice,YearBuilt 
order by UniqueID) as row_n
from Housing_data )

select * from row_num
where row_n > 1

with row_num as (
select *, 
row_number() over 
( partition by 
ParcelID,LegalReference,sale_date,SalePrice,YearBuilt 
order by UniqueID) as row_n
from Housing_data )

delete from row_num
where row_n > 1

-----------------------------------------------
-- removing some undesired or less useful columns

select * from Housing_data

alter table Housing_data
drop column  PropertyAddress

------------------------------------------------
-- changing some column names

sp_rename 'Housing_data.property_address' , 'Property_Address' , 'Column'
sp_rename 'Housing_data.sale_date' , 'Sale_Date' , 'Column'
sp_rename 'Housing_data.property_city' , 'Property_City' , 'Column'

-------------------------------------------------
--above queries are used to get a cleaned data for further use there are some errors in above queries as some columns have been removed and converted into 
--a more accessible/usable formats.
--So below is the cleaned table that we have obatined.
select * from Housing_data
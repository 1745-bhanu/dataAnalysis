SELECT * FROM nashville_housing_data;

-- POPULATE PROPERTY ADDRESS DATA 

SELECT * FROM nashville_housing_data WHERE PropertyAddress = '';

SELECT A.ParcelID, B.ParcelID, 
       A.UniqueID, A.PropertyAddress, 
       B.UniqueID, B.PropertyAddress
FROM nashville_housing_data A 
JOIN nashville_housing_data B
ON A.ParcelID = B.ParcelID 
   AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL OR A.PropertyAddress = '';

SET SQL_SAFE_UPDATES = 0;

UPDATE nashville_housing_data AS A
JOIN nashville_housing_data B
ON A.ParcelID = B.ParcelID 
   AND A.UniqueID <> B.UniqueID
SET A.PropertyAddress = COALESCE(B.PropertyAddress, A.PropertyAddress)
WHERE A.PropertyAddress IS NULL OR A.PropertyAddress = '';

-- BREAKING THE OWNDERADDRESS INTO ADDRESS, CITY, STATE

SELECT OWNERADDRESS, substring_index(PropertyAddress,',', 1) AS SUB_STRING FROM nashville_housing_data;

SELECT OWNERADDRESS, substring_index(substring_index(PropertyAddress,',', 2), ',', -1) AS SUB_STRING FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
ADD PropertySplitAddress Nvarchar(255);

ALTER TABLE nashville_housing_data
ADD PropertySplitCity Nvarchar(255);

UPDATE nashville_housing_data
SET PropertySplitAddress = substring_index(PropertyAddress,',', 1);

UPDATE nashville_housing_data
SET PropertySplitCity = substring_index(substring_index(PropertyAddress,',', 2), ',', -1);

-- CHANGE Y AND N TO YES AND NO IN VACANT FIELD

SELECT DISTINCT SOLDASVACANT FROM nashville_housing_data;

SELECT SOLDASVACANT,
CASE 
	WHEN SOLDASVACANT = 'Y' THEN 'YES'
    WHEN SOLDASVACANT = 'N' THEN 'NO'
    ELSE 
    SoldAsVacant
END AS UPDATE_SOLDASVACANT
FROM nashville_housing_data;

SELECT DISTINCT UPDATE_SOLDASVACANT FROM (SELECT SOLDASVACANT,
CASE 
	WHEN SOLDASVACANT = 'Y' THEN 'YES'
    WHEN SOLDASVACANT = 'N' THEN 'NO'
    ELSE 
    SoldAsVacant
END AS UPDATE_SOLDASVACANT
FROM nashville_housing_data) AS TABLE_SOLDASVACANT;

UPDATE nashville_housing_data
SET SOLDASVACANT = CASE 
	WHEN SOLDASVACANT = 'Y' THEN 'YES'
    WHEN SOLDASVACANT = 'N' THEN 'NO'
    ELSE 
    SoldAsVacant
END;

-- REMOVE DUPLICATES

SELECT *,
	ROW_NUMBER() OVER(PARTITION BY PARCELID, PROPERTYADDRESS, SALEDATE, SALEPRICE, OWNERNAME, LEGALREFERENCE) ROW_NUM
    FROM nashville_housing_data;
    
SELECT * FROM (SELECT *,
	ROW_NUMBER() OVER(PARTITION BY PARCELID, PROPERTYADDRESS, SALEDATE, SALEPRICE, OWNERNAME, LEGALREFERENCE) ROW_NUM
    FROM nashville_housing_data) AS ROW_NUM_TABLE WHERE ROW_NUM > 1;
    
WITH CTE_ROW_NUM AS (SELECT UniqueID,
	ROW_NUMBER() OVER(PARTITION BY PARCELID, PROPERTYADDRESS, SALEDATE, SALEPRICE, OWNERNAME, LEGALREFERENCE ORDER BY UNIQUEID) AS ROW_NUM
    FROM nashville_housing_data)
DELETE FROM nashville_housing_data
WHERE UniqueID IN (SELECT UniqueID FROM CTE_ROW_NUM WHERE ROW_NUM > 1);

-- DELETE UNUSED COLUMNS 

SELECT OWNERADDRESS, TAXDISTRICT, SALEDATE, PROPERTYADDRESS FROM nashville_housing_data;

ALTER TABLE nashville_housing_data
DROP COLUMN OwnerAddress,
DROP COLUMN TAXDISTRICT, 
DROP COLUMN SALEDATE,
DROP COLUMN PROPERTYADDRESS;
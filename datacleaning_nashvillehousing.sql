-- Creating a PostgreSQL 16 table to showcase data cleaning skills using a Nashville housing dataset

CREATE TABLE nashville_housing (
    UniqueID INT,
    ParcelID VARCHAR(50),
    LandUse VARCHAR(50),
    PropertyAddress VARCHAR(255),
    SaleDate DATE,
    SalePrice INT,
    LegalReference VARCHAR(50),
    SoldAsVacant VARCHAR(10),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage DECIMAL(10, 2),
    TaxDistrict VARCHAR(50),
    LandValue DECIMAL(15, 2),
    BuildingValue DECIMAL(15, 2),
    TotalValue DECIMAL(15, 2),
    YearBuilt NUMERIC,
    Bedrooms NUMERIC,
    FullBath NUMERIC,
    HalfBath NUMERIC
);

-- Data overview for analysis purposes

SELECT * FROM nashville_housing;

-- Populate property address data

SELECT
    *
FROM nashville_housing
-- WHERE propertyaddress is null
ORDER by parcelID; -- Checking that any duplicate Parcel ID data has the same address associated

SELECT
    a.parcelID AS parcelID_a, a.propertyAddress AS propertyAddress_a,
    b.parcelID AS parcelID_b, b.propertyAddress AS propertyAddress_b,
    COALESCE(a.propertyaddress, b.propertyaddress) AS merged_propertyaddress
FROM nashville_housing a
JOIN nashville_housing b
    ON a.parcelID = b.parcelID
    AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

UPDATE nashville_housing AS a
SET propertyaddress = b.propertyaddress
FROM nashville_housing AS b
WHERE a.propertyaddress IS NULL
    AND a.parcelID = b.parcelID
    AND a.uniqueid <> b.uniqueid;

-- Breaking out address into individual columns (address, city, state)

SELECT
    propertyaddress
FROM nashville_housing;

SELECT
    SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress) - 1) as Address1,
    SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress) + 1) as Address2
FROM nashville_housing;

-- Add new columns from address and city with unique names

ALTER TABLE nashville_housing
ADD COLUMN PropertySplitAddressNew VARCHAR(255),
ADD COLUMN PropertySplitCityNew VARCHAR(255);

-- Update the new columns with split values

UPDATE nashville_housing
SET PropertySplitAddressNew = SPLIT_PART(propertyaddress, ',', 1),
    PropertySplitCityNew = SPLIT_PART(propertyaddress, ',', 2)::VARCHAR(255);

-- Drop the two columns showing null values

ALTER TABLE nashville_housing
DROP COLUMN propertysplitaddress,
DROP COLUMN propertysplitcity;

-- Verify the changes

SELECT * FROM nashville_housing;

SELECT
    owneraddress
FROM nashville_housing;

SELECT 
    SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 3) AS Address,
    SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 2) AS City,
    SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 1) AS State
FROM nashville_housing;

-- Add new columns for Address, City, and State

ALTER TABLE nashville_housing
ADD COLUMN Address VARCHAR(255),
ADD COLUMN City VARCHAR(255),
ADD COLUMN State VARCHAR(255);

-- Populate the new columns with split values

UPDATE nashville_housing
SET Address = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 1),
    City = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 2),
    State = SPLIT_PART(REPLACE(owneraddress, ',', '.'), '.', 3);

SELECT
    *
FROM
    nashville_housing;

-- Change Y and N to Yes and No in the "Sold as Vacant" field

UPDATE nashville_housing
SET soldasvacant = 
    CASE 
        WHEN (soldasvacant) = 'Y' THEN 'Yes'
        WHEN (soldasvacant) = 'N' THEN 'No'
        ELSE soldasvacant
    END;

SELECT
    *
FROM
    nashville_housing;

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
            ORDER BY
                UniqueID
        ) row_num
    FROM
        nashville_housing
)

DELETE FROM nashville_housing
WHERE ParcelID IN (
    SELECT ParcelID
    FROM (
        SELECT
            ParcelID,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                ORDER BY UniqueID
            ) AS row_num
        FROM nashville_housing
    ) AS RowNumCTE
    WHERE row_num > 1
);

WITH RowNumCTE2 AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM
        nashville_housing
)

SELECT
    *
FROM
    RowNumCTE2
WHERE
    row_num > 1
ORDER BY
    propertyaddress;
	
SELECT * FROM nashville_housing;
	
-- Delete any columns no longer needed

ALTER TABLE nashville_housing
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict;

SELECT * FROM nashville_housing;

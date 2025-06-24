# Analysis-of-Health-Facilities-in-Sub-Saharan-Africa

SELECT *
FROM sub_saharan_health_facilities;


-- Number of columns

SELECT COUNT(*) AS Column_count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sub_saharan_health_facilities';


-- Number of rows

SELECT COUNT(*) AS Row_count
FROM sub_saharan_health_facilities;


-- Columns & Data-Types

SELECT Column_name,
data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sub_saharan_health_facilities';


-- Checking for Null Values

SELECT 
    SUM(CASE WHEN Country ='' THEN 1 ELSE 0 END) AS null_Country,
		SUM(CASE WHEN Admin1 ='' THEN 1 ELSE 0 END) AS null_Admin1,
			SUM(CASE WHEN Facility_n ='' THEN 1 ELSE 0 END) AS null_Facility_Name,
				SUM(CASE WHEN Facility_t ='' THEN 1 ELSE 0 END) AS null_Facility_Type,
				SUM(CASE WHEN Ownership ='' THEN 1 ELSE 0 END) AS null_Ownership,
			SUM(CASE WHEN Lat ='' THEN 1 ELSE 0 END) AS null_Lat,
		SUM(CASE WHEN `Long` ='' THEN 1 ELSE 0 END) AS null_Long,
    SUM(CASE WHEN LL_source ='' THEN 1 ELSE 0 END) AS null_LLSource
FROM sub_saharan_health_facilities;


-- Duplicate Rows Count

WITH Duplicates AS
      (SELECT *,
      ROW_NUMBER() OVER(PARTITION BY Country, Admin1, Facility_n, LL_source, Facility_t, Ownership, Lat, 'Long') AS row_num
      FROM sub_saharan_health_facilities)
SELECT COUNT(*) AS Num_of_Duplicate_Rows
FROM Duplicates
WHERE row_num > 1;


# Data Cleaning

-- Table Duplication

CREATE TABLE `sub_saharan_health_facilities_ANA` (
  `Country` text,
  `Admin1` text,
  `Facility_name` text,
  `Facility_type` text,
  `Ownership` text,
  `Lat` int DEFAULT NULL,
  `Long` int DEFAULT NULL,
  `LL_source` text,
  row_num int) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    
-- Data popolating

INSERT INTO sub_saharan_health_facilities_ANA
SELECT *,
ROW_NUMBER() OVER(PARTITION BY Country, Admin1, Facility_n, LL_source, Facility_t, Ownership, Lat, 'Long') AS row_num
FROM sub_saharan_health_facilities;


-- 1 Removal oF Duplicates

DELETE
FROM sub_saharan_health_facilities_ANA
WHERE row_num > 1;


-- Number of rows after duplicates removal

SELECT COUNT(*) AS Row_count
FROM sub_saharan_health_facilities_ANA;


-- 2 Removal of Irrelevant Columns

ALTER TABLE sub_saharan_health_facilities_ANA
DROP COLUMN `Long`,
DROP COLUMN Lat, 
DROP COLUMN row_num;


-- Columns available after dropping irrelevant columns

SELECT Column_name,
data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sub_saharan_health_facilities_ANA';


-- 3 Addressing Blank Values or Null Values

UPDATE sub_saharan_health_facilities_ANA
SET Ownership = 'NULL'
WHERE Ownership = '';


-- 4 Standardizing data

UPDATE sub_saharan_health_facilities_ANA
SET Country = TRIM(Country);

UPDATE sub_saharan_health_facilities_ANA
SET Country = CONCAT(UPPER(SUBSTRING(Country, 1, 1)), LOWER(SUBSTRING(Country, 2)));

----------------------------------------
UPDATE sub_saharan_health_facilities_ANA
SET Admin1 = TRIM(Admin1);

UPDATE sub_saharan_health_facilities_ANA
SET Admin1 = CONCAT(UPPER(SUBSTRING(Admin1, 1, 1)), LOWER(SUBSTRING(Admin1, 2)));

-------------------------------------------
UPDATE sub_saharan_health_facilities_ANA
SET Facility_name = TRIM(Facility_name);

UPDATE sub_saharan_health_facilities_ANA
SET Facility_name = CONCAT(UPPER(SUBSTRING(Facility_name, 1, 1)), LOWER(SUBSTRING(Facility_name, 2)));

UPDATE sub_saharan_health_facilities_ANA
SET Facility_name = TRIM(BOTH '?' FROM Facility_name);

-----------------------------------------
UPDATE sub_saharan_health_facilities_ANA
SET Facility_type = TRIM(Facility_type);

UPDATE sub_saharan_health_facilities_ANA
SET Facility_type = CONCAT(UPPER(SUBSTRING(Facility_type, 1, 1)), LOWER(SUBSTRING(Facility_type, 2)));

UPDATE sub_saharan_health_facilities_ANA
SET Facility_type = TRIM(BOTH '?' FROM Facility_type);

UPDATE sub_saharan_health_facilities_ANA
SET Facility_type = TRIM(BOTH '"' FROM Facility_type);

--------------------------------------
UPDATE sub_saharan_health_facilities_ANA
SET Ownership = 'Public'
WHERE Ownership LIKE 'Pub%';

UPDATE sub_saharan_health_facilities_ANA
SET Ownership = TRIM(Ownership);


# Univariate Analysis
-- Highligh Unique Country Count

SELECT 
	COUNT(DISTINCT(Country)) AS Country_Count
FROM sub_saharan_health_facilities_ANA;


-- Highligh Unique Countries

SELECT 
	DISTINCT(Country) AS Unique_Countries
FROM sub_saharan_health_facilities_ANA;


-- Number of facilities by country

SELECT Country,
	COUNT(Facility_type) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
GROUP BY Country
ORDER BY Facility_Count DESC;


-- Highlight Unique Administrative divisions(States)

SELECT 
	 DISTINCT(Admin1) AS Admin_Division_or_State
FROM sub_saharan_health_facilities_ANA
ORDER BY Admin1;


-- Count of Unique Administrative divisions (State)

SELECT 
	COUNT(DISTINCT(Admin1)) AS Admin_Division_or_States
FROM sub_saharan_health_facilities_ANA;


-- Count of Unique Facilities

SELECT 
	COUNT(DISTINCT(Facility_name)) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
ORDER BY Facility_Name;


--  Highlight Facility type

SELECT DISTINCT(Facility_type) AS Facility_Type
FROM sub_saharan_health_facilities_ANA;


-- Count Unique Facility type

SELECT COUNT(DISTINCT(Facility_type)) AS Facility_Type_Count
FROM sub_saharan_health_facilities_ANA;


-- Highlight Unique Ownership Types

SELECT DISTINCT(Ownership)
FROM sub_saharan_health_facilities_ANA
ORDER BY Ownership;

-- Count Unique Ownership Types

SELECT count( DISTINCT(Ownership)) AS Count_of_Ownership
FROM sub_saharan_health_facilities_ANA
ORDER BY Ownership;


-- Transform & Highlight the Unique Ownership Types

SELECT DISTINCT
(CASE 
	WHEN Ownership LIKE 'MoH%' THEN 'Ministry of Health & Partners' 
		WHEN Ownership LIKE 'Priv%' THEN 'Private'
            WHEN Ownership LIKE 'Publi%' THEN 'Public'
				WHEN Ownership LIKE 'ONG%' THEN 'Non Governmental Organization'
					WHEN Ownership = 'Govt.' THEN 'Government'
					WHEN Ownership = 'CBO' THEN 'Community Based Organization'
				WHEN Ownership = 'FBO' THEN 'Faith Based Organization'
            WHEN Ownership = 'FBO/NGO' OR Ownership = 'NGO/FBO' THEN 'Faith Based Organization/Community Based Organization'
		WHEN Ownership = 'NGO' THEN 'Non Governmental Organization'
	ELSE Ownership
END) AS Ownership
FROM sub_saharan_health_facilities_ANA;


-- Count Unique Ownership types

SELECT COUNT(DISTINCT
(CASE 
	WHEN Ownership LIKE 'MoH%' THEN 'Ministry of Health & Partners' 
		WHEN Ownership LIKE 'Priv%' THEN 'Private'
            WHEN Ownership LIKE 'Publi%' THEN 'Public'
				WHEN Ownership LIKE 'ONG%' THEN 'Non Governmental Organization'
					WHEN Ownership = 'Govt.' THEN 'Government'
					WHEN Ownership = 'CBO' THEN 'Community Based Organization'
				WHEN Ownership = 'FBO' THEN 'Faith Based Organization'
            WHEN Ownership = 'FBO/NGO' OR Ownership = 'NGO/FBO' THEN 'Faith Based Organization/Community Based Organization'
		WHEN Ownership = 'NGO' THEN 'Non Governmental Organization'
	ELSE Ownership
END)) AS Ownership_Count
FROM sub_saharan_health_facilities_ANA;


-- Number of facilities by Ownership type

WITH Facility_Count AS
  (SELECT
    CASE 
    	WHEN Ownership LIKE 'MoH%' THEN 'Ministry of Health & Partners' 
			WHEN Ownership LIKE 'Priv%' THEN 'Private'
                WHEN Ownership LIKE 'Publi%' THEN 'Public'
					WHEN Ownership LIKE 'ONG%' THEN 'Non Governmental Organization'
						WHEN Ownership = 'Govt.' THEN 'Government'
						WHEN Ownership = 'CBO' THEN 'Community Based Organization'
					WHEN Ownership = 'FBO' THEN 'Faith Based Organization'
                WHEN Ownership = 'FBO/NGO' OR Ownership = 'NGO/FBO' THEN 'Faith Based Organization/Community Based Organization'
			WHEN Ownership = 'NGO' THEN 'Non Governmental Organization'
    	ELSE Ownership
    END AS ownership,
  Facility_name
  FROM sub_saharan_health_facilities_ANA)

SELECT ownership, COUNT(Facility_name) AS Facility_Count
FROM Facility_Count
GROUP BY ownership
ORDER BY Facility_Count DESC;


-- Number of health facilities in Nigeria

SELECT Country, COUNT(Facility_name) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria'
GROUP BY Country;


-- Number of health facilities in each state in Nigeria

SELECT Admin1, COUNT(Facility_name) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria'
GROUP BY Admin1;


-- Top 5 states

SELECT Admin1, COUNT(Facility_name) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria'
GROUP BY Admin1
ORDER BY Facility_Count DESC
LIMIT 5;


-- Bottom 5 states

SELECT Admin1, COUNT(Facility_name) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria'
GROUP BY Admin1
ORDER BY Facility_Count ASC
LIMIT 5;


-- Number of facilities by Ownership in Nigeria

SELECT
  CASE 
  	WHEN Ownership LIKE 'MoH%' THEN 'Ministry of Health & Partners' 
		WHEN Ownership LIKE 'Priv%' THEN 'Private'
			WHEN Ownership LIKE 'Publi%' THEN 'Public'
              WHEN Ownership LIKE 'ONG%' THEN 'Non Governmental Organization'
				WHEN Ownership = 'Govt.' THEN 'Government'
              WHEN Ownership = 'CBO' THEN 'Community Based Organization'
              WHEN Ownership = 'FBO' THEN 'Faith Based Organization'
			WHEN Ownership = 'FBO/NGO' OR Ownership = 'NGO/FBO' THEN 'Faith Based Organization/Community Based Organization'
		WHEN Ownership = 'NGO' THEN 'Non Governmental Organization'
  	ELSE Ownership
END AS ownership,
COUNT(Facility_name) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria'
GROUP BY ownership;


-- Highlight Unique Facility types in Nigeria

SELECT  DISTINCT(Facility_type)
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria';


-- Number of facilities by Facility type in Nigeria

SELECT  Facility_type, COUNT(Facility_t) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria'
GROUP BY Facility_type;


-- Group Facility type based on healthcare tier and return number of facilities by healthcare tier

With Healthcare_Tier AS
  (SELECT 
    	CASE WHEN Facility_type = 'Natonal Hospital' THEN 'Tertairy'
				 WHEN Facility_type LIKE '%Health Centre%' THEN 'Primary'
					 WHEN Facility_type LIKE '%Clinic%' THEN 'Primary'
						 WHEN Facility_type = 'Cottage Hospital' THEN 'Primary'
							 WHEN Facility_type = 'Dispensary' THEN 'Primary'
								 WHEN Facility_type = 'District Hospital' THEN 'Secondary'
								 WHEN Facility_type LIKE '%Medical Centre%' THEN 'Secondary'
								 WHEN Facility_type = 'Federal Medical Centre' THEN 'Secondary'
							 WHEN Facility_type = 'General Hospital' THEN 'Secondary'
						 WHEN Facility_type = 'Health Post' THEN 'Primary'
					 WHEN Facility_type = 'Hospital' THEN 'Secondary'
				 WHEN Facility_type = 'Rural Hospital' THEN 'Primary'
    		 WHEN Facility_type = 'University Teaching Hospital' THEN 'Tertairy'
    		ELSE 'Others'
        END AS Healthcare_tier
  FROM sub_saharan_health_facilities_ANA
  WHERE Country = 'Nigeria')

SELECT Healthcare_tier, COUNT(Healthcare_tier) AS Healthcare_tier_Count
FROM Healthcare_Tier
GROUP BY Healthcare_tier;


# Bivariate Analysis

WITH healthdata AS
(SELECT 
    CASE 
      WHEN Facility_type = 'National Hospital' THEN 'Tertiary' 
        WHEN Facility_type LIKE '%Health Centre%' THEN 'Primary' 
          WHEN Facility_type LIKE '%Clinic%' THEN 'Primary' 
            WHEN Facility_type = 'Cottage Hospital' THEN 'Primary' 
              WHEN Facility_type = 'Dispensary' THEN 'Primary' 
                WHEN Facility_type = 'District Hospital' THEN 'Secondary' 
                WHEN Facility_type LIKE '%Medical Centre%' THEN 'Secondary' 
                WHEN Facility_type = 'Federal Medical Centre' THEN 'Secondary' 
              WHEN Facility_type = 'General Hospital' THEN 'Secondary' 
            WHEN Facility_type = 'Health Post' THEN 'Primary' 
          WHEN Facility_type = 'Hospital' THEN 'Secondary' 
        WHEN Facility_type = 'Rural Hospital' THEN 'Primary' 
      WHEN Facility_type = 'University Teaching Hospital' THEN 'Tertiary' 
    END AS HealthCare_tier,
    CASE 
        WHEN Ownership LIKE 'MoH%' THEN 'Ministry of Health & Partners' 
          WHEN Ownership LIKE 'Priv%' THEN 'Private' 
            WHEN Ownership LIKE 'Publi%' THEN 'Public' 
              WHEN Ownership LIKE 'ONG%' THEN 'Non-Governmental Organization' 
                WHEN Ownership = 'Govt.' THEN 'Government' 
                WHEN Ownership = 'CBO' THEN 'Community Based Organization' 
            WHEN Ownership = 'FBO' THEN 'Faith-Based Organization' 
          WHEN Ownership = 'FBO/NGO' THEN 'Faith-Based Organization/Community Based Organization' 
        WHEN Ownership = 'NGO' THEN 'Non-Governmental Organization' 
        ELSE Ownership 
    END AS ownership
  FROM sub_saharan_health_facilities_ANA 
  WHERE Country = 'Nigeria')

SELECT 
  ownership,
    SUM(CASE WHEN HealthCare_tier = 'Primary' THEN 1 ELSE 0 END) AS `Primary`,
      SUM(CASE WHEN HealthCare_tier = 'Secondary' THEN 1 ELSE 0 END) AS `Secondary`,
    SUM(CASE WHEN HealthCare_tier = 'Tertiary' THEN 1 ELSE 0 END) AS `Tertiary`
FROM healthdata
GROUP BY ownership;



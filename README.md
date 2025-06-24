# Analysis-of-Health-Facilities-in-Sub-Saharan-Africa
Building on my analysis of health facilities in sub-Saharan Africa, where I explored country-level and state-level distribution, facility ownership, and facility types, I aim to further drill down and provide in-depth insights specifically for Nigeria, shedding light on the nuances of healthcare infrastructure within the country.

## Table of Contents
1.  [Project Overview](#project-overview)

2.  [Tools and Methodology](#tools-and-methodology)

3.  [Data Profiling](#data-profiling)

4.  [Data Cleaning](#data-cleaning)

5.  [Univariate Analysis](#univariate-analysis)

6.  [Bivariate Analysis](#bivariate-analysis)



## Project Overview
This analysis utilizes a [dataset](https://data.humdata.org/dataset/health-facilities-in-sub-saharan-africa) compiled by Maina, J., Ouma, P.O., Macharia, P.M., et al., as part of their research titled [A spatial database of health facilities managed by the public health sector in sub-Saharan Africa, published in 2019.](https://www.researchgate.net/publication/334289719_A_spatial_database_of_health_facilities_managed_by_the_public_health_sector_in_sub_Saharan_Africa)

The goal is to explore the distribution of health facilities at country and state levels, examining facility types and ownership structures. The analysis will also focus specifically on Nigeria, investigating state-level distribution, ownership, facility types, and healthcare service tiers within the country.

## Tools and Methodology
1. SQL (querying and analyzing data)
2. Data Exploration (understanding the data)
3. Data Cleaning (preparing the data for analysis)
4. Aggregation (grouping and summarizing data)
5. CTE (Common Table Expressions, a powerful SQL feature)

## Data Profiling
This dataset comprises 98,745 rows and 8 columns, featuring 6 categorical variables (Country, Admin1, Facility name, Facility type, Ownership, and LL Source) stored as varchar, and 2 numerical variables (Lat and Long, representing latitude and longitude). Upon inspection, null values are present in several columns: Ownership (30,448 nulls), Lat (6,041 nulls), Long (3,095 nulls), and LL Source (2,350 nulls). Additionally, the dataset contains 1367 duplicate rows. After removing these duplicates, the dataset is refined to 97,378 unique rows.


#### Number of columns
```sql
SELECT COUNT(*) AS Column_count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sub_saharan_health_facilities';
```
| Column_count |
| --- |
| 8 |


#### Number of rows
```sql
SELECT COUNT(*) AS Row_count
FROM sub_saharan_health_facilities;
```
| Row count |
| --- |
| 98745 |


#### Columns & Data-Types
```
SELECT Column_name,
data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sub_saharan_health_facilities';
```
| Column Name | Data Type |
| --- | --- |
| Country | text |
| Admin1 | text |
| Facility_name | text |
| Facility_type | text |
| Ownership | text |
| Lat | int |
| Long | int |
| LL_source | text |

#### Checking for Null Values
``` sql
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
```
| null_Country | null_Admin1 | null_Facility_Name | null_Facility_Type | null_Ownership | null_Lat | null_Long | null_LLSource |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 30448 | 6041 | 3095 | 2350 |


#### Duplicate Rows Count
```sql
WITH Duplicates AS
      (SELECT *,
      ROW_NUMBER() OVER(PARTITION BY Country, Admin1, Facility_n, LL_source, Facility_t, Ownership, Lat, 'Long') AS row_num
      FROM sub_saharan_health_facilities)
SELECT COUNT(*) AS Num_of_Duplicate_Rows
FROM Duplicates
WHERE row_num > 1;
```
| Num_of_Duplicate_Rows |
| --- |
| 1367 |


## Data Cleaning
To make permanent changes to the dataset, I created a new table by duplicating the main table's data, and then applied data cleaning transformations, including  dropping duplicate rows, removing irrelevant columns, updating null values, and correcting irregularities to ensure a refined dataset for analysis.  I then added a new column called "row_num" to store the ROW_NUMBER() function, which helped identify duplicate rows by assigning a unique number to each row within a partition. This allowed me to easily remove duplicates by deleting rows with row_num greater than 1 (>1). 


#### Table Duplication
``` sql
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
```

Copying data from the main table to a new table in preparation for permanent changes.
```sql
INSERT INTO sub_saharan_health_facilities_ANA
SELECT *,
ROW_NUMBER() OVER(PARTITION BY Country, Admin1, Facility_n, LL_source, Facility_t, Ownership, Lat, 'Long') AS row_num
FROM sub_saharan_health_facilities;
```


#### Removal oF Duplicates
```sql
DELETE
FROM sub_saharan_health_facilities_ANA
WHERE row_num > 1;
```


*Number of rows after duplicates removal*
```sql
SELECT COUNT(*) AS Row_count
FROM sub_saharan_health_facilities_ANA;
```
| Row_count |
| --- |
| 97378 |


#### Removal of Irrelevant Columns
```sql
ALTER TABLE sub_saharan_health_facilities_ANA
DROP COLUMN `Long`,
DROP COLUMN Lat, 
DROP COLUMN row_num;
```


*Columns available after dropping irrelevant columns*
```
SELECT Column_name,
data_type
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sub_saharan_health_facilities_ANA';
```
| Column Name | Data Type |
| --- | --- |
| Country | text |
| Admin1 | text |
| Facility_name | text |
| Facility_type | text |
| Ownership | text |


#### Addressing Blank Values or Null Values 
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Ownership = 'NULL'
WHERE Ownership = '';
```


#### Standardizing data
This involves transforming and formatting data into a consistent and uniform structure, making it easier to work with, analyze, and compare. This process includes data formatting, normalization, cleansing, and transformation to improve data quality, reduce errors, and enable accurate analysis and insights. By standardizing data, inconsistencies are removed, and data becomes more reliable, allowing for better decision-making and more effective use of data-driven insights.

*Country Column*
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Country = TRIM(Country);
```
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Country = CONCAT(UPPER(SUBSTRING(Country, 1, 1)), LOWER(SUBSTRING(Country, 2)));
```


*Admin1 Column*
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Admin1 = TRIM(Admin1);
```
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Admin1 = CONCAT(UPPER(SUBSTRING(Admin1, 1, 1)), LOWER(SUBSTRING(Admin1, 2)));
```


*Facility Name Column*
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Facility_name = TRIM(Facility_name);
```
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Facility_name = CONCAT(UPPER(SUBSTRING(Facility_name, 1, 1)), LOWER(SUBSTRING(Facility_name, 2)));
```
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Facility_name = TRIM(BOTH '?' FROM Facility_name);
```


*Facility Type Column*
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Facility_type = TRIM(Facility_type);
```
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Facility_type = CONCAT(UPPER(SUBSTRING(Facility_type, 1, 1)), LOWER(SUBSTRING(Facility_type, 2)));
```
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Facility_type = TRIM(BOTH '?' FROM Facility_type);
```
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Facility_type = TRIM(BOTH '"' FROM Facility_type);
```


*Ownership Column*
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Ownership = 'Public'
WHERE Ownership LIKE 'Pub%';
```
```sql
UPDATE sub_saharan_health_facilities_ANA
SET Ownership = TRIM(Ownership);
```


## Univariate Analysis
The dataset contains data from 50 unique countries, 583 states, 93,474 facilities, 166 facility types, and 20 ownership types.

#### Highligh Unique Countries
```sql
SELECT 
	COUNT(DISTINCT(Country)) AS Country_Count
FROM sub_saharan_health_facilities_ANA;
```
| Country_Count |
| --- |
| 50 |


```sql
SELECT 
	DISTINCT(Country) AS Unique_Countries
FROM sub_saharan_health_facilities_ANA;
```
| Unique_Countriess |
| --- |
| Angola |
| Benin |
| Botswana |
| Burkina Faso |
| Burundi |
| Cameroon |
| Cape Verde |
| Central African Republic |
| Chad |
| Comoros |
| Congo |
| Cote d'Ivoire |
| Democratic Republic of the Congo |
| Djibouti |
| Equatorial Guinea |
| Eritrea |
| Eswatini |
| Ethiopia |
| Gabon |
| Gambia |
| Ghana |
| Guinea |
| Guinea-Bissau |
| Kenya |
| Lesotho |
| Liberia |
| Madagascar |
| Malawi |
| Mali |
| Mauritania |
| Mauritius |
| Mozambique |
| Namibia |
| Niger |
| Nigeria |
| Rwanda |
| Sao Tome and Principe |
| Senegal |
| Seychelles |
| Sierra Leone |
| Somalia |
| South Africa |
| South Sudan |
| Sudan |
| Tanzania |
| Togo |
| Uganda |
| Zambia |
| Zanzibar |
| Zimbabwe |


#### Number of facilities by country
Nigeria, the Democratic Republic of the Congo, and Tanzania have the highest number of healthcare facilities, while Equatorial Guinea, Seychelles, and Guinea-Bissau have the fewest.
```sql
SELECT Country,
	COUNT(Facility_type) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
GROUP BY Country
ORDER BY Facility_Count DESC;
```
| Country | Facility_Count |
| --- | --- |
| Nigeria | 20602 |
| Democratic Republic of the Congo | 13955 |
| Tanzania | 6272 |
| Kenya | 6135 |
| Ethiopia | 4946 |
| South Africa | 4303 |
| Uganda | 3783 |
| Cameroon | 3039 |
| Niger | 2876 |
| Madagascar | 2668 |
| Ghana | 1950 |
| Cote d'Ivoire | 1789 |
| South Sudan | 1727 |
| Burkina Faso | 1715 |
| Guinea | 1712 |
| Mozambique | 1573 |
| Angola | 1548 |
| Mali | 1474 |
| Senegal | 1343 |
| Chad | 1271 |
| Zambia | 1259 |
| Zimbabwe | 1235 |
| Sierra Leone | 1106 |
| Somalia | 879 |
| Benin | 819 |
| Liberia | 739 |
| Burundi | 660 |
| Malawi | 645 |
| Mauritania | 636 |
| Botswana | 623 |
| Rwanda | 572 |
| Central African Republic | 555 |
| Gabon | 540 |
| Namibia | 369 |
| Congo | 327 |
| Sudan | 272 |
| Eritrea | 268 |
| Togo | 207 |
| Mauritius | 166 |
| Zanzibar | 144 |
| Eswatini | 135 |
| Lesotho | 117 |
| Gambia | 103 |
| Djibouti | 66 |
| Cape Verde | 66 |
| Comoros | 66 |
| Sao Tome and Principe | 50 |
| Equatorial Guinea | 47 |
| Seychelles | 18 |
| Guinea-Bissau | 8 |



#### Highlight Unique Administrative divisions(States)
```sql
SELECT 
	 DISTINCT(Admin1) AS Admin_Division_or_State
FROM sub_saharan_health_facilities_ANA
ORDER BY Admin1;
```


#### Count of Unique Administrative divisions (State)
```sql
SELECT 
	COUNT(DISTINCT(Admin1)) AS Admin_Division_or_States
FROM sub_saharan_health_facilities_ANA;
```
| Admin_Division_or_States |
| --- |
| 583 |


#### Count of Unique Facilities
The number of unique facilities is lower than the total row count in the dataset because some facilities appear in multiple locations, such as satellite branches.

```sql
SELECT 
	COUNT(DISTINCT(Facility_name)) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
ORDER BY Facility_Name;
```
| Facility_Count |
| --- |
| 93474 |


#### Highlight Facility type
```sql
SELECT DISTINCT(Facility_type) AS Facility_Type
FROM sub_saharan_health_facilities_ANA;
```

#### Count Unique Facility type
```sql
SELECT COUNT(DISTINCT(Facility_type)) AS Facility_Type_Count
FROM sub_saharan_health_facilities_ANA;
````
| Facility_Type_Count |
| --- |
| 166 |


#### Highlight Unique Ownership Types
This returned 20 different ownership types, most of which required data cleaning and transformation to ensure uniformity.
```sql
SELECT DISTINCT(Ownership)
FROM sub_saharan_health_facilities_ANA
ORDER BY Ownership;
```

#### Count Unique Ownership Types
```sql
SELECT count( DISTINCT(Ownership)) AS Count_of_Ownership
FROM sub_saharan_health_facilities_ANA
ORDER BY Ownership;
```
| Count_of_Ownership |
| --- |
| 20 |

#### Transform & Highlight the Unique Ownership Types

```sql
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
```
| Ownership |
| --- |
| Government |
| Ministry of Health & Partners |
| Public |
| Faith Based Organization |
| NULL |
| Private |
| Community Based Organization |
| Confessionnel |
| Non Governmental Organization |
| Faith Based Organization/Community Based Organization |
| Local authority |
| Parastatal |


#### Count Unique Ownership types
```sql
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
```
| Ownership_Count |
| --- |
| 12 |



#### Number of facilities by Ownership type
The Ministry of Health & Partners owned the largest share of healthcare facilities.

```sql
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
```
| ownership | Facility_Count |
| --- | --- |
| Ministry of Health & Partners | 31321 |
| NULL | 30180 |
| Public | 23339 |
| Local authority | 6166 |
| Faith Based Organization | 2940 |
| Private | 962 |
| Non Governmental Organization | 853 |
| Government | 806 |
| Community Based Organization | 369 |
| Confessionnel | 348 |
| Faith Based Organization/Community Based Organization | 89 |
| Parastatal | 5 |



### Drilling down to Nigeria
The dataset reports 20,602 healthcare facilities in Nigeria
#### Number of health facilities in Nigeria
```sql
SELECT Country, COUNT(Facility_name) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria'
GROUP BY Country;
```
| Country | Facility_Count |
| --- | --- |
| Nigeria | 20602 |


#### Number of health facilities in each state in Nigeria
Katsina, Niger, Kano, Kaduna, and Adamawa recorded the highest volumes, while Gombe, Lagos, Bayelsa, Abia, and the FCT recorded the fewest.
```sql
ELECT Admin1, COUNT(Facility_name) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria'
GROUP BY Admin1;
```
| Admin1 | Facility_Count |
| --- | --- |
| Abia | 196 |
| Adamawa | 806 |
| Akwa Ibom | 381 |
| Anambra | 352 |
| Bauchi | 769 |
| Bayelsa | 205 |
| Benue | 747 |
| Borno | 395 |
| Cross River | 575 |
| Delta | 485 |
| Ebonyi | 371 |
| Edo | 346 |
| Ekiti | 312 |
| Enugu | 474 |
| Federal Capital Territory | 180 |
| Gombe | 315 |
| Imo | 386 |
| Jigawa | 598 |
| Kaduna | 923 |
| Kano | 1019 |
| Katsina | 1244 |
| Kebbi | 372 |
| Kogi | 780 |
| Kwara | 487 |
| Lagos | 247 |
| Nasarawa | 605 |
| Niger | 1225 |
| Ogun | 474 |
| Ondo | 452 |
| Osun | 671 |
| Oyo | 603 |
| Plateau | 720 |
| Rivers | 387 |
| Sokoto | 665 |
| Taraba | 735 |
| Yobe | 448 |
| Zamfara | 652 |


#### Top 5 states
```sql
SELECT Admin1, COUNT(Facility_name) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria'
GROUP BY Admin1
ORDER BY Facility_Count DESC
LIMIT 5;
```
| Admin1 | Facility_Count |
| --- | --- |
| Katsina | 1244 |
| Niger | 1225 |
| Kano | 1019 |
| Kaduna | 923 |
| Adamawa | 806 |

#### Bottom 5 states
```sql
SELECT Admin1, COUNT(Facility_name) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria'
GROUP BY Admin1
ORDER BY Facility_Count ASC
LIMIT 5;
```
| Admin1 | Facility_Count |
| --- | --- |
| Federal Capital Territory | 180 |
| Abia | 196 |
| Bayelsa | 205 |
| Lagos | 247 |
| Ekiti | 312 |


#### Number of facilities by Ownership in Nigeria
Ownership was unspecified for the majority of healthcare facilities in Nigeria; however, for those with specified ownership, Community Based Organizations took the lead.
```sql
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
```
| ownership | Facility_Count |
| --- | --- |
| NULL | 20422 |
| Community Based Organization | 126 |
| Ministry of Health & Partners | 39 |
| Faith Based Organization | 15 |


#### Highlight Unique Facility types in Nigeria
```sql
SELECT  DISTINCT(Facility_type)
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria';
```

| Facility_type |
| --- |
| Primary health centre |
| Health centre |
| Clinic |
| Health post |
| Model health centre |
| General hospital |
| Dispensary |
| Basic health centre |
| Comprehensive health centre |
| Federal medical centre |
| Cottage hospital |
| Polyclinic |
| Medical centre |
| Hospital |
| University teaching hospital |
| Model primary health centre |
| Rural hospital |
| District hospital |
| National hospital |
| State hospital |


#### Number of facilities by Facility type in Nigeria
```sql
SELECT  Facility_type, COUNT(Facility_t) AS Facility_Count
FROM sub_saharan_health_facilities_ANA
WHERE Country = 'Nigeria'
GROUP BY Facility_type;
```
| Facility_type | Facility_Count |
| --- | --- |
| Primary health centre | 4586 |
| Health centre | 3373 |
| Clinic | 4292 |
| Health post | 3038 |
| Model health centre | 107 |
| General hospital | 529 |
| Dispensary | 3210 |
| Basic health centre | 559 |
| Comprehensive health centre | 433 |
| Federal medical centre | 19 |
| Cottage hospital | 149 |
| Polyclinic | 10 |
| Medical centre | 19 |
| Hospital | 148 |
| University teaching hospital | 25 |
| Model primary health centre | 58 |
| Rural hospital | 19 |
| District hospital | 16 |
| National hospital | 1 |
| State hospital | 11 |


#### Group Facility type based on healthcare tier and return number of facilities by healthcare tier
Based on healthcare tier, the majority of health facilities are primary healthcare institutions.

```sql
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
```
| Healthcare_Tier | Healthcare_Tier_Count |
| --- | --- |
| Primary | 19834 |
| Secondary | 731 |
| Tertiary | 26 |
| Others | 11 |

## Bivariate Analysis
Number of facilities by ownership and healthcare tier
```sql
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
```

| ownership | Primary | Secondary | Tertiary |
| --- | --- | --- | --- |
| NULL | 19678 | 707 | 25 |
| Community Based Organization | 126 | 0 | 0 |
| Ministry of Health & Partners | 15 | 24 | 0 |
| Faith-Based Organization | 15 | 0 | 0 |

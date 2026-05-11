use world_layoffs;

--  Data Cleaning 

--  1. Viewing the dataset 

SELECT * 
FROM layoffs;

--  2. Data Cleaning process

-- 1.	Removing duplicates 
-- 2.	Standardizing the data 
-- 3.	Handling null and blank values 
-- 4.	Removing unnecessary rows and columns

-- 3. Creating a stagging table 

CREATE TABLE layoffs_staging
LIKE layoffs ;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT * 
FROM layoffs_staging;

-- 4. Removing Duplicates

-- find the duplicates  
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT * ,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte 
WHERE row_num > 1;

-- a query to get a quick check if we have got the exact duplicates 
SELECT * 
FROM layoffs_staging 
WHERE company = 'Casper';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country,
funds_raised_millions
) AS row_num
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging2
WHERE row_num>1 ;

-- Removing duplicates 

DELETE 
FROM layoffs_staging2
WHERE row_num>1 ;

SELECT * 
FROM layoffs_staging2 
WHERE row_num > 1 ;

-- 5. Standerdizing the data 

SELECT *
FROM layoffs_staging2;

-- removing extra spaces

SELECT company , trim(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT company 
FROM layoffs_staging2;

-- standardizing industry name 

SELECT DISTINCT(industry)
FROM layoffs_staging2 
ORDER BY industry ;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT(industry)
FROM layoffs_staging2 
ORDER BY industry ;

-- fixing country name 

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- fixing the datatype of date column

SELECT *
FROM layoffs_staging2;

-- we can use str to date to convert it to date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- now we can convert the data type properly
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 6. Look at Null Values

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- looking for null and blank in industry column 
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- matching rows having missing industry with rows having valid industries for the company adn loacation 
-- using self join 

SELECT t1.company, t1.location, t1.industry,
t2.company, t2.location, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- updating the blanks with nulls 
-- this will hep in replacing them with relevent industry values easily 
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;
 
 
-- checking if the feilds are successfully updated  
SELECT *
FROM layoffs_staging2
WHERE company IN ('Airbnb' , 'Carvana' , 'Juul');

-- looking for rows still with null values 
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';


-- looking for rows with completely null layoff info

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data that can't really be used
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- removing helper column no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;



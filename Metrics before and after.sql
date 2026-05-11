use world_layoffs;

SELECT COUNT(*) AS total_rows_before
FROM layoffs;

SELECT COUNT(*) AS total_rows_after
FROM layoffs_staging2;

WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry,
total_laid_off, percentage_laid_off,
date, stage, country, funds_raised_millions
) AS row_num
FROM layoffs
)

SELECT COUNT(*) AS duplicate_records_before
FROM duplicate_cte
WHERE row_num > 1;

WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry,
total_laid_off, percentage_laid_off,
date, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging2
)

SELECT COUNT(*) AS duplicate_records_after
FROM duplicate_cte
WHERE row_num > 1;

SELECT COUNT(*) AS blank_industry_before
FROM layoffs
WHERE industry IS NULL
OR industry = '';

SELECT COUNT(*) AS blank_industry_after
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT COUNT(*) AS invalid_country_before
FROM layoffs
WHERE country LIKE '%.';

SELECT COUNT(*) AS null_layoff_rows_before
FROM layoffs
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT COUNT(*) AS null_layoff_rows_after
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT COUNT(*) AS invalid_country_after
FROM layoffs_staging2
WHERE country LIKE '%.';
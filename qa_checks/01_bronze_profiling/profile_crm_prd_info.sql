/*
===============================================================================
QA & Data Profiling: Bronze to Silver - Product Info (crm_prd_info)
===============================================================================
Script Purpose:
    - Inspect raw product data and identify data quality issues.
    - Check primary key uniqueness, nulls, and formatting anomalies.
    - Validate product cost ranges and categorical distributions.
    - Identify date overlap or sequencing anomalies.
===============================================================================
*/

-- 1. Inspect raw schema and initial sample rows
SELECT
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt 
FROM bronze.crm_prd_info
LIMIT 100;

-- 2. Primary Key Integrity Checks (prd_id)
SELECT 
    prd_id,
    COUNT(*) AS record_count
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 
   OR prd_id IS NULL 
   OR TRIM(prd_id) = '' 
   OR prd_id ~ '\s{2,}';

-- 3. String Whitespace & Formatting Checks (prd_key & prd_nm)
SELECT
    prd_key
FROM bronze.crm_prd_info
WHERE prd_key != TRIM(prd_key) 
   OR prd_key ~ '\s{2,}';

-- Test key splitting logic (cat_id and prd_key separation)
SELECT
    prd_key,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS cleaned_prd_key
FROM bronze.crm_prd_info
LIMIT 10;

-- Check product name whitespace
SELECT
    prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- 4. Checking for Nulls and Negative Numbers in Cost
SELECT 
    prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL 
   OR CAST(NULLIF(TRIM(prd_cost), '') AS NUMERIC) < 0;

-- 5. Categorical Data Consistency (prd_line)
SELECT DISTINCT 
    prd_line 
FROM bronze.crm_prd_info;

-- 6. Date Sequence & Format Validation
-- Check for logically invalid date ranges (End Date before Start Date)
SELECT *
FROM bronze.crm_prd_info
WHERE CAST(prd_end_dt AS DATE) < CAST(prd_start_dt AS DATE);

-- Check for malformed date strings not matching YYYY-MM-DD
SELECT *
FROM bronze.crm_prd_info
WHERE prd_start_dt !~ '^\d{4}-\d{2}-\d{2}$' 
   OR prd_end_dt !~ '^\d{4}-\d{2}-\d{2}$';

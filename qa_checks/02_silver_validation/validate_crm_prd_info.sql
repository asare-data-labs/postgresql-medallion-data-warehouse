/*
====================================================================================
Data Validation Script: silver.crm_prd_info
====================================================================================
*/

-- 1. Primary Key Integrity (prd_id)
-- Expectation: 0 rows returned
SELECT prd_id, COUNT(*) AS record_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- 2. Foreign Key / Category Key Integrity (cat_id)
-- Expectation: 0 unexpected nulls or malformed IDs
SELECT *
FROM silver.crm_prd_info
WHERE cat_id IS NULL OR cat_id != TRIM(cat_id);

-- 3. String Whitespace & Formatting Checks
-- Expectation: 0 rows returned
SELECT *
FROM silver.crm_prd_info
WHERE prd_key != TRIM(prd_key)
   OR prd_nm != TRIM(prd_nm)
   OR prd_line != TRIM(prd_line);

-- 4. Numeric & Range Validation (prd_cost)
-- Expectation: 0 negative costs
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- 5. Categorical Value Distribution
SELECT DISTINCT prd_line FROM silver.crm_prd_info;

-- 6. Date Sequence & Validity
-- Expectation: Start date must be before or equal to end date
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt
   OR prd_start_dt IS NULL;

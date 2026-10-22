/*
====================================================================================
Data Validation Script: silver.erp_cust_az12
====================================================================================
*/

-- 1. Primary Key Integrity (cid)
-- Expectation: 0 rows returned
SELECT cid, COUNT(*) AS record_count
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- 2. Cleaned ID Format Check
-- Expectation: 0 rows returned (Ensures prefix stripping logic was successful)
SELECT *
FROM silver.erp_cust_az12
WHERE cid LIKE 'NAS%';

-- 3. Date of Birth & Age Sanity Checks
-- Expectation: DOB cannot be in the future or older than 120 years
SELECT *
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE
   OR bdate < (CURRENT_DATE - INTERVAL '120 years');

-- 4. Categorical Standardization Check (Gender / Marital Status)
SELECT DISTINCT gen FROM silver.erp_cust_az12;

/*
====================================================================================
Data Validation Script: silver.erp_loc_a101
====================================================================================
*/

-- 1. Primary Key Integrity (cid)
-- Expectation: 0 rows returned
SELECT cid, COUNT(*) AS record_count
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- 2. Cleaned ID String Check
-- Expectation: 0 rows with hyphens (verifies REPLACE('-', '') logic)
SELECT *
FROM silver.erp_loc_a101
WHERE cid LIKE '%-%';

-- 3. Country Field Standardization Check
-- Expectation: Only standardized, clean country names returned (no abbreviations or whitespace)
SELECT DISTINCT cntry FROM silver.erp_loc_a101;

SELECT *
FROM silver.erp_loc_a101
WHERE cntry != TRIM(cntry) OR cntry IS NULL OR cntry = '';

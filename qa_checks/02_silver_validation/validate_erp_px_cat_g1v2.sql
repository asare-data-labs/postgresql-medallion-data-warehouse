/*
====================================================================================
Data Validation Script: silver.erp_px_cat_g1v2
====================================================================================
*/

-- 1. Primary Key Integrity (id)
-- Expectation: 0 rows returned
SELECT id, COUNT(*) AS record_count
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL;

-- 2. String Formatting & Whitespace Checks
-- Expectation: 0 rows returned
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- 3. Domain / Categorical Distribution Audit
SELECT DISTINCT cat FROM silver.erp_px_cat_g1v2;
SELECT DISTINCT subcat FROM silver.erp_px_cat_g1v2;
SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2;

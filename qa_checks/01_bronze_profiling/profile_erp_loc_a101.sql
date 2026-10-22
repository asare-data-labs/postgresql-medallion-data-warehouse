/*
===============================================================================
QA & Data Profiling: Bronze to Silver - ERP Location Info (erp_loc_a101)
===============================================================================
Script Purpose:
    - Inspect raw ERP location schema and sample rows.
    - Validate customer ID (`cid`) whitespace and hyphen structures.
    - Check for orphan location records not matching the Silver customer table.
    - Audit country (`cntry`) value distribution and design standardization rules.
===============================================================================
*/

-- 1. Explore raw table sample
SELECT 
    cid,
    cntry
FROM bronze.erp_loc_a101
LIMIT 10;

-- 2. Customer ID Whitespace & Formatting Checks
SELECT 
    cid
FROM bronze.erp_loc_a101
WHERE cid IS NULL 
   OR cid != TRIM(cid) 
   OR TRIM(cid) = ''
   OR cid ~ '\s{2,}';

-- Test hyphen removal logic (aligning ERP format with CRM customer keys)
SELECT 
    cid,
    REPLACE(TRIM(cid), '-', '') AS clean_cid
FROM bronze.erp_loc_a101
LIMIT 10;

-- 3. Referential Integrity Check: Find orphan locations missing from Customer Master
SELECT DISTINCT
    cid
FROM bronze.erp_loc_a101
WHERE NULLIF(REPLACE(TRIM(cid), '-', ''), '') NOT IN (
    SELECT cst_key FROM silver.crm_cust_info
);

-- 4. Country Code Consistency & Distribution Audit
SELECT DISTINCT 
    cntry,
    COUNT(*) AS record_count
FROM bronze.erp_loc_a101
GROUP BY cntry;

-- 5. Test Country Standardization Mapping Logic
SELECT DISTINCT 
    cntry,
    CASE 
        WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
        WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS clean_cntry
FROM bronze.erp_loc_a101;

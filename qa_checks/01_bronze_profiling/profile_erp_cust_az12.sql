/*
===============================================================================
QA & Data Profiling: Bronze to Silver - ERP Customer Info (erp_cust_az12)
===============================================================================
Script Purpose:
    - Inspect raw ERP customer schema and sample rows.
    - Validate customer ID (`cid`) formatting, whitespace, and prefix patterns.
    - Check birthdate (`bdate`) format compliance and detect illogical future dates.
    - Audit distinct gender values for standardization mapping.
===============================================================================
*/

-- 1. Explore raw table sample
SELECT 
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
LIMIT 10;

-- 2. Customer ID Integrity & Whitespace Checks
SELECT 
    cid 
FROM bronze.erp_cust_az12
WHERE cid IS NULL 
   OR cid != TRIM(cid) 
   OR TRIM(cid) = ''
   OR cid ~ '\s{2,}';

-- Test prefix stripping logic (handling 'NAS' prefixes)
SELECT 
    cid,
    CASE 
        WHEN TRIM(cid) LIKE 'NAS%' THEN SUBSTRING(TRIM(cid), 4, LENGTH(TRIM(cid)))
        ELSE TRIM(cid)
    END AS cleaned_cid
FROM bronze.erp_cust_az12;

-- 3. Birthdate Format Checks
SELECT 
    bdate
FROM bronze.erp_cust_az12
WHERE bdate IS NULL 
   OR bdate != TRIM(bdate)
   OR TRIM(bdate) ~ '\s{2,}'
   OR TRIM(bdate) = ''
   OR TRIM(bdate) !~ '^\d{4}-\d{2}-\d{2}$';

-- 4. Logical Date Range Checks (Detecting impossible future birthdates)
SELECT 
    bdate
FROM bronze.erp_cust_az12
WHERE NULLIF(TRIM(bdate), '') ~ '^\d{4}-\d{2}-\d{2}$'
  AND CAST(NULLIF(TRIM(bdate), '') AS DATE) > CURRENT_DATE;

-- 5. Gender Value Distribution Audit
SELECT DISTINCT 
    gen,
    COUNT(*) AS record_count
FROM bronze.erp_cust_az12
GROUP BY gen;

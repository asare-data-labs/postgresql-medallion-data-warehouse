/*
===============================================================================
QA & Data Profiling: Bronze to Silver - ERP Product Category Info (erp_px_cat_g1v2)
===============================================================================
Script Purpose:
    - Inspect raw ERP product category schema and sample rows.
    - Validate category ID (`id`), category (`cat`), subcategory (`subcat`), 
      and maintenance flags for whitespace anomalies, empty strings, and nulls.
===============================================================================
*/

-- 1. Explore raw table sample
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2
LIMIT 10;

-- 2. Category ID Integrity & Whitespace Checks
SELECT
    id
FROM bronze.erp_px_cat_g1v2
WHERE id IS NULL
   OR id != TRIM(id)
   OR TRIM(id) = ''
   OR id ~ '\s{2,}';

-- 3. Category Whitespace & Formatting Checks
SELECT DISTINCT 
    cat
FROM bronze.erp_px_cat_g1v2
WHERE cat IS NULL
   OR cat != TRIM(cat)
   OR TRIM(cat) = ''
   OR cat ~ '\s{2,}';

-- 4. Subcategory Whitespace & Formatting Checks
SELECT DISTINCT 
    subcat
FROM bronze.erp_px_cat_g1v2
WHERE subcat IS NULL
   OR subcat != TRIM(subcat)
   OR TRIM(subcat) = ''
   OR subcat ~ '\s{2,}';

-- 5. Maintenance Flag Whitespace & Formatting Checks
SELECT DISTINCT 
    maintenance 
FROM bronze.erp_px_cat_g1v2
WHERE maintenance IS NULL
   OR maintenance != TRIM(maintenance)
   OR TRIM(maintenance) = ''
   OR maintenance ~ '\s{2,}';

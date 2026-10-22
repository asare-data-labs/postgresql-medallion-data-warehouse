/*
===============================================================================
QA & Data Profiling: Bronze to Silver - Sales Details (crm_sales_details)
===============================================================================
Script Purpose:
    - Inspect raw schema, orders, and initial sample records.
    - Validate primary order number formatting and whitespace anomalies.
    - Enforce Referential Integrity (RI) against Silver Product and Customer tables.
    - Validate date string lengths, valid ranges, and chronological logic.
    - Profile financial discrepancies between sales, quantity, and unit price.
===============================================================================
*/

-- 1. Inspect raw schema and initial sample rows
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
LIMIT 10;

-- 2. Order Number Integrity Checks
SELECT
    sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL 
   OR TRIM(sls_ord_num) = '' 
   OR TRIM(sls_ord_num) != sls_ord_num
   OR sls_ord_num ~ '\s{2,}';

-- 3. Product Key Integrity & Referential Integrity Checks
SELECT
    sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key IS NULL 
   OR TRIM(sls_prd_key) = '' 
   OR TRIM(sls_prd_key) != sls_prd_key
   OR sls_prd_key ~ '\s{2,}';

-- Orphan check against Silver Product table (RI Validation)
SELECT DISTINCT
    sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

-- 4. Customer ID Integrity & Referential Integrity Checks
SELECT
    sls_cust_id
FROM bronze.crm_sales_details
WHERE sls_cust_id IS NULL 
   OR TRIM(sls_cust_id) = ''
   OR TRIM(sls_cust_id) ~ '\s{2,}';

-- Orphan check against Silver Customer table (RI Validation)
SELECT DISTINCT
    sls_cust_id
FROM bronze.crm_sales_details
WHERE CAST(NULLIF(TRIM(sls_cust_id), '') AS INT) NOT IN (SELECT cst_id FROM silver.crm_cust_info);

-- 5. Date Format & Range Checks (YYYYMMDD layout checks)
SELECT 
    sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt = '0' 
   OR LENGTH(sls_order_dt) != 8
   OR sls_order_dt > '20500101'
   OR sls_order_dt < '19000101';

-- Logical date sequence validation (Order date must precede ship/due dates)
SELECT 
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- 6. Financial Reconciliation Check (Sales vs Quantity * Price)
SELECT DISTINCT
    sls_sales AS raw_sales,
    sls_quantity,
    sls_price AS raw_price
FROM bronze.crm_sales_details
WHERE CAST(NULLIF(TRIM(sls_sales), '') AS NUMERIC) != CAST(NULLIF(TRIM(sls_quantity), '') AS NUMERIC) * ABS(CAST(NULLIF(TRIM(sls_price), '') AS NUMERIC))
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL;

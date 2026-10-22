/*
====================================================================================
QA & Data Profiling Script: bronze.crm_cust_info
====================================================================================
Script Purpose:
    This script contains exploratory data quality checks used to profile the raw 
    CRM Customer Information table in the Bronze layer prior to Silver ingestion.
    
    Key checks performed:
    1. Table volume & sample inspection.
    2. Primary Key integrity (Uniqueness, Nullability, & Duplicate ranking).
    3. String formatting anomalies (Leading/Trailing spaces & internal whitespace).
    4. Categorical data standardization & distinct value distribution.
    5. Date field integrity, future dates, and malformed syntax detection.

Dependencies:
    - Target Table: bronze.crm_cust_info
====================================================================================
*/

-- =================================================================================
-- 1. Table Overview & Sample Data Inspection
-- =================================================================================
-- Purpose: Inspect raw schema and initial sample rows.

SELECT 
    * 
FROM bronze.crm_cust_info 
LIMIT 100;


-- =================================================================================
-- 2. Primary Key Integrity Checks (cst_id)
-- =================================================================================
-- Purpose: Ensure 'cst_id' is unique and contains no NULL or blank values.
-- Expectation: 0 rows returned.

SELECT 
    cst_id,
    COUNT(*) AS record_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL OR TRIM(cst_id) = '' OR cst_id ~ '\s{2,}';

-- Inspect duplicate instances and verify deduplication logic (Keep latest record)
SELECT 
    *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL AND TRIM(cst_id) != '' AND cst_id !~ '\s{2,}'
) AS ranked_records
WHERE flag_last = 1;


-- =================================================================================
-- 3. String Whitespace & Formatting Checks
-- =================================================================================
-- Purpose: Identify fields containing unwanted leading, trailing, or internal spaces.
-- Expectation: 0 rows returned for clean fields.

-- Check for leading/trailing spaces in names (Note: Inner spaces like "Van Der Berg" are preserved intentionally)
SELECT cst_firstname 
FROM bronze.crm_cust_info 
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname 
FROM bronze.crm_cust_info 
WHERE cst_lastname != TRIM(cst_lastname);

-- Check Customer Key for both outer edges and illegal internal spaces (e.g. "AW000  11001")
SELECT cst_key 
FROM bronze.crm_cust_info 
WHERE cst_key != TRIM(cst_key) OR cst_key ~ '\s{2,}';

-- Check Marital Status & Gender for trailing/leading spaces
SELECT cst_marital_status 
FROM bronze.crm_cust_info 
WHERE cst_marital_status != TRIM(cst_marital_status);

SELECT cst_gndr 
FROM bronze.crm_cust_info 
WHERE cst_gndr != TRIM(cst_gndr);


-- =================================================================================
-- 4. Categorical Data Consistency & Value Distribution
-- =================================================================================
-- Purpose: Audit distinct values in low-cardinality fields to design mapping rules.

-- Audit Gender Values
SELECT DISTINCT 
    cst_gndr AS raw_gender_value
FROM bronze.crm_cust_info;

-- Validate Gender Standardized Output Transformation
SELECT DISTINCT 
    cst_gndr AS raw_value,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS transformed_value
FROM bronze.crm_cust_info;

-- Audit Marital Status Values
SELECT DISTINCT 
    cst_marital_status AS raw_marital_status_value
FROM bronze.crm_cust_info;

-- Validate Marital Status Standardized Output Transformation
SELECT DISTINCT 
    cst_marital_status AS raw_value,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS transformed_value
FROM bronze.crm_cust_info;


-- =================================================================================
-- 5. Date Field Integrity & Validity
-- =================================================================================
-- Purpose: Verify date formats, check for nulls, malformed syntax, and future dates.

-- Check for missing or blank date strings
SELECT 
    cst_create_date 
FROM bronze.crm_cust_info 
WHERE cst_create_date IS NULL OR TRIM(cst_create_date) = '';

-- Check for malformed date syntax that doesn't match standard YYYY-MM-DD format
SELECT 
    cst_create_date 
FROM bronze.crm_cust_info 
WHERE cst_create_date IS NOT NULL 
    AND TRIM(cst_create_date) != ''
    AND cst_create_date !~ '^\d{4}-\d{2}-\d{2}$';

-- Check for unexpected future creation dates
SELECT 
    * 
FROM bronze.crm_cust_info 
WHERE cst_create_date ~ '^\d{4}-\d{2}-\d{2}$'
  AND CAST(TRIM(cst_create_date) AS DATE) > CURRENT_DATE;

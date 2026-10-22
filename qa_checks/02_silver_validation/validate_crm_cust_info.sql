/*
====================================================================================
Data Validation Script: silver.crm_cust_info
====================================================================================
*/

-- =================================================================================
-- 1. Table Overview & Sample Data Inspection
-- =================================================================================
-- Purpose: Inspect raw schema and initial sample rows.

SELECT 
    * 
FROM silver.crm_cust_info 
LIMIT 100;


-- =================================================================================
-- 2. Primary Key Integrity Checks (cst_id)
-- =================================================================================
-- Purpose: Ensure 'cst_id' is unique and contains no NULL or blank values.
-- Expectation: 0 rows returned.

-- 1. Check for duplicate cst_id values
SELECT 
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- 2. Check for NULL cst_id values
SELECT *
FROM silver.crm_cust_info
WHERE cst_id IS NULL;

-- Inspect duplicate instances and verify deduplication logic (Keep latest record)
SELECT 
    *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM silver.crm_cust_info
    WHERE cst_id IS NULL
) AS ranked_records
WHERE flag_last = 1;


-- =================================================================================
-- 3. String Whitespace & Formatting Checks
-- =================================================================================
-- Purpose: Identify fields containing unwanted leading, trailing, or internal spaces.
-- Expectation: 0 rows returned for clean fields.

-- Check for leading/trailing spaces in names (Note: Inner spaces like "Van Der Berg" are preserved intentionally)
SELECT cst_firstname 
FROM silver.crm_cust_info 
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname 
FROM silver.crm_cust_info 
WHERE cst_lastname != TRIM(cst_lastname);

-- Check Customer Key for both outer edges and illegal internal spaces (e.g. "AW000  11001")
SELECT cst_key 
FROM silver.crm_cust_info 
WHERE cst_key != TRIM(cst_key) OR cst_key ~ '\s{2,}';

-- Check Marital Status & Gender for trailing/leading spaces
SELECT cst_marital_status 
FROM silver.crm_cust_info 
WHERE cst_marital_status != TRIM(cst_marital_status);

SELECT cst_gndr 
FROM silver.crm_cust_info 
WHERE cst_gndr != TRIM(cst_gndr);


-- =================================================================================
-- 4. Categorical Data Consistency & Value Distribution
-- =================================================================================
-- Purpose: Audit distinct values in low-cardinality fields to design mapping rules.

-- Audit Gender Values
SELECT DISTINCT 
    cst_gndr AS raw_gender_value
FROM silver.crm_cust_info;


-- Audit Marital Status Values
SELECT DISTINCT 
    cst_marital_status AS raw_marital_status_value
FROM silver.crm_cust_info;


-- =================================================================================
-- 5. Date Field Integrity & Validity
-- =================================================================================
-- Purpose: Verify date formats, check for nulls, malformed syntax, and future dates.

-- Check for missing or blank date strings
SELECT 
    cst_create_date 
FROM silver.crm_cust_info 
WHERE cst_create_date IS NULL

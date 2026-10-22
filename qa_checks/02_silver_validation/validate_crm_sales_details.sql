/*
====================================================================================
Data Validation Script: silver.crm_sales_details
====================================================================================
*/

-- 1. Primary / Composite Key Integrity Check
-- Expectation: 0 duplicate sales transactions
SELECT sls_ord_num, sls_prd_key, sls_cust_id, COUNT(*) AS record_count
FROM silver.crm_sales_details
GROUP BY sls_ord_num, sls_prd_key, sls_cust_id
HAVING COUNT(*) > 1;

-- 2. Foreign Key Integrity Checks
-- Expectation: 0 rows returned
SELECT *
FROM silver.crm_sales_details
WHERE sls_cust_id IS NULL 
   OR sls_prd_key IS NULL;

-- 3. String Whitespace Checks
-- Expectation: 0 rows returned
SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)
   OR sls_prd_key != TRIM(sls_prd_key);

-- 4. Financial & Quantity Logic Validation
-- Expectation: Sales, Quantity, and Price must be positive and follow Sales = Quantity * Price
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
   OR sls_sales != (sls_quantity * sls_price);

-- 5. Date Logic Validation
-- Expectation: Order Date <= Ship Date AND Order Date <= Due Date
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;
   
-- 6. Missing Order Date Audit
-- Purpose: Track records where order date is missing but fulfillment/shipping records exist.
-- Note: Retained in Silver to prevent inventory and revenue loss downstream.
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL;

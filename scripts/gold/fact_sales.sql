/*
====================================================================================
DDL Script: Gold Layer Fact Table - Sales (`gold.fact_sales`)
====================================================================================
Script Purpose:
    - Creates the `fact_sales` fact view by integrating data from 
      `silver.crm_sales_details`, `gold.dim_products`, and `gold.dim_customers`.
    - Connects facts to dimensions using surrogate keys (`product_key`, `customer_key`).
    - Preserves transaction integrity and financial reporting accuracy.
====================================================================================
*/

-- Drop existing view if it exists for clean re-creation
DROP VIEW IF EXISTS gold.fact_sales;

-- Create the Gold Fact Sales View
CREATE VIEW gold.fact_sales AS 
SELECT
    sd.sls_ord_num AS order_number,
    dp.product_key,
    dc.customer_key, 
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price 
FROM silver.crm_sales_details sd 
LEFT JOIN gold.dim_products dp
    ON sd.sls_prd_key = dp.product_number 
LEFT JOIN gold.dim_customers dc 
    ON sd.sls_cust_id = dc.customer_id;


-- =================================================================================
-- Gold Layer Validation Queries (fact_sales)
-- =================================================================================

-- 1. Row Count & Sample Data Inspection
SELECT COUNT(*) AS total_sales FROM gold.fact_sales;
SELECT * FROM gold.fact_sales LIMIT 50;

-- 2. Orphan Foreign Key Checks (Expectation: 0 rows or investigated low counts)
-- Check for sales referencing non-existent or filtered-out products
SELECT COUNT(*) AS orphaned_products
FROM gold.fact_sales
WHERE product_key IS NULL;

-- Check for sales referencing non-existent customers
SELECT COUNT(*) AS orphaned_customers
FROM gold.fact_sales
WHERE customer_key IS NULL;

-- 3. Financial & Quantity Metric Sanity Checks (Expectation: 0 invalid rows)
SELECT COUNT(*) AS invalid_financials
FROM gold.fact_sales
WHERE sales_amount < 0 
   OR quantity < 0 
   OR price < 0;

-- 4. Date Logic Validation at Gold Layer (Order Date vs Ship/Due Date)
SELECT COUNT(*) AS invalid_date_sequences
FROM gold.fact_sales
WHERE order_date > shipping_date 
   OR order_date > due_date;

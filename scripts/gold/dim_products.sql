/*
====================================================================================
DDL Script: Gold Layer Dimension - Product (`gold.dim_products`)
====================================================================================
Script Purpose:
    - Creates the `dim_products` dimension view by integrating data from 
      `silver.crm_prd_info` and `silver.erp_px_cat_g1v2`.
    - Filters out historical/expired products (keeping only current records where `prd_end_dt IS NULL`).
    - Assigns stable surrogate keys and applies business-friendly naming conventions.
====================================================================================
*/

-- Drop existing view if it exists for clean re-creation
DROP VIEW IF EXISTS gold.dim_products;

-- Create the Gold Product Dimension View
CREATE VIEW gold.dim_products AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY pi.prd_id) AS product_key,
    pi.prd_id AS product_id,
    pi.prd_key AS product_number,
    pi.prd_nm AS product_name,
    pi.cat_id AS category_id,
    COALESCE(pc.cat, 'n/a') AS category,
    COALESCE(pc.subcat, 'n/a') AS subcategory,
    COALESCE(pc.maintenance, 'n/a') AS maintenance,
    pi.prd_cost AS cost,
    pi.prd_line AS product_line,
    pi.prd_start_dt AS start_date
FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 pc 
    ON pi.cat_id = pc.id
WHERE pi.prd_end_dt IS NULL; -- Filter out historical/expired product data


-- =================================================================================
-- Gold Layer Validation Queries (dim_products)
-- =================================================================================

-- 1. Row Count & Sample Data Inspection
SELECT COUNT(*) AS total_products FROM gold.dim_products;
SELECT * FROM gold.dim_products LIMIT 50;

-- 2. Primary Key / Surrogate Key Uniqueness Check (Expectation: 0 duplicates)
SELECT 
    product_key, 
    COUNT(*) AS record_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- 3. Domain Distribution Audit for Categorical Fields
SELECT DISTINCT category, COUNT(*) AS category_count
FROM gold.dim_products
GROUP BY category;

SELECT DISTINCT subcategory, COUNT(*) AS subcategory_count
FROM gold.dim_products
GROUP BY subcategory;

SELECT DISTINCT maintenance, COUNT(*) AS maintenance_count
FROM gold.dim_products
GROUP BY maintenance;

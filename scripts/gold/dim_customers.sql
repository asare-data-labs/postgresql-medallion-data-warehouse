/*
====================================================================================
DDL Script: Gold Layer Dimension - Customer (`gold.dim_customers`)
====================================================================================
Script Purpose:
    - Creates the `dim_customers` dimension view by integrating data from 
      `silver.crm_cust_info`, `silver.erp_cust_az12`, and `silver.erp_loc_a101`.
    - Establishes CRM as the master source for customer data with ERP fallbacks.
    - Assigns surrogate keys and applies business-friendly naming conventions.
====================================================================================
*/

-- Drop existing view if it exists for clean re-creation
DROP VIEW IF EXISTS gold.dim_customers;

-- Create the Gold Dimension View
CREATE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    -- Data Integration: CRM is master for gender, fallback to ERP demographic data
    CASE 
        WHEN ci.cst_gndr IS NOT NULL AND ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci 
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la 
    ON ci.cst_key = la.cid;


-- =================================================================================
-- Gold Layer Validation Queries (dim_customers)
-- =================================================================================

-- 1. Row Count & Sample Data Inspection
SELECT COUNT(*) AS total_customers FROM gold.dim_customers;
SELECT * FROM gold.dim_customers LIMIT 50;

-- 2. Primary Key / Surrogate Key Uniqueness Check (Expectation: 0 duplicates)
SELECT 
    customer_key, 
    COUNT(*) AS record_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- 3. Domain Distribution Audit for Integrated Fields
SELECT DISTINCT gender, COUNT(*) AS customer_count
FROM gold.dim_customers
GROUP BY gender;

SELECT DISTINCT country, COUNT(*) AS customer_count
FROM gold.dim_customers
GROUP BY country;

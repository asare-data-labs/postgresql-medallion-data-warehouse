/*
====================================================================================
DDL Script: Create Silver Layer Tables
====================================================================================
Script Purpose:
    This script creates the conformed and cleansed silver layer tables for CRM 
    and ERP datasets. It enforces proper data types (INT, DATE, NUMERIC) and 
    standardized audit metadata (`dwh_create_timestamp`).

Dependencies:
    - Requires the 'silver' schema to exist.
====================================================================================
*/

-- -----------------------------------------------------------------------------
-- 1. Customer Information (CRM)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.crm_cust_info CASCADE;
CREATE TABLE silver.crm_cust_info (
    cst_id             INT,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr           VARCHAR(50),
    cst_create_date    DATE,

    -- DWH Audit Metadata
    dwh_create_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 2. Product Information (CRM)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.crm_prd_info CASCADE;
CREATE TABLE silver.crm_prd_info (
    prd_id           INT,
    cat_id           VARCHAR(50),
    prd_key          VARCHAR(50),
    prd_nm           VARCHAR(100), 
    prd_cost         NUMERIC(10,2),
    prd_line         VARCHAR(50),
    prd_start_dt     DATE,
    prd_end_dt       DATE,

    -- DWH Audit Metadata
    dwh_create_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 3. Sales Details (CRM)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.crm_sales_details CASCADE; 
CREATE TABLE silver.crm_sales_details (
    sls_ord_num      VARCHAR(50),
    sls_prd_key      VARCHAR(50),
    sls_cust_id      INT,
    sls_order_dt     DATE,
    sls_ship_dt      DATE,
    sls_due_dt       DATE,
    sls_sales        NUMERIC(10,2),
    sls_quantity     INT,
    sls_price        NUMERIC(10,2),

    -- DWH Audit Metadata
    dwh_create_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 4. Customer Personal Information (ERP)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.erp_cust_az12 CASCADE; 
CREATE TABLE silver.erp_cust_az12 (
    cid           VARCHAR(50),
    bdate         DATE,
    gen           VARCHAR(50),

    -- DWH Audit Metadata
    dwh_create_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 5. Location Information (ERP)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.erp_loc_a101 CASCADE;
CREATE TABLE silver.erp_loc_a101 (
    cid       VARCHAR(50),
    cntry     VARCHAR(50),
    
    -- DWH Audit Metadata
    dwh_create_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 6. Product Categories (ERP)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2 CASCADE; 
CREATE TABLE silver.erp_px_cat_g1v2 (
    id            VARCHAR(50),
    cat           VARCHAR(50),
    subcat        VARCHAR(50),
    maintenance   VARCHAR(50),
	
    -- DWH Audit Metadata
    dwh_create_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Description: Bronze Layer Table Definitions
-- Project: Data Warehouse Architecture
-- Purpose: Defines raw landing tables for CRM and ERP data sources.

-- Target Database: data_warehouse
\connect data_warehouse

-- -----------------------------------------------------------------------------
-- 1. Customer Information (source_crm)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.crm_cust_info CASCADE;
CREATE TABLE bronze.crm_cust_info (
    cst_id             VARCHAR(50),
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr           VARCHAR(50),
    cst_create_date    VARCHAR(50),

    -- Audit Metadata Field
    _ingestion_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 2. Product Information (source_crm)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.crm_prd_info CASCADE;
CREATE TABLE bronze.crm_prd_info (
    prd_id           VARCHAR(50),
    prd_key          VARCHAR(50),
    prd_nm           VARCHAR(100), 
    prd_cost         VARCHAR(50),
    prd_line         VARCHAR(50),
    prd_start_dt     VARCHAR(50),
    prd_end_dt       VARCHAR(50),

    -- Audit Metadata Field
    _ingestion_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 3. Sales Details (source_crm)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.crm_sales_details CASCADE; 
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num      VARCHAR(50),
    sls_prd_key      VARCHAR(50),
    sls_cust_id      VARCHAR(50),
    sls_order_dt     VARCHAR(50),
    sls_ship_dt      VARCHAR(50),
    sls_due_dt       VARCHAR(50),
    sls_sales        VARCHAR(50),
    sls_quantity     VARCHAR(50),
    sls_price        VARCHAR(50),

    -- Audit Metadata Field
    _ingestion_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 4. Customer Personal Information (source_erp)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.erp_cust_az12 CASCADE; 
CREATE TABLE bronze.erp_cust_az12 (
    cid              VARCHAR(50),
    bdate            VARCHAR(50),
    gen              VARCHAR(50),

    -- Audit Metadata Field
    _ingestion_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 5. Location Information (source_erp)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.erp_loc_a101 CASCADE;
CREATE TABLE bronze.erp_loc_a101 (
    cid              VARCHAR(50),
    cntry            VARCHAR(50),
	
	-- Audit Metadata Field
	_ingestion_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 6. Product Categories (source_erp)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2 CASCADE; 
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id              VARCHAR(50),
    cat             VARCHAR(50),
    subcat          VARCHAR(50),
    maintenance     VARCHAR(50),
	
	-- Audit Metadata Field
	_ingestion_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- Schema Documentation & Comments
-- -----------------------------------------------------------------------------
COMMENT ON TABLE bronze.cust_info IS 'Raw landing table for CRM customer info (source_crm).';
COMMENT ON TABLE bronze.prd_info IS 'Raw landing table for CRM product catalog (source_crm).';
COMMENT ON TABLE bronze.sales_details IS 'Raw landing table for POS transaction records (source_crm).';
COMMENT ON TABLE bronze.cust_az12 IS 'Raw landing table for ERP customer personal demographics (source_erp).';
COMMENT ON TABLE bronze.loc_a101 IS 'Raw landing table for ERP customer geographic locations (source_erp).';
COMMENT ON TABLE bronze.px_cat_g1v2 IS 'Raw landing table for ERP product categories and maintenance attributes (source_erp).';

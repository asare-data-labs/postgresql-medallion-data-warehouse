-- Description: Data Warehouse Layer Initialization
-- Project: Data Warehouse Architecture
-- Purpose: Creates the Medallion Architecture schemas (Bronze, Silver, Gold).
-- Target Database: data_warehouse

-- Switch to target database when executed via psql
\connect data_warehouse

-- -----------------------------------------------------------------------------
-- Stored Procedure: create_data_warehouse_schemas
-- -----------------------------------------------------------------------------
-- Description: Safely creates or refreshes the multi-layered schema pipeline.
-- Warning: CASCADE drops existing schema objects (tables, views, functions).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE create_data_warehouse_schemas()
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Bronze Layer (Raw Ingestion / Landing Zone)
    DROP SCHEMA IF EXISTS bronze CASCADE;
    CREATE SCHEMA bronze;
    COMMENT ON SCHEMA bronze IS 'Bronze Layer: Raw ingested data, persistent staging.';

    -- 2. Silver Layer (Cleaned & Conformed Data)
    DROP SCHEMA IF EXISTS silver CASCADE;
    CREATE SCHEMA silver;
    COMMENT ON SCHEMA silver IS 'Silver Layer: Cleansed, transformed, and structured data.';

    -- 3. Gold Layer (Business & Analytical Marts)
    DROP SCHEMA IF EXISTS gold CASCADE;
    CREATE SCHEMA gold;
    COMMENT ON SCHEMA gold IS 'Gold Layer: Aggregated business metrics, reporting, and BI data marts.';

    RAISE NOTICE 'Data warehouse schemas (bronze, silver, gold) successfully initialized.';
END;
$$;

-- Execute Procedure
CALL create_data_warehouse_schemas();

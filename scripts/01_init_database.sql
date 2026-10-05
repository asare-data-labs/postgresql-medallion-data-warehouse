-- Description: Environment Initialization Script
-- Project: Data Warehouse Architecture
-- Purpose: Creates the target database 'data_warehouse' if it does not already exist.
-- Note: Must be executed by a user with CREATEDB privileges (e.g., 'postgres').
-- Warning: Drops 'data_warehouse' if it exists. All data will be permanently deleted. Proceed with caution and ensure you have proper backups.

DROP DATABASE IF EXISTS data_warehouse;

CREATE DATABASE data_warehouse
    WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE data_warehouse IS 'Primary database for Bronze, Silver, and Gold data warehouse layers.';

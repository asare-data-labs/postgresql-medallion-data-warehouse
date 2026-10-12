/*
====================================================================================
Stored Procedure: Load Bronze Layer (Source CSV Files -> Bronze Schema)
====================================================================================
Script Purpose:
    This stored procedure truncates and bulk-loads external CSV data into 
    the bronze schema tables using PostgreSQL's COPY command.
    
    It performs the following tasks:
    1. Tracks batch start time and individual table execution durations.
    2. Truncates landing tables to maintain idempotent loads.
    3. Maps CSV source fields explicitly to table target columns.
    4. Handles runtime execution errors gracefully with standard SQLSTATE reporting.

Parameters:
    None.

Usage Example:
    CALL bronze.load_bronze();
====================================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze ()
LANGUAGE plpgsql
AS $$
DECLARE 
    start_time TIMESTAMPTZ;
    end_time TIMESTAMPTZ;
    duration INTERVAL;
    batch_start_time TIMESTAMPTZ;
    batch_end_time TIMESTAMPTZ;
    batch_duration INTERVAL;
BEGIN
    batch_start_time := clock_timestamp();
    RAISE NOTICE '>> Batch load started at: %', date_trunc('seconds', batch_start_time);
    RAISE NOTICE '================================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================================';
    RAISE NOTICE '';

    -- =========================================================================
    -- 1. Loading CRM Source Tables
    -- =========================================================================
    RAISE NOTICE '----------------------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '----------------------------------------------------------------';

    -- -------------------------------------------------------------------------
    -- Table 1: bronze.crm_cust_info
    -- -------------------------------------------------------------------------
    start_time := clock_timestamp();
    RAISE NOTICE 'Loading bronze.crm_cust_info started at: %',date_trunc('seconds',start_time);
			
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
	
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
    COPY bronze.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
	  )
    FROM '/tmp/datasets/source_crm/cust_info.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );
		
    end_time := clock_timestamp();
    duration:= end_time - start_time;
    RAISE NOTICE 'Load finished at: %', date_trunc('seconds',end_time);
    RAISE NOTICE 'Total Load Duration: %', date_trunc('seconds',duration);
    RAISE NOTICE '****************************************************************';
    RAISE NOTICE '';

    -- -------------------------------------------------------------------------
    -- Table 2: bronze.crm_prd_info
    -- -------------------------------------------------------------------------
    start_time := clock_timestamp();
    RAISE NOTICE 'bronze.crm_prd_info started at: %', date_trunc('seconds',start_time);
    
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
            
    RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
    COPY bronze.crm_prd_info (
        prd_id,
        prd_key,
        prd_nm, 
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt 
    )
    FROM '/tmp/datasets/source_crm/prd_info.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );
        
    end_time := clock_timestamp();
    duration:= end_time - start_time;
    RAISE NOTICE 'Load finished at: %', date_trunc('seconds',end_time);
    RAISE NOTICE 'Total Load Duration: %', date_trunc('seconds',duration);
    RAISE NOTICE '****************************************************************';
    RAISE NOTICE '';

    -- -------------------------------------------------------------------------
    -- Table 3: bronze.crm_sales_details
    -- -------------------------------------------------------------------------
    start_time := clock_timestamp();
    RAISE NOTICE 'bronze.crm_sales_details started at: %',date_trunc('seconds',start_time);
            
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
    COPY bronze.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price 
    )
    FROM '/tmp/datasets/source_crm/sales_details.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );

    end_time := clock_timestamp();
    duration:= end_time - start_time;
    RAISE NOTICE 'Load finished at: %', date_trunc('seconds',end_time);
    RAISE NOTICE 'Total Load Duration: %', date_trunc('seconds',duration);
    RAISE NOTICE '****************************************************************';
    RAISE NOTICE '';

    -- =========================================================================
    -- 2. Loading ERP Source Tables
    -- =========================================================================
    RAISE NOTICE '----------------------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '----------------------------------------------------------------';

    -- -------------------------------------------------------------------------
    -- Table 4: bronze.erp_cust_az12
    -- -------------------------------------------------------------------------
    start_time := clock_timestamp();
    RAISE NOTICE 'bronze.erp_cust_az12 started at: %',date_trunc('seconds',start_time);
    
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
    COPY bronze.erp_cust_az12 (
        cid,
        bdate,
        gen    
    )
    FROM '/tmp/datasets/source_erp/cust_az12.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );
        
    end_time := clock_timestamp();
    duration:= end_time - start_time;
    RAISE NOTICE 'Load finished at: %', date_trunc('seconds',end_time);
    RAISE NOTICE 'Total Load Duration: %', date_trunc('seconds',duration);
    RAISE NOTICE '****************************************************************';
    RAISE NOTICE '';

    -- -------------------------------------------------------------------------
    -- Table 5: bronze.erp_loc_a101
    -- -------------------------------------------------------------------------
    start_time := clock_timestamp();
    RAISE NOTICE 'bronze.erp_loc_a101 started at: %',date_trunc('seconds',start_time);
            
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;

    RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
    COPY bronze.erp_loc_a101 (
        cid,
        cntry
    )
    FROM '/tmp/datasets/source_erp/loc_a101.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );
        
    end_time := clock_timestamp();
    duration:= end_time - start_time;
    RAISE NOTICE 'Load finished at: %', date_trunc('seconds',end_time);
    RAISE NOTICE 'Total Load Duration: %', date_trunc('seconds',duration);
    RAISE NOTICE '****************************************************************';
    RAISE NOTICE '';

    -- -------------------------------------------------------------------------
    -- Table 6: bronze.erp_px_cat_g1v2
    -- -------------------------------------------------------------------------
    start_time := clock_timestamp();
    RAISE NOTICE 'bronze.erp_px_cat_g1v2 started at: %',date_trunc('seconds',start_time);
            
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    
    RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
    COPY bronze.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    FROM '/tmp/datasets/source_erp/px_cat_g1v2.csv'
    WITH (
        FORMAT CSV,
        HEADER TRUE,
        DELIMITER ','
    );

    end_time := clock_timestamp();
    duration:= end_time - start_time;
    RAISE NOTICE 'Load finished at: %', date_trunc('seconds',end_time);
    RAISE NOTICE 'Total Load Duration: %', date_trunc('seconds',duration);
    RAISE NOTICE '****************************************************************';
    RAISE NOTICE '';
    
    -- =========================================================================
    -- Batch Execution Summary
    -- =========================================================================
    batch_end_time := clock_timestamp();
    batch_duration:= batch_end_time - batch_start_time;
    RAISE NOTICE '================================================================';
    RAISE NOTICE 'Batch Load finished at: %', date_trunc('seconds',batch_end_time);
    RAISE NOTICE 'Total Batch Load Duration: %', date_trunc('seconds',batch_duration);
    RAISE NOTICE '================================================================';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '================================================================';
            RAISE NOTICE 'AN ERROR OCCURED DURING LOADING BRONZE LAYER';
            RAISE NOTICE 'Error Code: %', SQLSTATE;
            RAISE NOTICE 'Error Message: %', SQLERRM;
            RAISE NOTICE '================================================================';
            RAISE EXCEPTION 'Bronze layer load failed. Check logs for details. SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
    END;
$$;

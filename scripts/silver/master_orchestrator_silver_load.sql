/*
===============================================================================
Master Orchestration Script: Load Silver Layer
===============================================================================
Purpose: 
    - Executes individual Silver table stored procedures in the correct 
      dependency order to ensure referential integrity.
    - Tracks overall execution timing and handles pipeline-wide error bubbling.
===============================================================================
*/

DO $$
DECLARE
    batch_start TIMESTAMPTZ;
    batch_end TIMESTAMPTZ;
    batch_duration INTERVAL;
BEGIN
    batch_start := clock_timestamp();
    RAISE NOTICE '================================================================';
    RAISE NOTICE 'Starting Silver Layer Full Load Pipeline at: %', date_trunc('seconds', batch_start);
    RAISE NOTICE '================================================================';

    -- 1. Load Independent Dimension & Lookup Tables First
    RAISE NOTICE '--- Phase 1: Loading Dimension & Lookup Tables ---';
    CALL silver.sp_load_crm_cust_info();
    CALL silver.sp_load_crm_prd_info();
    CALL silver.sp_load_erp_cust_az12();
    CALL silver.sp_load_erp_loc_a101();
    CALL silver.sp_load_erp_px_cat_g1v2();

    -- 2. Load Dependent Fact Tables Last (Requires customers & products to exist)
    RAISE NOTICE '--- Phase 2: Loading Fact Tables ---';
    CALL silver.sp_load_crm_sales_details();

    batch_end := clock_timestamp();
    batch_duration := batch_end - batch_start;
    
    RAISE NOTICE '================================================================';
    RAISE NOTICE 'Silver Layer Full Load Completed Successfully!';
    RAISE NOTICE 'Total Pipeline Duration: %', date_trunc('seconds', batch_duration);
    RAISE NOTICE '================================================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '================================================================';
        RAISE NOTICE 'CRITICAL ERROR: Silver Layer Orchestration Pipeline Failed!';
        RAISE NOTICE 'Error Code: %', SQLSTATE;
        RAISE NOTICE 'Error Message: %', SQLERRM;
        RAISE NOTICE '================================================================';
        RAISE EXCEPTION 'Pipeline execution aborted. SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
END $$;

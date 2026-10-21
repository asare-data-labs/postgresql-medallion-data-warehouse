/*
===============================================================================
Silver Layer Transformation: ERP Location Info (erp_loc_a101)
===============================================================================
Script Purpose:
    - Cleans and standardizes customer location keys by stripping hyphens and whitespace.
    - Standardizes country codes and abbreviations into clean, full country names 
      for consistent downstream reporting and analytics.
    - Includes execution logging, timing metrics, and error handling.
===============================================================================
*/
CREATE OR REPLACE PROCEDURE silver.sp_load_erp_loc_a101()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMPTZ;
    end_time TIMESTAMPTZ;
    duration INTERVAL;
BEGIN 
    start_time := clock_timestamp();
    RAISE NOTICE 'Loading silver.erp_loc_a101 started at: %',date_trunc('seconds',start_time);
                
    RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
        
    RAISE NOTICE '>> Inserting Data Into: silver.erp_loc_a101';
    INSERT INTO silver.erp_loc_a101 (
        cid,
        cntry
    )
    SELECT 
        NULLIF(REPLACE(TRIM(cid), '-', ''), '') AS cid,
        CASE 
          WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
          WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
          WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
          ELSE TRIM(cntry)
        END AS cntry 
    FROM bronze.erp_loc_a101;
        
    end_time := clock_timestamp();
    duration:= end_time - start_time;
    RAISE NOTICE 'Load finished at: %', date_trunc('seconds',end_time);
    RAISE NOTICE 'Total Load Duration: %', date_trunc('seconds',duration);
    RAISE NOTICE '****************************************************************';
    RAISE NOTICE '';
    
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '================================================================';
            RAISE NOTICE 'AN ERROR OCCURED DURING LOADING silver.sp_erp_loc_a101';
            RAISE NOTICE 'Error Code: %', SQLSTATE;
            RAISE NOTICE 'Error Message: %', SQLERRM;
            RAISE NOTICE '================================================================';
            RAISE EXCEPTION 'silver.sp_erp_loc_a101 load failed. Check logs for details. SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
END;
$$;

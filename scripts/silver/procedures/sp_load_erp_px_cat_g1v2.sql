/*
===============================================================================
Silver Layer Transformation: ERP Product Category Info (erp_px_cat_g1v2)
===============================================================================
Script Purpose:
    - Cleans and standardizes raw product category lookup data from Bronze.
    - Strips unwanted whitespace across ID, category, subcategory, and maintenance attributes.
    - Safely converts empty or blank text fields into standardized SQL NULL values.
    - Includes execution logging, timing metrics, and error handling.
===============================================================================
*/
CREATE OR REPLACE PROCEDURE silver.sp_load_erp_px_cat_g1v2()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMPTZ;
    end_time TIMESTAMPTZ;
    duration INTERVAL;
BEGIN 
    start_time := clock_timestamp();
    RAISE NOTICE 'Loading silver.erp_px_cat_g1v2 started at: %',date_trunc('seconds',start_time);
            
    RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
        
    RAISE NOTICE '>> Inserting Data Into: silver.erp_px_cat_g1v2';
    INSERT INTO silver.erp_px_cat_g1v2(
        id,
        cat,
        subcat,
        maintenance
		)
    SELECT
        NULLIF(TRIM(id), '') AS id,
        NULLIF(TRIM(cat), '') AS cat,
        NULLIF(TRIM(subcat), '') AS subcat,
        NULLIF(TRIM(maintenance), '') AS maintenance
    FROM bronze.erp_px_cat_g1v2;

    end_time := clock_timestamp();
    duration:= end_time - start_time;
    RAISE NOTICE 'Load finished at: %', date_trunc('seconds',end_time);
    RAISE NOTICE 'Total Load Duration: %', date_trunc('seconds',duration);
    RAISE NOTICE '****************************************************************';
    RAISE NOTICE '';

    EXCEPTION
        WHEN OTHERS THEN
          RAISE NOTICE '================================================================';
          RAISE NOTICE 'AN ERROR OCCURED DURING LOADING silver.sp_load_erp_px_cat_g1v2';
          RAISE NOTICE 'Error Code: %', SQLSTATE;
          RAISE NOTICE 'Error Message: %', SQLERRM;
          RAISE NOTICE '================================================================';
          RAISE EXCEPTION 'silver.sp_load_erp_px_cat_g1v2 load failed. Check logs for details. SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
END;
$$;

/*
===============================================================================
Silver Layer Transformation: Product Info (crm_prd_info)
===============================================================================
Script Purpose:
    - Cleans, standardizes, and transforms raw product data from Bronze.
    - Splits composite product keys into category ID and clean product key.
    - Standardizes product lines and handles null costs gracefully.
    - Uses LEAD window function to fix historical date overlaps, leaving 
      active/current records with a NULL end date.
    - Includes execution logging, timing metrics, and error handling.
===============================================================================
*/
CREATE OR REPLACE PROCEDURE silver.sp_load_crm_prd_info()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMPTZ;
    end_time TIMESTAMPTZ;
    duration INTERVAL;
BEGIN 
    start_time := clock_timestamp();
    RAISE NOTICE 'Loading silver.crm_prd_info started at: %',date_trunc('seconds',start_time);
            
    RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    
    RAISE NOTICE '>> Inserting Data Into: silver.crm_prd_info';
    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt 
    )
    SELECT
        CAST(NULLIF(TRIM(prd_id), '') AS INT) AS prd_id,
        REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') AS cat_id,
        SUBSTRING(TRIM(prd_key), 7, LENGTH(TRIM(prd_key))) AS prd_key,
        TRIM(prd_nm) AS prd_nm,
        COALESCE(CAST(NULLIF(TRIM(prd_cost), '') AS NUMERIC), 0) AS prd_cost,
        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
        CAST(NULLIF(TRIM(prd_start_dt), '') AS DATE) AS prd_start_dt,
        CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE) + INTERVAL '-1 day' AS prd_end_dt 
    FROM bronze.crm_prd_info;
    
    end_time := clock_timestamp();
    duration:= end_time - start_time;
    RAISE NOTICE 'Load finished at: %', date_trunc('seconds',end_time);
    RAISE NOTICE 'Total Load Duration: %', date_trunc('seconds',duration);
    RAISE NOTICE '****************************************************************';
    RAISE NOTICE '';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '================================================================';
            RAISE NOTICE 'AN ERROR OCCURED DURING LOADING silver.sp_load_crm_prd_info';
            RAISE NOTICE 'Error Code: %', SQLSTATE;
            RAISE NOTICE 'Error Message: %', SQLERRM;
            RAISE NOTICE '================================================================';
            RAISE EXCEPTION 'silver.sp_load_crm_prd_info load failed. Check logs for details. SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
END;
$$;

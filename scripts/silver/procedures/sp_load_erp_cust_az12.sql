/*
===============================================================================
Silver Layer Transformation: ERP Customer Info (erp_cust_az12)
===============================================================================
Script Purpose:
    - Standardizes customer IDs by stripping unwanted whitespace and removing 
      the legacy 'NAS' prefix to align with CRM customer keys.
    - Safely sanitizes birthdates, rejecting malformed strings and future dates.
    - Standardizes gender codes into clean, readable categorical values.
    - Includes execution logging, timing metrics, and error handling.
===============================================================================
*/
CREATE OR REPLACE PROCEDURE silver.sp_load_erp_cust_az12()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMPTZ;
    end_time TIMESTAMPTZ;
    duration INTERVAL;
BEGIN 
    start_time := clock_timestamp();
    RAISE NOTICE 'Loading silver.erp_cust_az12 started at: %',date_trunc('seconds',start_time);
            
    RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;
    
    RAISE NOTICE '>> Inserting Data Into: silver.erp_cust_az12';
    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    SELECT
        CASE 
            WHEN TRIM(cid) LIKE 'NAS%' THEN NULLIF(TRIM(SUBSTRING(TRIM(cid), 4, LENGTH(TRIM(cid)))), '')
            ELSE NULLIF(TRIM(cid), '')
        END AS cid,
        CASE 
            WHEN NULLIF(TRIM(bdate), '') ~ '^\d{4}-\d{2}-\d{2}$'
            AND CAST(NULLIF(TRIM(bdate), '') AS DATE) <= CURRENT_DATE 
            THEN CAST(NULLIF(TRIM(bdate), '') AS DATE)
            ELSE NULL 
        END AS bdate,
        CASE 
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            ELSE 'n/a'
        END AS gen
    FROM bronze.erp_cust_az12;
    
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '================================================================';
            RAISE NOTICE 'AN ERROR OCCURED DURING LOADING silver.sp_load_erp_cust_az12';
            RAISE NOTICE 'Error Code: %', SQLSTATE;
            RAISE NOTICE 'Error Message: %', SQLERRM;
            RAISE NOTICE '================================================================';
            RAISE EXCEPTION 'silver.sp_load_erp_cust_az12 load failed. Check logs for details. SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
END;
$$;

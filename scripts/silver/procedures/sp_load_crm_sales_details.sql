/*
===============================================================================
Silver Layer Transformation: Sales Details (crm_sales_details)
===============================================================================
Script Purpose:
    - Cleans and standardizes transaction IDs, product keys, and customer IDs.
    - Converts 8-character string dates (YYYYMMDD) into proper SQL DATE types,
      handling missing values ('0' or invalid lengths) by setting them to NULL.
    - Reconciles financial calculation errors (recalculating sales or prices 
      where quantity * price mismatches sales totals).
    - Includes execution logging, timing metrics, and error handling.
===============================================================================
*/
CREATE OR REPLACE PROCEDURE silver.sp_load_crm_sales_details()
LANGUAGE plpgsql
AS $$
DECLARE
  start_time TIMESTAMPTZ;
  end_time TIMESTAMPTZ;
  duration INTERVAL;
BEGIN 
  start_time := clock_timestamp();
  RAISE NOTICE 'Loading silver.crm_sales_details started at: %',date_trunc('seconds',start_time);
            
  RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
  TRUNCATE TABLE silver.crm_sales_details;
    
  RAISE NOTICE '>> Inserting Data Into: silver.crm_sales_details';
  INSERT INTO silver.crm_sales_details (
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
  SELECT
      NULLIF(TRIM(sls_ord_num), '') AS sls_ord_num,
      NULLIF(TRIM(sls_prd_key), '') AS sls_prd_key,
      CAST(NULLIF(TRIM(sls_cust_id), '') AS INT) AS sls_cust_id,
      CASE
        WHEN sls_order_dt = '0' OR LENGTH(TRIM(sls_order_dt)) != 8 THEN NULL
        ELSE TO_DATE(TRIM(sls_order_dt), 'YYYYMMDD')
      END AS sls_order_dt,
      CASE
        WHEN sls_ship_dt = '0' OR LENGTH(TRIM(sls_ship_dt)) != 8 THEN NULL
        ELSE TO_DATE(TRIM(sls_ship_dt), 'YYYYMMDD')
      END AS sls_ship_dt,
      CASE
        WHEN sls_due_dt = '0' OR LENGTH(TRIM(sls_due_dt)) != 8 THEN NULL
        ELSE TO_DATE(TRIM(sls_due_dt), 'YYYYMMDD')
      END AS sls_due_dt,
      CASE 
        WHEN CAST(NULLIF(TRIM(sls_sales), '') AS NUMERIC) IS NULL 
          OR CAST(NULLIF(TRIM(sls_sales), '') AS NUMERIC) <= 0 
          OR CAST(NULLIF(TRIM(sls_sales), '') AS NUMERIC) != CAST(NULLIF(TRIM(sls_quantity), '') AS NUMERIC) * ABS(CAST(NULLIF(TRIM(sls_price), '') AS NUMERIC))
        THEN CAST(NULLIF(TRIM(sls_quantity), '') AS NUMERIC) * ABS(CAST(NULLIF(TRIM(sls_price), '') AS NUMERIC))
    ELSE CAST(NULLIF(TRIM(sls_sales), '') AS NUMERIC)
    END AS sls_sales,
    CAST(NULLIF(TRIM(sls_quantity), '') AS INT) AS sls_quantity,
    CASE
        WHEN NULLIF(TRIM(sls_price), '') IS NULL 
          OR CAST(NULLIF(TRIM(sls_price), '') AS NUMERIC) <= 0
        THEN CAST(NULLIF(TRIM(sls_sales), '') AS NUMERIC) / NULLIF(CAST(NULLIF(TRIM(sls_quantity), '') AS NUMERIC), 0)
        ELSE CAST(NULLIF(TRIM(sls_price), '') AS NUMERIC)
    END AS sls_price  
FROM bronze.crm_sales_details;

end_time := clock_timestamp();
duration:= end_time - start_time;
RAISE NOTICE 'Load finished at: %', date_trunc('seconds',end_time);
RAISE NOTICE 'Total Load Duration: %', date_trunc('seconds',duration);
RAISE NOTICE '****************************************************************';
RAISE NOTICE '';

EXCEPTION
  WHEN OTHERS THEN
     RAISE NOTICE '================================================================';
     RAISE NOTICE 'AN ERROR OCCURED DURING LOADING silver.sp_load_crm_sales_details';
     RAISE NOTICE 'Error Code: %', SQLSTATE;
     RAISE NOTICE 'Error Message: %', SQLERRM;
     RAISE NOTICE '================================================================';
     RAISE EXCEPTION 'silver.sp_load_crm_sales_details load failed. Check logs for details. SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
 END;
$$;

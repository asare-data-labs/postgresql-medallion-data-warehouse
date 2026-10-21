/*
-- =================================================================================
-- Silver Layer Transformation: Customer Details (crm_cust_info)
====================================================================================
Script Purpose:
    This script performs data quality checks, cleansing, and transformation on the 
    raw bronze customer data and loads it into the conformed silver layer table:
    `silver.crm_cust_info`.

Transformations Performed:
    1. Removes duplicate customer records by keeping the latest record based on create date.
    2. Trims leading and trailing whitespace from string fields.
    3. Standardizes gender and marital status codes into readable descriptions.
    4. Safely casts string data types into proper INT and DATE types.
    5. Includes execution logging, timing metrics, and error handling.
====================================================================================
*/
CREATE OR REPLACE PROCEDURE silver.sp_load_crm_cust_info()
LANGUAGE plpgsql
AS $$
DECLARE
	start_time TIMESTAMPTZ;
	end_time TIMESTAMPTZ;
	duration INTERVAL;
BEGIN 
    start_time := clock_timestamp();
    RAISE NOTICE 'Loading silver.crm_cust_info started at: %',date_trunc('seconds',start_time);
            
    RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    
    RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info (
	    cst_id, 
	    cst_key, 
	    cst_firstname, 
	    cst_lastname, 
	    cst_marital_status, 
	    cst_gndr, 
	    cst_create_date
	)
	SELECT
	    CAST(NULLIF(TRIM(cst_id), '') AS INT) AS cst_id,
	    REGEXP_REPLACE(TRIM(cst_key), '\s+', ' ', 'g') AS cst_key,
	    TRIM(cst_firstname) AS cst_firstname,
	    TRIM(cst_lastname) AS cst_lastname,
	    CASE
	        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	        ELSE 'n/a'
	    END AS cst_marital_status,
	    CASE
	        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	        ELSE 'n/a'
	    END AS cst_gndr,
	    CASE 
	        WHEN NULLIF(TRIM(cst_create_date), '') ~ '^\d{4}-\d{2}-\d{2}$' 
	        THEN CAST(TRIM(cst_create_date) AS DATE)
	        ELSE NULL 
	    END AS cst_create_date
	FROM (
	    SELECT
	        *,
	        ROW_NUMBER() OVER (
	            PARTITION BY CAST(NULLIF(TRIM(cst_id), '') AS INT) 
	            ORDER BY 
	                CASE 
	                    WHEN NULLIF(TRIM(cst_create_date), '') ~ '^\d{4}-\d{2}-\d{2}$' 
	                    THEN CAST(TRIM(cst_create_date) AS DATE)
	                    ELSE '1900-01-01'::DATE 
	                END DESC
	        ) AS flag_last
	    FROM bronze.crm_cust_info
	    WHERE cst_id IS NOT NULL AND TRIM(cst_id) != '' AND cst_id !~ '\s{2,}'
	) AS cleaned_customers
	WHERE flag_last = 1;

EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE '================================================================';
			RAISE NOTICE 'AN ERROR OCCURED DURING LOADING silver.sp_load_crm_cust_info';
			RAISE NOTICE 'Error Code: %', SQLSTATE;
            RAISE NOTICE 'Error Message: %', SQLERRM;
            RAISE NOTICE '================================================================';
            RAISE EXCEPTION 'silver.sp_load_crm_cust_info load failed. Check logs for details. SQLSTATE: %, SQLERRM: %', SQLSTATE, SQLERRM;
END;
$$;

/*
==================================================================================================================================
Creates the stored procedure silver.load_silver, which loads the Silver Layer. This layer consists of cleaned up data 
from the bronze layer.

Usage: 
EXEC silver.load_silver 
==================================================================================================================================
*/


-- USE DataWarehouse


CREATE OR ALTER PROCEDURE silver.load_silver 
AS 

BEGIN 
    TRUNCATE TABLE silver.crm_cust_info;
    PRINT('Inserting data into silver.crm_cust_info');

    -- Removes unwanted duplicates (selects data from most recent entry)

    WITH no_duplicates AS
    (
        SELECT *
        FROM
        (
            SELECT *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS recency_flag
            FROM bronze.crm_cust_info 
            WHERE cst_id IS NOT NULL
        )t
        WHERE recency_flag = 1
    )


    INSERT INTO silver.crm_cust_info 
    (
    cst_id, 
    cst_key, 
    cst_firstname, 
    cst_lastname, 
    cst_marital_status, 
    cst_gndr, 
    cst_create_date   
    )


    -- removes unwanted spaces in first names and last names

    SELECT 
    cst_id, cst_key, TRIM(cst_firstname) AS cst_firstname, TRIM(cst_lastname) AS cst_lastname, 
    CASE 
        WHEN cst_marital_status = 'M' THEN 'Married'
        WHEN cst_marital_status = 'S' THEN 'Single'
        ELSE 'Unknown'
    END AS cst_marital_status, 
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        ELSE 'Unknown'
    END AS cst_gndr, 
    cst_create_date
    FROM no_duplicates


    /*
    ===================================================================================================================
    Same for file crm.prd_info
    ===================================================================================================================
    */

    TRUNCATE TABLE silver.crm_prd_info 
    PRINT('Inserting data into silver.crm_prd_info')

    INSERT INTO silver.crm_prd_info 
    (prd_id, 
    cat_id, 
    prd_key, 
    prd_nm, 
    prd_cost, 
    prd_line, 
    prd_start_dt, 
    prd_end_dt
    )

    SELECT 
    prd_id, 
    REPLACE(SUBSTRING(prd_key, 1,5), '-', '_') AS cat_id,  AS cat_id, 
    SUBSTRING(prd_key, 7) AS prd_key,
    prd_nm, 
    ISNULL(prd_cost, 0) AS prd_cost, 
    CASE 
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        ELSE 'Unknown'
    END AS prd_line, 
    CAST(prd_start_dt AS DATE) AS prd_start_dt, 
    CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC)-1 AS DATE) AS prd_end_dt
    FROM bronze.crm_prd_info



    /*
    =========================================================================================================
    And similarly for silver.crm_sales_details
    =========================================================================================================
    */

    TRUNCATE TABLE silver.crm_sales_details
    PRINT('Inserting data into silver.crm_sales_details')

    INSERT INTO silver.crm_sales_details 
    (sls_ord_num, 
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
    sls_ord_num,
    sls_prd_key, 
    sls_cust_id, 
    CASE 
        WHEN LEN(sls_order_dt)!=8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
    END AS sls_order_dt, 
    CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE) AS sls_ship_dt, 
    CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE) AS sls_due_dt, 
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales 
    END AS sls_sales, 
    sls_quantity, 
    CASE 
    WHEN sls_price IS NULL THEN sls_sales / sls_quantity 
        WHEN sls_price < 0 THEN -sls_price
        ELSE sls_price 
    END AS sls_price
    FROM bronze.crm_sales_details


    /*
    =====================================================================================================
    Cleaning up the next table 
    =====================================================================================================
    */

    TRUNCATE TABLE silver.erp_cust_az12 
    PRINT('Inserting data into silver.erp_cust_az12')

    INSERT INTO silver.erp_cust_az12 
    (
        cid, 
        bdate, 
        gen 
    )


    SELECT 
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
        ELSE cid
    END AS cid, 
    CASE 
        WHEN bdate > GETDATE() THEN NULL 
        ELSE bdate 
    END AS bdate, 
    CASE 
        WHEN UPPER(gen) = 'F' THEN 'Female'
        WHEN UPPER(gen) = 'M' THEN 'Male'
        WHEN gen = '' OR gen IS NULL THEN 'Unknown'
        ELSE gen 
    END AS gen
    FROM bronze.erp_cust_az12

    /*
    =============================================================================
    And another one
    =============================================================================
    */

    TRUNCATE TABLE silver.erp_loc_a101 
    PRINT('Inserting data into silver.erp_loc_a101')

    INSERT INTO silver.erp_loc_a101
    (
        cid, 
        cntry
    )

    SELECT 
    REPLACE(cid, '-', '') AS cid, 
    CASE 
        WHEN cntry = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
        WHEN cntry = '' OR cntry IS NULL THEN 'Unknown'
        ELSE TRIM(cntry)
    END AS cntry
    FROM bronze.erp_loc_a101

    /*
    =================================================================================
    Last one, I swear 
    =================================================================================
    */

    TRUNCATE TABLE silver.erp_px_cat_g1v2 
    PRINT('Inserting data into silver.erp_px_cat_g1v2')

    INSERT INTO silver.erp_px_cat_g1v2
    (
        id, 
        cat,
        subcat, 
        maintenance
    )

    SELECT *
    FROM bronze.erp_px_cat_g1v2

END 

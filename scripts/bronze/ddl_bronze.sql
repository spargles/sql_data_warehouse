/*
==================================================================================================================
Creates one (at this point empty) table for each CSV file.
For the first table, it checks whether it exists and drops it if it does.
This would be the correct thing to do for all tables, but all of this is just an exercise, and the learning
effect from copy paste is... limited.
==================================================================================================================
*/



-- added this just once, technically the clean solution
IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info

CREATE TABLE bronze.crm_cust_info
(
    cst_id INT,
    cst_key NVARCHAR(50), 
    cst_firstname NVARCHAR(30), 
    cst_lastname NVARCHAR(30), 
    cst_marital_status NVARCHAR(20),
    cst_gndr NVARCHAR(20),
    cst_create_date DATE
);



CREATE TABLE bronze.crm_prd_info
(
    prd_id INT PRIMARY KEY,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);


CREATE TABLE bronze.crm_sales_details
(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);




CREATE TABLE bronze.erp_cust_az12
(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(20)
);


CREATE TABLE bronze.erp_loc_a101
(
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

CREATE TABLE bronze.erp_px_cat_g1v2
(   
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(20)
);

/*
================================================================================================================================
Creates the procedure load_bronze, that bulk inserts all data from csv files into the tables created in ddl_bronze.
Includes a few timers to keep track of loading times of certain files. A cleaner version would contain more timers and maybe
a seperate config file for data paths.

To properly run this, first replace the placeholders YOUR_LOCAL_PATH.
After executing the query, the procedure may be used via EXEC bronze.load_bronze

================================================================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT('Loading Bronze Layer')


        SET @start_time = GETDATE();

        PRINT('Loading CRM Tables')
        TRUNCATE TABLE bronze.crm_cust_info;

        BULK INSERT bronze.crm_cust_info
        FROM 'YOUR_LOCAL_PATH\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT('Load time:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.');



        TRUNCATE TABLE bronze.crm_prd_info;

        BULK INSERT bronze.crm_prd_info
        FROM 'YOUR_LOCAL_PATH\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );



        TRUNCATE TABLE bronze.crm_sales_details;

        BULK INSERT bronze.crm_sales_details
        FROM 'YOUR_LOCAL_PATH\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @start_time = GETDATE();

        PRINT('Loading ERP Tables')

        TRUNCATE TABLE bronze.erp_cust_az12;

        BULK INSERT bronze.erp_cust_az12
        FROM 'YOUR_LOCAL_PATH\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );


        TRUNCATE TABLE bronze.erp_loc_a101;

        BULK INSERT bronze.erp_loc_a101
        FROM 'YOUR_LOCAL_PATH\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );



        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'YOUR_LOCAL_PATH\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );


    SET @end_time = GETDATE();

        PRINT('Load time for ERP tables:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.');
    

    END TRY
    BEGIN CATCH 
        PRINT('Something''s gone wrong' );
        PRINT('Error Message'+ ERROR_MESSAGE());
        PRINT('Error Number'+ CAST(ERROR_NUMBER() AS NVARCHAR));
    END CATCH
END

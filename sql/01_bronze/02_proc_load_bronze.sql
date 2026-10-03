/*
===============================================================================
Bronze Load Procedure
Purpose:
    Load the six CSV source files into Bronze.

Usage:
    EXEC bronze.load_bronze
         @data_root = N'C:\path\to\medallion-architecture-data-warehouse';

The procedure expects:
    <data_root>\datasets\source_crm\cust_info.csv
    <data_root>\datasets\source_crm\prd_info.csv
    <data_root>\datasets\source_crm\sales_details.csv
    <data_root>\datasets\source_erp\cust_az12.csv
    <data_root>\datasets\source_erp\loc_a101.csv
    <data_root>\datasets\source_erp\px_cat_g1v2.csv

Important:
    SQL Server service-account permissions must allow the server to read the
    supplied files. BULK INSERT reads files from the SQL Server host.
===============================================================================
*/
USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
    @data_root NVARCHAR(4000)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @batch_start DATETIME2 = SYSDATETIME(),
        @start_time  DATETIME2,
        @file_path   NVARCHAR(4000),
        @sql         NVARCHAR(MAX);

    SET @data_root = RTRIM(@data_root);

    BEGIN TRY

        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        /* CRM: customer */
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE bronze.crm_cust_info;
        SET @file_path = CONCAT(@data_root, N'\datasets\source_crm\cust_info.csv');

        SET @sql = N'
            BULK INSERT bronze.crm_cust_info
            FROM ''' + REPLACE(@file_path,'''','''''') + N'''
            WITH (
                FORMAT = ''CSV'',
                FIRSTROW = 2,
                FIELDQUOTE = ''"'',
                TABLOCK
            );';
        EXEC sys.sp_executesql @sql;

        PRINT CONCAT('crm_cust_info loaded in ',
                     DATEDIFF(SECOND, @start_time, SYSDATETIME()), ' seconds');

        /* CRM: product */
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE bronze.crm_prd_info;
        SET @file_path = CONCAT(@data_root, N'\datasets\source_crm\prd_info.csv');

        SET @sql = N'
            BULK INSERT bronze.crm_prd_info
            FROM ''' + REPLACE(@file_path,'''','''''') + N'''
            WITH (
                FORMAT = ''CSV'',
                FIRSTROW = 2,
                FIELDQUOTE = ''"'',
                TABLOCK
            );';
        EXEC sys.sp_executesql @sql;

        PRINT CONCAT('crm_prd_info loaded in ',
                     DATEDIFF(SECOND, @start_time, SYSDATETIME()), ' seconds');

        /* CRM: sales */
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE bronze.crm_sales_details;
        SET @file_path = CONCAT(@data_root, N'\datasets\source_crm\sales_details.csv');

        SET @sql = N'
            BULK INSERT bronze.crm_sales_details
            FROM ''' + REPLACE(@file_path,'''','''''') + N'''
            WITH (
                FORMAT = ''CSV'',
                FIRSTROW = 2,
                FIELDQUOTE = ''"'',
                TABLOCK
            );';
        EXEC sys.sp_executesql @sql;

        PRINT CONCAT('crm_sales_details loaded in ',
                     DATEDIFF(SECOND, @start_time, SYSDATETIME()), ' seconds');

        /* ERP: customer */
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE bronze.erp_cust_az12;
        SET @file_path = CONCAT(@data_root, N'\datasets\source_erp\cust_az12.csv');

        SET @sql = N'
            BULK INSERT bronze.erp_cust_az12
            FROM ''' + REPLACE(@file_path,'''','''''') + N'''
            WITH (
                FORMAT = ''CSV'',
                FIRSTROW = 2,
                FIELDQUOTE = ''"'',
                TABLOCK
            );';
        EXEC sys.sp_executesql @sql;

        PRINT CONCAT('erp_cust_az12 loaded in ',
                     DATEDIFF(SECOND, @start_time, SYSDATETIME()), ' seconds');

        /* ERP: location */
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE bronze.erp_loc_a101;
        SET @file_path = CONCAT(@data_root, N'\datasets\source_erp\loc_a101.csv');

        SET @sql = N'
            BULK INSERT bronze.erp_loc_a101
            FROM ''' + REPLACE(@file_path,'''','''''') + N'''
            WITH (
                FORMAT = ''CSV'',
                FIRSTROW = 2,
                FIELDQUOTE = ''"'',
                TABLOCK
            );';
        EXEC sys.sp_executesql @sql;

        PRINT CONCAT('erp_loc_a101 loaded in ',
                     DATEDIFF(SECOND, @start_time, SYSDATETIME()), ' seconds');

        /* ERP: product category */
        SET @start_time = SYSDATETIME();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        SET @file_path = CONCAT(@data_root, N'\datasets\source_erp\px_cat_g1v2.csv');

        SET @sql = N'
            BULK INSERT bronze.erp_px_cat_g1v2
            FROM ''' + REPLACE(@file_path,'''','''''') + N'''
            WITH (
                FORMAT = ''CSV'',
                FIRSTROW = 2,
                FIELDQUOTE = ''"'',
                TABLOCK
            );';
        EXEC sys.sp_executesql @sql;

        PRINT CONCAT('erp_px_cat_g1v2 loaded in ',
                     DATEDIFF(SECOND, @start_time, SYSDATETIME()), ' seconds');

        PRINT '================================================';
        PRINT CONCAT('Bronze load completed in ',
                     DATEDIFF(SECOND, @batch_start, SYSDATETIME()), ' seconds');
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR DURING BRONZE LOAD';
        PRINT CONCAT('Error Number : ', ERROR_NUMBER());
        PRINT CONCAT('Error Line   : ', ERROR_LINE());
        PRINT CONCAT('Error Message: ', ERROR_MESSAGE());
        PRINT '================================================';
        THROW;
    END CATCH
END;
GO

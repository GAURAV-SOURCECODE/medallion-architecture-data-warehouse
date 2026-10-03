/*
===============================================================================
Silver Load Procedure
Purpose:
    Transform Bronze data into cleaned and standardized Silver data.

Design decision:
    Silver is full-refresh in this portfolio project. It uses TRUNCATE + INSERT
    so the transformation logic remains deterministic and easy to demonstrate.

Usage:
    EXEC silver.load_silver;
===============================================================================
*/
USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @batch_start DATETIME2 = SYSDATETIME();

    BEGIN TRY

        /* ================================================================
           CRM CUSTOMER
           Keep the latest record for each customer business key.
           ================================================================ */
        TRUNCATE TABLE silver.crm_cust_info;

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
        SELECT
            cst_id,
            TRIM(cst_key),
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,
            cst_create_date
        FROM
        (
            SELECT *,
                   ROW_NUMBER() OVER
                   (
                       PARTITION BY cst_id
                       ORDER BY cst_create_date DESC
                   ) AS rn
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) AS x
        WHERE rn = 1;

        /* ================================================================
           CRM PRODUCT
           Derive category ID and product number.
           Build product validity windows using LEAD().
           ================================================================ */
        TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info
        (
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
            prd_id,
            REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_') AS cat_id,
            SUBSTRING(TRIM(prd_key), 7, LEN(TRIM(prd_key))) AS prd_key,
            TRIM(prd_nm),
            ISNULL(prd_cost, 0),
            CASE
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END,
            CAST(prd_start_dt AS DATE),
            DATEADD
            (
                DAY,
                -1,
                LEAD(CAST(prd_start_dt AS DATE)) OVER
                (
                    PARTITION BY TRIM(prd_key)
                    ORDER BY CAST(prd_start_dt AS DATE)
                )
            )
        FROM bronze.crm_prd_info;

        /* ================================================================
           CRM SALES
           Convert YYYYMMDD integers safely and repair invalid metrics.

           Logic:
             1. If quantity is invalid, preserve it for DQ visibility.
             2. If price is invalid but sales is usable, derive price.
             3. If sales is invalid but quantity and price are usable,
                calculate sales = quantity * absolute(price).
             4. TRY_CONVERT prevents malformed dates from failing the load.
           ================================================================ */
        TRUNCATE TABLE silver.crm_sales_details;

        ;WITH base AS
        (
            SELECT
                TRIM(sls_ord_num) AS sls_ord_num,
                TRIM(sls_prd_key) AS sls_prd_key,
                sls_cust_id,
                CASE
                    WHEN sls_order_dt = 0 OR LEN(CONVERT(VARCHAR(20), sls_order_dt)) <> 8
                        THEN NULL
                    ELSE TRY_CONVERT(DATE, CONVERT(CHAR(8), sls_order_dt))
                END AS sls_order_dt,
                CASE
                    WHEN sls_ship_dt = 0 OR LEN(CONVERT(VARCHAR(20), sls_ship_dt)) <> 8
                        THEN NULL
                    ELSE TRY_CONVERT(DATE, CONVERT(CHAR(8), sls_ship_dt))
                END AS sls_ship_dt,
                CASE
                    WHEN sls_due_dt = 0 OR LEN(CONVERT(VARCHAR(20), sls_due_dt)) <> 8
                        THEN NULL
                    ELSE TRY_CONVERT(DATE, CONVERT(CHAR(8), sls_due_dt))
                END AS sls_due_dt,
                sls_sales,
                sls_quantity,
                sls_price
            FROM bronze.crm_sales_details
        ),
        repaired AS
        (
            SELECT
                *,
                CASE
                    WHEN sls_sales IS NULL
                         OR sls_sales <= 0
                         OR (
                              sls_quantity IS NOT NULL
                              AND sls_price IS NOT NULL
                              AND sls_sales <> sls_quantity * ABS(sls_price)
                            )
                    THEN
                        CASE
                            WHEN sls_quantity > 0 AND sls_price IS NOT NULL
                                THEN sls_quantity * ABS(sls_price)
                            ELSE sls_sales
                        END
                    ELSE sls_sales
                END AS corrected_sales
            FROM base
        )
        INSERT INTO silver.crm_sales_details
        (
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
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            corrected_sales,
            sls_quantity,
            CASE
                WHEN sls_price IS NULL OR sls_price <= 0
                    THEN corrected_sales / NULLIF(sls_quantity, 0)
                ELSE ABS(sls_price)
            END
        FROM repaired;

        /* ================================================================
           ERP CUSTOMER
           Normalize customer IDs, dates and gender.
           ================================================================ */
        TRUNCATE TABLE silver.erp_cust_az12;

        INSERT INTO silver.erp_cust_az12
        (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE
                WHEN TRIM(cid) LIKE 'NAS%' THEN SUBSTRING(TRIM(cid), 4, LEN(TRIM(cid)))
                ELSE TRIM(cid)
            END,
            CASE
                WHEN bdate > CAST(GETDATE() AS DATE) THEN NULL
                ELSE bdate
            END,
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END
        FROM bronze.erp_cust_az12;

        /* ================================================================
           ERP LOCATION
           Normalize customer ID and country names.
           ================================================================ */
        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101
        (
            cid,
            cntry
        )
        SELECT
            REPLACE(TRIM(cid), '-', ''),
            CASE
                WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
                WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
                WHEN NULLIF(TRIM(cntry), '') IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END
        FROM bronze.erp_loc_a101;

        /* ================================================================
           ERP PRODUCT CATEGORY
           ================================================================ */
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2
        (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            TRIM(id),
            TRIM(cat),
            TRIM(subcat),
            CASE
                WHEN UPPER(TRIM(maintenance)) = 'YES' THEN 'Yes'
                WHEN UPPER(TRIM(maintenance)) = 'NO' THEN 'No'
                ELSE 'n/a'
            END
        FROM bronze.erp_px_cat_g1v2;

        PRINT CONCAT(
            'Silver load completed in ',
            DATEDIFF(SECOND, @batch_start, SYSDATETIME()),
            ' seconds.'
        );

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR DURING SILVER LOAD';
        PRINT CONCAT('Error Number : ', ERROR_NUMBER());
        PRINT CONCAT('Error Line   : ', ERROR_LINE());
        PRINT CONCAT('Error Message: ', ERROR_MESSAGE());
        PRINT '================================================';
        THROW;
    END CATCH
END;
GO

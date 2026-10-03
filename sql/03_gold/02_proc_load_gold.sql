/*
===============================================================================
Gold Load Procedure
Purpose:
    Build the physical star schema from Silver.

Grain:
    One row in fact_sales represents one product line within one sales order.

Dimensions:
    dim_customers - customer master + ERP demographic/location enrichment
    dim_products  - current product attributes + ERP category enrichment
    dim_date      - role-playing date dimension
===============================================================================
*/
USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE gold.load_gold
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @batch_start DATETIME2 = SYSDATETIME();

    BEGIN TRY

        /* ---------------------------------------------------------------
           FACT must be cleared first because it references dimensions.
           --------------------------------------------------------------- */
        TRUNCATE TABLE gold.fact_sales;

        /* ---------------------------------------------------------------
           CUSTOMER DIMENSION
           CRM is the primary source for customer attributes.
           ERP supplies birthdate, gender fallback and country.
           --------------------------------------------------------------- */
        DELETE FROM gold.dim_customers;

        SET IDENTITY_INSERT gold.dim_customers ON;

        INSERT INTO gold.dim_customers
        (
            customer_key,
            customer_id,
            customer_number,
            first_name,
            last_name,
            country,
            marital_status,
            gender,
            birthdate,
            create_date
        )
        VALUES
        (
            0,
            -1,
            'UNKNOWN',
            'Unknown',
            'Unknown',
            'n/a',
            'n/a',
            'n/a',
            NULL,
            NULL
        );

        SET IDENTITY_INSERT gold.dim_customers OFF;

        INSERT INTO gold.dim_customers
        (
            customer_id,
            customer_number,
            first_name,
            last_name,
            country,
            marital_status,
            gender,
            birthdate,
            create_date
        )
        SELECT
            ci.cst_id,
            ci.cst_key,
            ci.cst_firstname,
            ci.cst_lastname,
            COALESCE(NULLIF(la.cntry, ''), 'n/a'),
            ci.cst_marital_status,
            CASE
                WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
                ELSE COALESCE(ca.gen, 'n/a')
            END,
            ca.bdate,
            ci.cst_create_date
        FROM silver.crm_cust_info ci
        LEFT JOIN silver.erp_cust_az12 ca
            ON ci.cst_key = ca.cid
        LEFT JOIN silver.erp_loc_a101 la
            ON ci.cst_key = la.cid;

        /* ---------------------------------------------------------------
           PRODUCT DIMENSION
           Current product version only, matching the original business
           requirement represented by the source project.
           --------------------------------------------------------------- */
        DELETE FROM gold.dim_products;

        SET IDENTITY_INSERT gold.dim_products ON;

        INSERT INTO gold.dim_products
        (
            product_key,
            product_id,
            product_number,
            product_name,
            category_id,
            category,
            subcategory,
            maintenance,
            cost,
            product_line,
            start_date
        )
        VALUES
        (
            0,
            -1,
            'UNKNOWN',
            'Unknown',
            'n/a',
            'n/a',
            'n/a',
            'n/a',
            0,
            'n/a',
            NULL
        );

        SET IDENTITY_INSERT gold.dim_products OFF;

        INSERT INTO gold.dim_products
        (
            product_id,
            product_number,
            product_name,
            category_id,
            category,
            subcategory,
            maintenance,
            cost,
            product_line,
            start_date
        )
        SELECT
            pn.prd_id,
            pn.prd_key,
            pn.prd_nm,
            pn.cat_id,
            COALESCE(pc.cat, 'n/a'),
            COALESCE(pc.subcat, 'n/a'),
            COALESCE(pc.maintenance, 'n/a'),
            pn.prd_cost,
            pn.prd_line,
            pn.prd_start_dt
        FROM silver.crm_prd_info pn
        LEFT JOIN silver.erp_px_cat_g1v2 pc
            ON pn.cat_id = pc.id
        WHERE pn.prd_end_dt IS NULL;

        /* ---------------------------------------------------------------
           DATE DIMENSION
           Rebuild the date dimension based on the fact date range.
           --------------------------------------------------------------- */
        DELETE FROM gold.dim_date;

        INSERT INTO gold.dim_date
        (
            date_key,
            full_date,
            day_number,
            day_name,
            week_number,
            month_number,
            month_name,
            quarter_number,
            year_number,
            is_weekend
        )
        VALUES
        (
            0, '1900-01-01', 0, 'Unknown', 0, 0, 'Unknown', 0, 0, 0
        );

        DECLARE
            @min_date DATE,
            @max_date DATE;

        SELECT
            @min_date = MIN(dt),
            @max_date = MAX(dt)
        FROM
        (
            SELECT sls_order_dt AS dt FROM silver.crm_sales_details WHERE sls_order_dt IS NOT NULL
            UNION ALL
            SELECT sls_ship_dt  FROM silver.crm_sales_details WHERE sls_ship_dt IS NOT NULL
            UNION ALL
            SELECT sls_due_dt   FROM silver.crm_sales_details WHERE sls_due_dt IS NOT NULL
        ) d;

        IF @min_date IS NOT NULL AND @max_date IS NOT NULL
        BEGIN
            ;WITH dates AS
            (
                SELECT @min_date AS full_date
                UNION ALL
                SELECT DATEADD(DAY, 1, full_date)
                FROM dates
                WHERE full_date < @max_date
            )
            INSERT INTO gold.dim_date
            (
                date_key,
                full_date,
                day_number,
                day_name,
                week_number,
                month_number,
                month_name,
                quarter_number,
                year_number,
                is_weekend
            )
            SELECT
                CONVERT(INT, CONVERT(CHAR(8), full_date, 112)),
                full_date,
                DAY(full_date),
                DATENAME(WEEKDAY, full_date),
                DATEPART(ISO_WEEK, full_date),
                MONTH(full_date),
                DATENAME(MONTH, full_date),
                DATEPART(QUARTER, full_date),
                YEAR(full_date),
                CASE
                    WHEN DATEPART(WEEKDAY, full_date) IN (1, 7) THEN 1
                    ELSE 0
                END
            FROM dates
            OPTION (MAXRECURSION 0);
        END;

        /* ---------------------------------------------------------------
           FACT SALES
           Unknown member key 0 preserves transactions when a lookup fails.
           --------------------------------------------------------------- */
        INSERT INTO gold.fact_sales
        (
            order_number,
            product_key,
            customer_key,
            order_date_key,
            ship_date_key,
            due_date_key,
            sales_amount,
            quantity,
            price
        )
        SELECT
            sd.sls_ord_num,
            COALESCE(p.product_key, 0),
            COALESCE(c.customer_key, 0),
            COALESCE(od.date_key, 0),
            COALESCE(sdte.date_key, 0),
            COALESCE(dd.date_key, 0),
            sd.sls_sales,
            sd.sls_quantity,
            sd.sls_price
        FROM silver.crm_sales_details sd
        LEFT JOIN gold.dim_products p
            ON sd.sls_prd_key = p.product_number
        LEFT JOIN gold.dim_customers c
            ON sd.sls_cust_id = c.customer_id
        LEFT JOIN gold.dim_date od
            ON sd.sls_order_dt = od.full_date
        LEFT JOIN gold.dim_date sdte
            ON sd.sls_ship_dt = sdte.full_date
        LEFT JOIN gold.dim_date dd
            ON sd.sls_due_dt = dd.full_date;

        PRINT CONCAT(
            'Gold load completed in ',
            DATEDIFF(SECOND, @batch_start, SYSDATETIME()),
            ' seconds.'
        );

    END TRY
    BEGIN CATCH
        IF OBJECTPROPERTY(OBJECT_ID('gold.dim_customers'), 'TableHasIdentity') = 1
           AND EXISTS
           (
               SELECT 1
               FROM sys.identity_columns
               WHERE object_id = OBJECT_ID('gold.dim_customers')
           )
        BEGIN
            BEGIN TRY
                SET IDENTITY_INSERT gold.dim_customers OFF;
            END TRY
            BEGIN CATCH
            END CATCH
        END;

        BEGIN TRY
            SET IDENTITY_INSERT gold.dim_products OFF;
        END TRY
        BEGIN CATCH
        END CATCH;

        PRINT '================================================';
        PRINT 'ERROR DURING GOLD LOAD';
        PRINT CONCAT('Error Number : ', ERROR_NUMBER());
        PRINT CONCAT('Error Line   : ', ERROR_LINE());
        PRINT CONCAT('Error Message: ', ERROR_MESSAGE());
        PRINT '================================================';
        THROW;
    END CATCH
END;
GO

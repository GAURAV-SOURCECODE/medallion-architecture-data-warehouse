/*
===============================================================================
Silver DDL
Purpose:
    Cleaned and standardized tables derived from Bronze.

Silver transformations include:
    - trimming
    - standardization
    - deduplication
    - date conversion
    - derived category keys
    - validation / repair of sales metrics
    - source integration preparation
===============================================================================
*/
USE DataWarehouse;
GO

DROP TABLE IF EXISTS silver.crm_cust_info;
DROP TABLE IF EXISTS silver.crm_prd_info;
DROP TABLE IF EXISTS silver.crm_sales_details;
DROP TABLE IF EXISTS silver.erp_loc_a101;
DROP TABLE IF EXISTS silver.erp_cust_az12;
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.crm_cust_info
(
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_create_date    DATE,
    dwh_create_date    DATETIME2(0) NOT NULL
        CONSTRAINT df_silver_crm_cust_load DEFAULT SYSDATETIME()
);
GO

CREATE TABLE silver.crm_prd_info
(
    prd_id          INT,
    cat_id          NVARCHAR(50),
    prd_key         NVARCHAR(50),
    prd_nm          NVARCHAR(100),
    prd_cost        INT,
    prd_line        NVARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date DATETIME2(0) NOT NULL
        CONSTRAINT df_silver_crm_prd_load DEFAULT SYSDATETIME()
);
GO

CREATE TABLE silver.crm_sales_details
(
    sls_ord_num     NVARCHAR(50),
    sls_prd_key     NVARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       INT,
    sls_quantity    INT,
    sls_price       INT,
    dwh_create_date DATETIME2(0) NOT NULL
        CONSTRAINT df_silver_crm_sales_load DEFAULT SYSDATETIME()
);
GO

CREATE TABLE silver.erp_loc_a101
(
    cid             NVARCHAR(50),
    cntry           NVARCHAR(100),
    dwh_create_date DATETIME2(0) NOT NULL
        CONSTRAINT df_silver_erp_loc_load DEFAULT SYSDATETIME()
);
GO

CREATE TABLE silver.erp_cust_az12
(
    cid             NVARCHAR(50),
    bdate           DATE,
    gen             NVARCHAR(50),
    dwh_create_date DATETIME2(0) NOT NULL
        CONSTRAINT df_silver_erp_cust_load DEFAULT SYSDATETIME()
);
GO

CREATE TABLE silver.erp_px_cat_g1v2
(
    id              NVARCHAR(50),
    cat             NVARCHAR(100),
    subcat          NVARCHAR(100),
    maintenance     NVARCHAR(50),
    dwh_create_date DATETIME2(0) NOT NULL
        CONSTRAINT df_silver_erp_cat_load DEFAULT SYSDATETIME()
);
GO

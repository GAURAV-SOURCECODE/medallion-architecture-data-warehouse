USE DataWarehouse;
GO

SELECT 'bronze.crm_cust_info' AS object_name, COUNT_BIG(*) AS row_count FROM bronze.crm_cust_info
UNION ALL SELECT 'bronze.crm_prd_info', COUNT_BIG(*) FROM bronze.crm_prd_info
UNION ALL SELECT 'bronze.crm_sales_details', COUNT_BIG(*) FROM bronze.crm_sales_details
UNION ALL SELECT 'bronze.erp_cust_az12', COUNT_BIG(*) FROM bronze.erp_cust_az12
UNION ALL SELECT 'bronze.erp_loc_a101', COUNT_BIG(*) FROM bronze.erp_loc_a101
UNION ALL SELECT 'bronze.erp_px_cat_g1v2', COUNT_BIG(*) FROM bronze.erp_px_cat_g1v2
UNION ALL SELECT 'silver.crm_cust_info', COUNT_BIG(*) FROM silver.crm_cust_info
UNION ALL SELECT 'silver.crm_prd_info', COUNT_BIG(*) FROM silver.crm_prd_info
UNION ALL SELECT 'silver.crm_sales_details', COUNT_BIG(*) FROM silver.crm_sales_details
UNION ALL SELECT 'gold.dim_customers', COUNT_BIG(*) FROM gold.dim_customers
UNION ALL SELECT 'gold.dim_products', COUNT_BIG(*) FROM gold.dim_products
UNION ALL SELECT 'gold.dim_date', COUNT_BIG(*) FROM gold.dim_date
UNION ALL SELECT 'gold.fact_sales', COUNT_BIG(*) FROM gold.fact_sales;
GO

SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM gold.fact_sales) > 0
         AND (SELECT COUNT(*) FROM gold.dim_customers) > 0
         AND (SELECT COUNT(*) FROM gold.dim_products) > 0
         AND (SELECT COUNT(*) FROM gold.dim_date) > 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS smoke_test_status;
GO

/*
===============================================================================
Silver Data Quality Checks
Expectation:
    Each query should return zero rows unless the comment says otherwise.
===============================================================================
*/
USE DataWarehouse;
GO

/* Customer: null/duplicate business key */
SELECT cst_id, COUNT(*) AS row_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING cst_id IS NULL OR COUNT(*) > 1;
GO

/* Customer: unwanted spaces */
SELECT *
FROM silver.crm_cust_info
WHERE cst_key <> TRIM(cst_key)
   OR cst_firstname <> TRIM(cst_firstname)
   OR cst_lastname <> TRIM(cst_lastname);
GO

/* Customer: standardization */
SELECT DISTINCT cst_marital_status, cst_gndr
FROM silver.crm_cust_info
ORDER BY cst_marital_status, cst_gndr;
GO

/* Product: null/duplicate ID */
SELECT prd_id, COUNT(*) AS row_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING prd_id IS NULL OR COUNT(*) > 1;
GO

/* Product: negative cost */
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
GO

/* Product: invalid date window */
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
GO

/* Sales: invalid date ordering */
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;
GO

/* Sales: repaired metric consistency */
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
   OR sls_sales <> sls_quantity * sls_price;
GO

/* ERP customer: future birthdate */
SELECT *
FROM silver.erp_cust_az12
WHERE bdate > CAST(GETDATE() AS DATE);
GO

/* ERP location: normalized values */
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;
GO

/* ERP category: unwanted spaces */
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE id <> TRIM(id)
   OR cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);
GO

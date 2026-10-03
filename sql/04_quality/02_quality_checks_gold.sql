/*
===============================================================================
Gold Data Quality Checks
Expectation:
    Integrity checks should return zero rows.
===============================================================================
*/
USE DataWarehouse;
GO

/* Dimension: customer surrogate key uniqueness */
SELECT customer_key, COUNT(*) AS row_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;
GO

/* Dimension: customer business key uniqueness */
SELECT customer_id, COUNT(*) AS row_count
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
GO

/* Dimension: product surrogate key uniqueness */
SELECT product_key, COUNT(*) AS row_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;
GO

/* Dimension: product business key uniqueness */
SELECT product_number, COUNT(*) AS row_count
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;
GO

/* Fact: orphan dimensions should not exist */
SELECT *
FROM gold.fact_sales
WHERE product_key NOT IN (SELECT product_key FROM gold.dim_products)
   OR customer_key NOT IN (SELECT customer_key FROM gold.dim_customers)
   OR order_date_key NOT IN (SELECT date_key FROM gold.dim_date)
   OR ship_date_key NOT IN (SELECT date_key FROM gold.dim_date)
   OR due_date_key NOT IN (SELECT date_key FROM gold.dim_date);
GO

/* Fact: business calculation */
SELECT *
FROM gold.fact_sales
WHERE sales_amount IS NULL
   OR quantity IS NULL
   OR price IS NULL
   OR sales_amount <> quantity * price;
GO

/* Fact: valid date ordering */
SELECT *
FROM gold.fact_sales
WHERE order_date_key > ship_date_key
   OR order_date_key > due_date_key;
GO

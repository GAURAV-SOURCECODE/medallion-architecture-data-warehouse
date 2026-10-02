/*
===============================================================================
Business Analysis Examples
===============================================================================
*/
USE DataWarehouse;
GO

/* 1. Total sales, quantity and average selling price */
SELECT
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    CAST(SUM(sales_amount) * 1.0 / NULLIF(SUM(quantity), 0) AS DECIMAL(18,2))
        AS weighted_average_price
FROM gold.fact_sales
WHERE product_key <> 0;
GO

/* 2. Sales by year */
SELECT
    d.year_number,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity
FROM gold.fact_sales f
JOIN gold.dim_date d
    ON f.order_date_key = d.date_key
GROUP BY d.year_number
ORDER BY d.year_number;
GO

/* 3. Top 10 products by sales */
SELECT TOP (10)
    p.product_number,
    p.product_name,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity
FROM gold.fact_sales f
JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_number,
    p.product_name
ORDER BY total_sales DESC;
GO

/* 4. Top 10 customers by sales */
SELECT TOP (10)
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity
FROM gold.fact_sales f
JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_number,
    c.first_name,
    c.last_name,
    c.country
ORDER BY total_sales DESC;
GO

/* 5. Monthly sales trend */
SELECT
    d.year_number,
    d.month_number,
    d.month_name,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_date d
    ON f.order_date_key = d.date_key
GROUP BY
    d.year_number,
    d.month_number,
    d.month_name
ORDER BY
    d.year_number,
    d.month_number;
GO

/* 6. Sales by product category */
SELECT
    p.category,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity
FROM gold.fact_sales f
JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;
GO

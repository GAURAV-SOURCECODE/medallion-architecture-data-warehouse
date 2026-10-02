/*
Product performance using the Gold star schema.
*/
USE DataWarehouse;
GO

SELECT
    p.category,
    p.subcategory,
    p.product_name,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS units_sold,
    AVG(CAST(f.price AS DECIMAL(18,2))) AS average_price,
    SUM(f.sales_amount - (p.cost * f.quantity)) AS estimated_gross_margin
FROM gold.fact_sales f
JOIN gold.dim_products p
    ON f.product_key = p.product_key
WHERE p.product_key <> 0
GROUP BY
    p.category,
    p.subcategory,
    p.product_name
ORDER BY total_sales DESC;
GO

/*
Customer segmentation example using sales behavior.
*/
USE DataWarehouse;
GO

WITH customer_sales AS
(
    SELECT
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(f.sales_amount) AS total_sales,
        COUNT(DISTINCT f.order_number) AS order_count
    FROM gold.fact_sales f
    JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    WHERE c.customer_key <> 0
    GROUP BY
        c.customer_key,
        c.customer_number,
        c.first_name,
        c.last_name
)
SELECT
    customer_number,
    customer_name,
    total_sales,
    order_count,
    CASE
        WHEN total_sales >= 10000 AND order_count >= 5 THEN 'High Value'
        WHEN total_sales >= 5000 OR order_count >= 3 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_sales
ORDER BY total_sales DESC;
GO

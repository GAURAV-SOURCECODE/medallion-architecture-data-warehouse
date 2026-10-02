# Power BI Model

## Recommended Relationships

Use single-direction relationships from dimensions to fact:

```text
dim_customers[customer_key]  1 ─── * fact_sales[customer_key]

dim_products[product_key]    1 ─── * fact_sales[product_key]

dim_date[date_key]           1 ─── * fact_sales[order_date_key]
```

For shipping and due dates, either:

- use inactive relationships and `USERELATIONSHIP()` in DAX, or
- duplicate the date dimension as role-specific dimensions.

## Core Measures

```DAX
Total Sales =
SUM(fact_sales[sales_amount])

Total Quantity =
SUM(fact_sales[quantity])

Order Count =
DISTINCTCOUNT(fact_sales[order_number])

Average Selling Price =
DIVIDE([Total Sales], [Total Quantity])

Gross Margin =
SUMX(
    fact_sales,
    fact_sales[sales_amount]
        - RELATED(dim_products[cost]) * fact_sales[quantity]
)
```

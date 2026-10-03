# Power BI

The Gold layer is designed to be the Power BI semantic-model source.

Recommended model:

```text
dim_customers ─┐
dim_products  ─┼──> fact_sales <── dim_date
               │
               └── Date roles:
                   Order Date
                   Ship Date
                   Due Date
```

Suggested report pages:

1. Executive Sales Overview
2. Sales Trend
3. Product Performance
4. Customer Performance
5. Geographic Analysis

Suggested measures:

- Total Sales
- Total Quantity
- Average Selling Price
- Number of Orders
- Sales YoY
- Sales MoM
- Gross Margin
- Gross Margin %

# SQL Server Sales Data Warehouse

Portfolio data warehouse project built with **SQL Server + T-SQL**.

> **CRM/ERP CSV → Bronze → Silver → Gold Star Schema → Analytics / Power BI**

See [`docs/README.md`](docs/README.md) for the complete project documentation.

## Quick Start

1. Run `sql/00_init/01_init_database.sql`
2. Run Bronze, Silver and Gold DDL scripts.
3. Run the three load-procedure scripts.
4. Execute:

```sql
EXEC bronze.load_bronze
     @data_root = N'C:\path\to\sql-server-sales-datawarehouse';

EXEC silver.load_silver;
EXEC gold.load_gold;
```

5. Run the quality checks under `sql/04_quality/`.
6. Explore the analytical queries under `sql/05_analytics/`.

## Core Model

- `gold.dim_customers`
- `gold.dim_products`
- `gold.dim_date`
- `gold.fact_sales`

**Fact grain:** one row per product line within a sales order.

## Technologies

- SQL Server
- T-SQL
- BULK INSERT
- Stored Procedures
- CTEs
- Window Functions
- Dimensional Modeling
- Data Quality Checks

## Repository

```text
datasets/     Source CSV files
sql/          DDL, ETL, tests and analytics
docs/         Architecture and data-model documentation
tests/        Additional validation scripts
powerbi/      Power BI documentation / assets
```

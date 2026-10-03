# SQL Server Sales Data Warehouse

A portfolio-ready **SQL Server Data Warehouse** project that integrates CRM and ERP CSV sources into a three-layer architecture:

**Bronze → Silver → Gold**

The project demonstrates source ingestion, data cleansing, standardization, integration, dimensional modeling, data quality validation and analytical SQL.

---

## Business Problem

The source data is split across two operational systems:

### CRM
- Customer master data
- Product master/history
- Sales transactions

### ERP
- Customer demographic data
- Customer country/location
- Product category information

The goal is to create a unified analytical model that answers questions such as:

- How much did we sell?
- Which products generate the most revenue?
- Which customers generate the most revenue?
- How are sales trending by month/year?
- Which product categories perform best?
- How many units are sold?
- What is the estimated gross margin?

---

## Architecture

```text
CRM CSV ─────┐
             ├──> BRONZE ──> SILVER ──> GOLD ──> BI / SQL Analytics
ERP CSV ─────┘
```

### Bronze

Raw source representation.

- No business transformations
- Source-oriented table names
- Full refresh
- CSV ingestion using `BULK INSERT`

### Silver

Cleaned and standardized data.

- Trimming
- Deduplication
- Code-to-description mappings
- Date conversion
- Data validation
- Sales metric repair
- Customer/product integration preparation

### Gold

Business-ready dimensional model.

- `gold.dim_customers`
- `gold.dim_products`
- `gold.dim_date`
- `gold.fact_sales`

---

## Star Schema

```text
                    ┌──────────────────┐
                    │   dim_customers  │
                    │------------------│
                    │ customer_key PK  │
                    │ customer_id      │
                    │ customer_number  │
                    │ demographics     │
                    └────────┬─────────┘
                             │
                             │
┌──────────────────┐         │         ┌──────────────────┐
│    dim_date      │         │         │   dim_products   │
│------------------│         │         │------------------│
│ date_key PK      │         │         │ product_key PK   │
│ full_date        │         │         │ product_number   │
│ month/year       │         │         │ category         │
└────────┬─────────┘         │         │ subcategory      │
         │                   │         └────────┬─────────┘
         │                   │                  │
         └───────────────────┼──────────────────┘
                             │
                     ┌───────▼────────┐
                     │   fact_sales   │
                     │----------------│
                     │ sales_key PK   │
                     │ product_key FK │
                     │ customer_key FK│
                     │ date keys      │
                     │ sales_amount   │
                     │ quantity       │
                     │ price          │
                     └────────────────┘
```

---

## Fact Grain

**One row in `gold.fact_sales` represents one product line within one sales order.**

This grain is important for all downstream aggregation and BI calculations.

---

## Key Design Decisions

### Surrogate keys

Gold dimensions use integer surrogate keys.

Key `0` is reserved for the **Unknown** member so that fact rows are not lost when a dimension lookup is unavailable.

### Date dimension

A role-playing date dimension supports:

- order date
- shipping date
- due date

### Product history

Silver derives product validity windows from product start dates. Gold intentionally exposes the **current product version** because that matches the business-ready model represented by the original project.

### SCD scope

The current project is a **full-refresh dimensional model**, not a persistent SCD Type 2 implementation.

Customer history is reduced to the latest CRM record in Silver.

---

## Repository Structure

```text
medallion-architecture-data-warehouse/
│
├── datasets/
│   ├── source_crm/
│   └── source_erp/
│
├── sql/
│   ├── 00_init/
│   ├── 01_bronze/
│   ├── 02_silver/
│   ├── 03_gold/
│   ├── 04_quality/
│   └── 05_analytics/
│
├── docs/
├── tests/
└── powerbi/
```

---

## Requirements

- SQL Server 2017+
- SQL Server Management Studio (SSMS) or Azure Data Studio
- Access for the SQL Server service account to read the CSV directory

The project uses SQL Server features including:

- `BULK INSERT`
- stored procedures
- CTEs
- window functions
- `TRY_CONVERT`
- `IDENTITY`
- foreign keys
- indexes

---

## How to Run

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd medallion-architecture-data-warehouse
```

### 2. Initialize the database

Run:

```text
sql/00_init/01_init_database.sql
```

> This script drops and recreates `DataWarehouse`. Use only for development.

### 3. Create Bronze tables

Run:

```text
sql/01_bronze/01_ddl_bronze.sql
```

### 4. Create Silver tables

Run:

```text
sql/02_silver/01_ddl_silver.sql
```

### 5. Create Gold tables

Run:

```text
sql/03_gold/01_ddl_gold.sql
```

### 6. Create stored procedures

Run:

```text
sql/01_bronze/02_proc_load_bronze.sql
sql/02_silver/02_proc_load_silver.sql
sql/03_gold/02_proc_load_gold.sql
```

### 7. Load Bronze

Replace the path with the local repository location:

```sql
EXEC bronze.load_bronze
     @data_root = N'C:\path\to\medallion-architecture-data-warehouse';
```

### 8. Load Silver

```sql
EXEC silver.load_silver;
```

### 9. Load Gold

```sql
EXEC gold.load_gold;
```

### 10. Run quality checks

Run:

```text
sql/04_quality/01_quality_checks_silver.sql
sql/04_quality/02_quality_checks_gold.sql
```

### 11. Run analytics

Start with:

```text
sql/05_analytics/01_sales_kpis.sql
```

---

## Source Data

The repository contains six CSV files supplied with the project:

| Source | File | Approx. rows |
|---|---|---:|
| CRM | `cust_info.csv` | 18,494 |
| CRM | `prd_info.csv` | 397 |
| CRM | `sales_details.csv` | 60,398 |
| ERP | `cust_az12.csv` | 18,484 |
| ERP | `loc_a101.csv` | 18,484 |
| ERP | `px_cat_g1v2.csv` | 37 |

The source data contains realistic data-quality conditions such as duplicate customer records, malformed date values, missing product cost and invalid sales metrics. The Silver layer is designed to address these conditions.

---

## Data Quality

Checks are provided for:

- null and duplicate business keys
- unwanted whitespace
- standardization
- invalid dates
- invalid date ordering
- invalid sales calculations
- negative/missing costs
- future birthdates
- dimension uniqueness
- fact-to-dimension integrity

---

## Analytics Examples

The project includes SQL for:

- total sales
- units sold
- sales by year
- monthly sales trend
- top products
- top customers
- category performance
- customer segmentation
- estimated gross margin

---

## Portfolio / Interview Talking Points

This project demonstrates:

1. ETL architecture
2. SQL Server data warehousing
3. Bronze/Silver/Gold layering
4. Data cleansing
5. Data standardization
6. Deduplication with `ROW_NUMBER()`
7. Window functions with `LEAD()`
8. Multi-source integration
9. Dimensional modeling
10. Fact table grain definition
11. Surrogate keys
12. Date dimension
13. Referential integrity
14. Data-quality testing
15. Analytical SQL

---

## Future Enhancements

Possible next iterations:

- incremental loading
- SCD Type 2 customer dimension
- ETL audit logging
- SQL Agent scheduling
- Power BI semantic model
- automated test reporting
- CI/CD deployment through GitHub Actions or Azure DevOps

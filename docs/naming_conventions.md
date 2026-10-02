# Naming Conventions

## General

- lowercase
- snake_case
- English names
- avoid reserved words

## Bronze / Silver

Keep source-system names:

```text
<sourcesystem>_<entity>
```

Examples:

```text
crm_cust_info
crm_prd_info
erp_cust_az12
```

## Gold

Use business-aligned dimensional names:

```text
dim_<entity>
fact_<entity>
agg_<entity>
```

Examples:

```text
dim_customers
dim_products
dim_date
fact_sales
```

## Keys

Surrogate keys use:

```text
<entity>_key
```

Examples:

```text
customer_key
product_key
date_key
```

## Technical columns

Use:

```text
dwh_<description>
```

Examples:

```text
dwh_load_date
dwh_create_date
```

## Stored Procedures

Use:

```text
load_<layer>
```

Examples:

```text
bronze.load_bronze
silver.load_silver
gold.load_gold

# Data Model

## Gold Star Schema

### `gold.dim_customers`

Customer dimension enriched from CRM + ERP.

**Primary key:** `customer_key`

| Column | Meaning |
|---|---|
| customer_key | Warehouse surrogate key |
| customer_id | CRM customer business identifier |
| customer_number | CRM customer number |
| first_name | Customer first name |
| last_name | Customer last name |
| country | ERP customer country |
| marital_status | Standardized marital status |
| gender | CRM gender with ERP fallback |
| birthdate | ERP birthdate |
| create_date | CRM customer creation date |

### `gold.dim_products`

Current product dimension enriched from CRM + ERP.

**Primary key:** `product_key`

| Column | Meaning |
|---|---|
| product_key | Warehouse surrogate key |
| product_id | CRM product identifier |
| product_number | Product business key |
| product_name | Product description |
| category_id | Derived category identifier |
| category | ERP category |
| subcategory | ERP subcategory |
| maintenance | ERP maintenance flag |
| cost | Product cost |
| product_line | Standardized product line |
| start_date | Product start date |

### `gold.dim_date`

Calendar dimension used for all fact dates.

**Primary key:** `date_key`

The fact uses the same date dimension in three roles:

- order date
- shipping date
- due date

### `gold.fact_sales`

**Grain:** one product line within one sales order.

| Column | Meaning |
|---|---|
| sales_key | Warehouse fact-row identifier |
| order_number | Source sales order number |
| product_key | Product dimension FK |
| customer_key | Customer dimension FK |
| order_date_key | Order date FK |
| ship_date_key | Shipping date FK |
| due_date_key | Due date FK |
| sales_amount | Sales value |
| quantity | Units sold |
| price | Unit selling price |

## Relationships

```text
dim_customers 1 ──────── * fact_sales
dim_products  1 ──────── * fact_sales
dim_date      1 ──────── * fact_sales  (order)
dim_date      1 ──────── * fact_sales  (ship)
dim_date      1 ──────── * fact_sales  (due)
```

## Unknown Member

Dimensions contain key `0` as an Unknown member.

This allows a fact row to remain queryable even when its source business key cannot be matched to a dimension.

# Data Dictionary

## Source-to-Silver-to-Gold Mapping

### Customer

| Source | Silver | Gold |
|---|---|---|
| crm.cst_id | cst_id | customer_id |
| crm.cst_key | cst_key | customer_number |
| crm.cst_firstname | cst_firstname | first_name |
| crm.cst_lastname | cst_lastname | last_name |
| crm.cst_marital_status | cst_marital_status | marital_status |
| crm.cst_gndr | cst_gndr | gender |
| ERP BDATE | bdate | birthdate |
| ERP CNTRY | cntry | country |

### Product

| Source | Silver | Gold |
|---|---|---|
| prd_id | prd_id | product_id |
| prd_key | prd_key | product_number |
| prd_nm | prd_nm | product_name |
| derived from prd_key | cat_id | category_id |
| ERP CAT | cat | category |
| ERP SUBCAT | subcat | subcategory |
| ERP MAINTENANCE | maintenance | maintenance |
| prd_cost | prd_cost | cost |
| prd_line | prd_line | product_line |

### Sales

| Source | Silver | Gold |
|---|---|---|
| sls_ord_num | sls_ord_num | order_number |
| sls_prd_key | sls_prd_key | product_key lookup |
| sls_cust_id | sls_cust_id | customer_key lookup |
| sls_order_dt | sls_order_dt | order_date_key |
| sls_ship_dt | sls_ship_dt | ship_date_key |
| sls_due_dt | sls_due_dt | due_date_key |
| sls_sales | sls_sales | sales_amount |
| sls_quantity | sls_quantity | quantity |
| sls_price | sls_price | price |

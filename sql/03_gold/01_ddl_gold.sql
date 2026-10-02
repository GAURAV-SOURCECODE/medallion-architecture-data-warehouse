/*
===============================================================================
Gold DDL
Purpose:
    Physical dimensional model for analytics.

Model:
    dim_customers
    dim_products
    dim_date
    fact_sales

Design:
    - Dimensions use integer surrogate keys.
    - Key 0 is the Unknown member.
    - Fact rows can therefore retain source transactions even when a dimension
      lookup is unavailable.
    - Gold is loaded by sql/03_gold/02_proc_load_gold.sql.
===============================================================================
*/
USE DataWarehouse;
GO

DROP TABLE IF EXISTS gold.fact_sales;
DROP TABLE IF EXISTS gold.dim_date;
DROP TABLE IF EXISTS gold.dim_products;
DROP TABLE IF EXISTS gold.dim_customers;
GO

CREATE TABLE gold.dim_customers
(
    customer_key    INT IDENTITY(1,1) NOT NULL,
    customer_id     INT NOT NULL,
    customer_number NVARCHAR(50) NOT NULL,
    first_name      NVARCHAR(50),
    last_name       NVARCHAR(50),
    country         NVARCHAR(100),
    marital_status  NVARCHAR(50),
    gender          NVARCHAR(50),
    birthdate       DATE,
    create_date     DATE,
    dwh_load_date   DATETIME2(0) NOT NULL
        CONSTRAINT df_gold_dim_customers_load DEFAULT SYSDATETIME(),

    CONSTRAINT pk_gold_dim_customers PRIMARY KEY (customer_key),
    CONSTRAINT uq_gold_dim_customers_customer_id UNIQUE (customer_id),
    CONSTRAINT uq_gold_dim_customers_customer_number UNIQUE (customer_number)
);
GO

CREATE TABLE gold.dim_products
(
    product_key     INT IDENTITY(1,1) NOT NULL,
    product_id      INT NOT NULL,
    product_number  NVARCHAR(50) NOT NULL,
    product_name    NVARCHAR(100),
    category_id     NVARCHAR(50),
    category        NVARCHAR(100),
    subcategory     NVARCHAR(100),
    maintenance     NVARCHAR(50),
    cost            INT,
    product_line    NVARCHAR(50),
    start_date      DATE,
    dwh_load_date   DATETIME2(0) NOT NULL
        CONSTRAINT df_gold_dim_products_load DEFAULT SYSDATETIME(),

    CONSTRAINT pk_gold_dim_products PRIMARY KEY (product_key),
    CONSTRAINT uq_gold_dim_products_product_id UNIQUE (product_id),
    CONSTRAINT uq_gold_dim_products_product_number UNIQUE (product_number)
);
GO

CREATE TABLE gold.dim_date
(
    date_key      INT NOT NULL,
    full_date     DATE NOT NULL,
    day_number    TINYINT NOT NULL,
    day_name      VARCHAR(10) NOT NULL,
    week_number   TINYINT NOT NULL,
    month_number  TINYINT NOT NULL,
    month_name    VARCHAR(10) NOT NULL,
    quarter_number TINYINT NOT NULL,
    year_number   SMALLINT NOT NULL,
    is_weekend    BIT NOT NULL,

    CONSTRAINT pk_gold_dim_date PRIMARY KEY (date_key),
    CONSTRAINT uq_gold_dim_date_full_date UNIQUE (full_date)
);
GO

CREATE TABLE gold.fact_sales
(
    sales_key      BIGINT IDENTITY(1,1) NOT NULL,
    order_number   NVARCHAR(50) NOT NULL,
    product_key    INT NOT NULL,
    customer_key   INT NOT NULL,
    order_date_key INT NOT NULL,
    ship_date_key  INT NOT NULL,
    due_date_key   INT NOT NULL,
    sales_amount   INT,
    quantity       INT,
    price          INT,
    dwh_load_date  DATETIME2(0) NOT NULL
        CONSTRAINT df_gold_fact_sales_load DEFAULT SYSDATETIME(),

    CONSTRAINT pk_gold_fact_sales PRIMARY KEY (sales_key),
    CONSTRAINT fk_gold_fact_sales_customer
        FOREIGN KEY (customer_key) REFERENCES gold.dim_customers(customer_key),
    CONSTRAINT fk_gold_fact_sales_product
        FOREIGN KEY (product_key) REFERENCES gold.dim_products(product_key),
    CONSTRAINT fk_gold_fact_sales_order_date
        FOREIGN KEY (order_date_key) REFERENCES gold.dim_date(date_key),
    CONSTRAINT fk_gold_fact_sales_ship_date
        FOREIGN KEY (ship_date_key) REFERENCES gold.dim_date(date_key),
    CONSTRAINT fk_gold_fact_sales_due_date
        FOREIGN KEY (due_date_key) REFERENCES gold.dim_date(date_key)
);
GO

CREATE INDEX ix_gold_fact_sales_order_date
    ON gold.fact_sales(order_date_key);
GO

CREATE INDEX ix_gold_fact_sales_customer
    ON gold.fact_sales(customer_key);
GO

CREATE INDEX ix_gold_fact_sales_product
    ON gold.fact_sales(product_key);
GO

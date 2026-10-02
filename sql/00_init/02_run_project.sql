/*
===============================================================================
ONE-TIME / FULL REFRESH EXECUTION ORDER

1. Run 01_init_database.sql
2. Run Bronze DDL
3. Run Silver DDL
4. Run Gold DDL
5. Run Bronze load
6. Run Silver load
7. Run Gold load
8. Run quality checks

Example Bronze execution:
    EXEC bronze.load_bronze
         @data_root = N'C:\path\to\sql-server-sales-datawarehouse';

Then:
    EXEC silver.load_silver;
    EXEC gold.load_gold;
===============================================================================
*/

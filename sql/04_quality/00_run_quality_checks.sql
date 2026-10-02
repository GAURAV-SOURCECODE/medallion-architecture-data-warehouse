/*
===============================================================================
Quality Check Run Order
===============================================================================

Run:
    1. 01_quality_checks_silver.sql
    2. 02_quality_checks_gold.sql

These scripts intentionally return diagnostic rows instead of raising SQL
exceptions. A returned row indicates an item that should be investigated.
===============================================================================
*/
USE DataWarehouse;
GO

PRINT 'Run: sql/04_quality/01_quality_checks_silver.sql';
PRINT 'Then: sql/04_quality/02_quality_checks_gold.sql';
GO

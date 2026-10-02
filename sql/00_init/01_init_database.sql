/*
===============================================================================
Project: SQL Server Sales Data Warehouse
Script : Initialize database and schemas
===============================================================================

WARNING:
    This script DROPS and recreates the DataWarehouse database.

Use only for a local development / portfolio environment.
===============================================================================
*/
USE master;
GO

IF DB_ID(N'DataWarehouse') IS NOT NULL
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

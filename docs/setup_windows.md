# Windows / SQL Server Setup

## 1. Repository path

Example:

```text
C:\projects\sql-server-sales-datawarehouse
```

The important requirement is that SQL Server can read:

```text
C:\projects\sql-server-sales-datawarehouse\datasets\
```

## 2. SQL Server permissions

`BULK INSERT` reads files from the SQL Server host using the SQL Server service security context.

If the load fails with an operating-system permission error:

1. Confirm the path exists on the SQL Server host.
2. Grant the SQL Server service account read permission on the repository's `datasets` folder.
3. Re-run the Bronze procedure.

## 3. Run Bronze

```sql
EXEC bronze.load_bronze
     @data_root = N'C:\projects\sql-server-sales-datawarehouse';
```

Do not include `\datasets` in `@data_root`; the procedure appends that folder itself.

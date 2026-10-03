# ETL Design

## Extraction

Source files are CSVs from two conceptual operational systems:

- CRM
- ERP

Bronze uses SQL Server `BULK INSERT`.

The Bronze load accepts a repository root parameter instead of hardcoding a machine-specific path.

## Transformation

### Customer

- Remove unwanted whitespace
- Keep latest customer row by `cst_id`
- Standardize marital status
- Standardize gender

### Product

- Derive category ID
- Derive product number
- Replace missing cost with zero
- Standardize product line
- Calculate product validity end dates using `LEAD()`

### Sales

- Convert integer `YYYYMMDD` dates
- Use `TRY_CONVERT`
- Repair inconsistent sales values
- Derive missing/invalid unit prices when possible
- Preserve rows where the source data cannot be fully repaired

### ERP Customer

- Remove `NAS` customer ID prefix
- Null future birthdates
- Standardize gender

### ERP Location

- Remove hyphens from customer IDs
- Standardize country codes

### ERP Product Category

- Trim category attributes
- Standardize maintenance values

## Loading

The project currently uses **full refresh** loading:

```text
Bronze TRUNCATE + INSERT
        ↓
Silver TRUNCATE + INSERT
        ↓
Gold dimension/fact rebuild
```

This is intentional for a portfolio project because it makes the ETL deterministic and easy to reproduce.

## Error Handling

Stored procedures use:

- `TRY...CATCH`
- `XACT_ABORT`
- `THROW`

so orchestration tools can detect load failures.

## Why not claim SCD Type 2?

The current implementation is a full-refresh model. Customer records are reduced to the latest CRM record in Silver, while Gold exposes current product attributes.

A future version can implement persistent SCD Type 2 history.

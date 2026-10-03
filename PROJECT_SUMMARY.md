# Project Summary

## Title

**SQL Server Sales Data Warehouse — CRM + ERP Integration**

## Objective

Build a reproducible SQL Server warehouse that transforms raw CRM and ERP CSV files into a business-ready star schema for sales analytics.

## Technical Highlights

- SQL Server / T-SQL
- Bronze / Silver / Gold architecture
- `BULK INSERT` ingestion
- Stored-procedure ETL
- `ROW_NUMBER()` deduplication
- `LEAD()` for product validity windows
- Safe date conversion with `TRY_CONVERT`
- Multi-source customer enrichment
- Surrogate-key dimensions
- Unknown-member handling
- Role-playing date dimension
- Fact table grain definition
- Foreign keys and indexes
- Data-quality validation
- Analytical SQL

## Interview Story

> I built a SQL Server sales data warehouse from CRM and ERP CSV sources. I used a Bronze layer for raw ingestion, a Silver layer for cleansing, standardization and integration, and a Gold layer implementing a physical star schema. I defined the fact grain as one product line per sales order, introduced surrogate keys and an Unknown member, created a role-playing date dimension, and added data-quality checks for key integrity, date validity and sales calculations.

## Important Scope Statement

The current implementation is a **full-refresh batch warehouse**. It does not claim persistent SCD Type 2 history or incremental CDC processing.

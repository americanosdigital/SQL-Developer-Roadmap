
/*
================================================================================
SQL DEVELOPER ROADMAP
MODULE 04 - SQL SERVER PERFORMANCE AND OPTIMIZATION
Database: SQLRoadmapTrainingDB | Lessons 29 to 36
================================================================================
OBJECTIVES
- Measure query performance.
- Read and understand execution plans.
- Understand Table Scan, Index Scan, and Index Seek.
- Create and analyze indexes.
- Use composite indexes and INCLUDE columns.
- Understand SQL Server statistics.
- Write SARGable filters.
- Identify opportunities to optimize inefficient queries.

INSTRUCTIONS
1. Complete Modules 01, 02, and 03 before starting this module.
2. Open this file in SQL Server Management Studio (SSMS).
3. Execute one lesson at a time.
4. Compare results before and after improvements.
5. Do not create indexes without analyzing queries and execution plans.
6. Creating indexes changes database structures, but does not modify data.

NOTE
The training database may contain only a small number of rows. In that case,
SQL Server may choose a Table Scan instead of using an index. This is expected.
================================================================================
*/

USE SQLRoadmapTrainingDB;
GO

IF OBJECT_ID(N'dbo.Products', N'U') IS NULL
    THROW 52000, N'dbo.Products was not found. Run Module 01 first.', 1;
GO

/*
================================================================================
LESSON 29 - MEASURING QUERY PERFORMANCE
================================================================================
Concepts:
- CPU time: processing time used by the CPU.
- Elapsed time: total time that has passed.
- Logical reads: pages read from SQL Server memory/cache.
- Physical reads: pages read from storage.

In SSMS:
1. Execute the query.
2. Open the Messages tab.
3. Compare STATISTICS IO and STATISTICS TIME results.
*/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    ProductId,
    ProductName,
    Price,
    StockQuantity
FROM dbo.Products
WHERE Price >= 100.00
ORDER BY Price DESC;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- EXERCISE:
-- 1. Run a query without a WHERE clause.
-- 2. Run another query filtering by Price.
-- 3. Compare logical reads and the execution time reported by SQL Server.
-- 4. Write down your observations.

/*
================================================================================
LESSON 30 - EXECUTION PLANS
================================================================================
An execution plan shows how SQL Server intends to access and process data.

In SSMS:
- Ctrl + L: display the estimated execution plan.
- Ctrl + M: enable the actual execution plan.
- Execute the query to view the actual plan.

Look for:
- Table Scan
- Index Scan
- Index Seek
- Sort
- Key Lookup
- Estimated Number of Rows
- Actual Number of Rows

The cost percentage displayed in a plan is a relative estimate, not a direct
measurement of the actual elapsed time of each operator.
*/

SELECT
    ProductId,
    ProductName,
    Price
FROM dbo.Products
WHERE ProductId = 1;
GO

SELECT
    ProductId,
    ProductName,
    Price
FROM dbo.Products
WHERE Price >= 1000.00;
GO

-- EXERCISE:
-- Enable the actual execution plan with Ctrl + M.
-- Compare the two queries and identify the operators used.
-- Observe the difference between estimated and actual rows.

/*
================================================================================
LESSON 31 - TABLE SCAN, INDEX SCAN, AND INDEX SEEK
================================================================================
TABLE SCAN:
Reads the data pages of a table.

INDEX SCAN:
Reads entries across an index.

INDEX SEEK:
Locates a key or range in an index based on search criteria.

No operator is always better. The choice depends on the query, data,
indexes, and the optimizer's estimates.
*/

-- Query using the primary key.
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE ProductId = 1;
GO

-- Query using a price range.
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE Price BETWEEN 100.00 AND 2000.00;
GO

-- Query returning all products.
SELECT ProductId, ProductName, Price
FROM dbo.Products;
GO

-- EXERCISE:
-- View the actual execution plans for all three queries.
-- Identify the operators and explain why SQL Server selected each one.

/*
================================================================================
LESSON 32 - CREATING AND ANALYZING INDEXES
================================================================================
An index can improve row retrieval, but it also increases the cost of
INSERT, UPDATE, and DELETE operations and consumes storage.

Before creating an index, analyze:
- Columns used in WHERE clauses.
- Columns used in JOIN conditions.
- Columns used in ORDER BY clauses.
- Query frequency and selectivity.
*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Roadmap_Products_Price'
      AND object_id = OBJECT_ID(N'dbo.Products')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Roadmap_Products_Price
    ON dbo.Products (Price);
END;
GO

-- Check the existing indexes on the table.
SELECT
    name AS IndexName,
    type_desc AS IndexType,
    is_unique AS IsUnique
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'dbo.Products');
GO

-- Run the price range query again.
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE Price BETWEEN 100.00 AND 2000.00;
GO

-- EXERCISE:
-- Compare the execution plan before and after creating the index.
-- Remember: SQL Server may still choose a Scan if it is less expensive.

/*
================================================================================
LESSON 33 - COMPOSITE INDEXES AND INCLUDE
================================================================================
Composite index:
An index whose key contains more than one column.

INCLUDE:
Adds columns at the leaf level of the index without making them key columns.

A covering index may satisfy a query without retrieving additional columns
from the table or clustered index.
*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Roadmap_Products_IsActive_Price'
      AND object_id = OBJECT_ID(N'dbo.Products')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Roadmap_Products_IsActive_Price
    ON dbo.Products (IsActive, Price)
    INCLUDE (ProductName, StockQuantity);
END;
GO

-- Query aligned with the composite index columns.
SELECT
    ProductName,
    Price,
    StockQuantity
FROM dbo.Products
WHERE IsActive = 1
  AND Price >= 100.00
ORDER BY Price;
GO

-- Review the definition of the created indexes.
SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS ColumnName,
    ic.key_ordinal AS KeyOrdinal,
    ic.is_included_column AS IsIncludedColumn
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic
    ON i.object_id = ic.object_id
   AND i.index_id = ic.index_id
INNER JOIN sys.columns AS c
    ON ic.object_id = c.object_id
   AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID(N'dbo.Products')
  AND i.name LIKE N'IX_Roadmap%'
ORDER BY i.name, ic.key_ordinal, ic.index_column_id;
GO

-- EXERCISE:
-- Create a query that filters by IsActive and Price.
-- Analyze whether the composite index can support the query.
-- Identify which columns are keys and which columns are INCLUDE columns.

/*
================================================================================
LESSON 34 - SQL SERVER STATISTICS
================================================================================
Statistics help the optimizer estimate how many rows a query will return.
These estimates influence execution plan selection.

Do not update statistics indiscriminately in production environments.
Consider data volume, maintenance, and the needs of the environment.
*/

-- Review the statistics available on Products.
SELECT
    name AS StatisticsName,
    auto_created AS AutoCreated,
    user_created AS UserCreated,
    is_temporary AS IsTemporary
FROM sys.stats
WHERE object_id = OBJECT_ID(N'dbo.Products');
GO

-- Update table statistics.
UPDATE STATISTICS dbo.Products;
GO

-- Display the statistics associated with the index created in Lesson 32.
DBCC SHOW_STATISTICS
(
    N'dbo.Products',
    N'IX_Roadmap_Products_Price'
)
WITH STAT_HEADER, DENSITY_VECTOR, HISTOGRAM;
GO

-- EXERCISE:
-- Review the histogram and identify its data distribution information.
-- Explain why statistics help the optimizer estimate row counts.

/*
================================================================================
LESSON 35 - SARGABILITY AND FILTER OPTIMIZATION
================================================================================
SARGable means that a predicate can be used efficiently to search for data,
allowing the optimizer to consider index-based access.

Avoid applying functions directly to filtered columns when this may prevent
an efficient index search.

NON-SARGABLE EXAMPLE:
YEAR(CreatedAt) = 2025

SARGABLE EXAMPLE:
CreatedAt >= start of year
AND CreatedAt < start of next year
*/

-- Less favorable form: function applied to the column.
SELECT ProductId, ProductName, CreatedAt
FROM dbo.Products
WHERE YEAR(CreatedAt) = 2025;
GO

-- SARGable form: date range.
DECLARE @StartDate DATETIME2 = '2025-01-01';
DECLARE @EndDate DATETIME2 = '2026-01-01';

SELECT ProductId, ProductName, CreatedAt
FROM dbo.Products
WHERE CreatedAt >= @StartDate
  AND CreatedAt < @EndDate;
GO

-- Another example: avoid applying a function to the filtered column.
-- Less favorable:
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE ISNULL(Price, 0) >= 100.00;
GO

-- Alternative, considering Price is NOT NULL in this project's table:
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE Price >= 100.00;
GO

-- EXERCISE:
-- Rewrite a query that applies a function to a column in its WHERE clause.
-- Compare estimated and actual plans when there is enough data.

/*
================================================================================
LESSON 36 - QUERY DIAGNOSIS AND OPTIMIZATION
================================================================================
Suggested workflow for investigating a slow query:

1. Identify the query and reproduce the problem.
2. Measure CPU, elapsed time, and logical reads.
3. Analyze the actual execution plan.
4. Compare estimated and actual row counts.
5. Review filters, JOINs, sorting, and aggregations.
6. Evaluate indexes and statistics.
7. Change one thing at a time.
8. Measure again and compare the results.

The query below displays aggregated execution statistics for queries that
are still present in the plan cache. Data may disappear after a restart,
plan cache cleanup, or other maintenance operations.

VIEW SERVER STATE permission may be required to query this DMV.
*/

SELECT TOP (10)
    qs.execution_count AS ExecutionCount,
    qs.total_worker_time / 1000 AS TotalCpuTimeMs,
    qs.total_elapsed_time / 1000 AS TotalElapsedTimeMs,
    qs.total_logical_reads AS TotalLogicalReads,
    qs.total_logical_reads / NULLIF(qs.execution_count, 0)
        AS AvgLogicalReads,
    SUBSTRING
    (
        st.text,
        (qs.statement_start_offset / 2) + 1,
        (
            (
                CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(st.text)
                    ELSE qs.statement_end_offset
                END
                - qs.statement_start_offset
            ) / 2
        ) + 1
    ) AS QueryText
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
WHERE st.dbid = DB_ID()
ORDER BY qs.total_worker_time DESC;
GO

/*
QUERY STORE - ADDITIONAL CONCEPT
Query Store can retain query, plan, and runtime statistics history,
helping investigate performance regressions.

Enabling it should be evaluated for each environment.
The following command is optional and requires appropriate permissions.

-- ALTER DATABASE SQLRoadmapTrainingDB SET QUERY_STORE = ON;
*/

-- FINAL EXERCISE:
-- 1. Choose a query from Module 02.
-- 2. Record its execution plan and IO/TIME statistics.
-- 3. Identify an opportunity for improvement.
-- 4. Create or adjust an index only when justified.
-- 5. Run the query again.
-- 6. Document the results before and after the change.

/*
================================================================================
MODULE 04 REVIEW
================================================================================
After completing this module, you should be able to:
1. Measure query performance using STATISTICS IO and TIME.
2. Read estimated and actual execution plans.
3. Differentiate Table Scan, Index Scan, and Index Seek.
4. Create nonclustered indexes.
5. Understand composite indexes and INCLUDE.
6. Review and update statistics.
7. Identify non-SARGable filters.
8. Follow an evidence-based query diagnosis and optimization process.

END OF MODULE 04
================================================================================
*/

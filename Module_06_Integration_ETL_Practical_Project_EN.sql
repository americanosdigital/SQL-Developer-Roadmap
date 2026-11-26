
/*
============================================================
SQL DEVELOPER ROADMAP
MODULE 06 - INTEGRATION, ETL AND PRACTICAL PROJECT
Database: SQLRoadmapTrainingDB
Lessons: 45 to 52
============================================================

PREREQUISITE:
Module 05 - Lesson 37.
Required tables:
Roadmap_Customers
Roadmap_Products
Roadmap_SalesOrders
Roadmap_SalesOrderItems

Run one lesson at a time.
============================================================
*/

USE SQLRoadmapTrainingDB;
GO

/*
============================================================
LESSON 45 - ETL FUNDAMENTALS AND STAGING TABLES
============================================================

ETL means:
E - Extract: retrieve data from the source.
T - Transform: clean and transform data.
L - Load: load data into the destination.

Staging: an intermediate area that receives data
before validation and final loading.
*/

-- 1.1 - ETL execution control table.
IF OBJECT_ID('dbo.RoadmapETL_RunLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoadmapETL_RunLog
    (
        BatchId UNIQUEIDENTIFIER PRIMARY KEY,
        StartedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        EndedAt DATETIME2 NULL,
        Status VARCHAR(20) NOT NULL,
        RowsExtracted INT NOT NULL DEFAULT 0,
        RowsLoaded INT NOT NULL DEFAULT 0,
        ErrorMessage NVARCHAR(2000) NULL
    );
END;
GO

-- 1.2 - Customer staging table.
IF OBJECT_ID('dbo.RoadmapETL_StgCustomers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoadmapETL_StgCustomers
    (
        StagingId BIGINT IDENTITY(1,1) PRIMARY KEY,
        BatchId UNIQUEIDENTIFIER NOT NULL,
        SourceCustomerId INT NOT NULL,
        FullName NVARCHAR(100) NULL,
        Email NVARCHAR(150) NULL,
        ExtractedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

-- 1.3 - Product staging table.
IF OBJECT_ID('dbo.RoadmapETL_StgProducts', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoadmapETL_StgProducts
    (
        StagingId BIGINT IDENTITY(1,1) PRIMARY KEY,
        BatchId UNIQUEIDENTIFIER NOT NULL,
        SourceProductId INT NOT NULL,
        ProductName NVARCHAR(150) NULL,
        UnitPrice DECIMAL(10,2) NULL,
        StockQuantity INT NULL,
        ExtractedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

-- 1.4 - Sales item staging table.
IF OBJECT_ID('dbo.RoadmapETL_StgSales', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoadmapETL_StgSales
    (
        StagingId BIGINT IDENTITY(1,1) PRIMARY KEY,
        BatchId UNIQUEIDENTIFIER NOT NULL,
        SourceOrderItemId INT NOT NULL,
        SourceOrderId INT NOT NULL,
        SourceCustomerId INT NOT NULL,
        SourceProductId INT NOT NULL,
        OrderDate DATETIME2 NOT NULL,
        OrderStatus VARCHAR(20) NOT NULL,
        Quantity INT NULL,
        UnitPrice DECIMAL(10,2) NULL,
        ExtractedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

-- 1.5 - Customer dimension.
IF OBJECT_ID('dbo.RoadmapETL_DimCustomer', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoadmapETL_DimCustomer
    (
        CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
        SourceCustomerId INT NOT NULL UNIQUE,
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(150) NOT NULL,
        LastUpdatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

-- 1.6 - Product dimension.
IF OBJECT_ID('dbo.RoadmapETL_DimProduct', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoadmapETL_DimProduct
    (
        ProductKey INT IDENTITY(1,1) PRIMARY KEY,
        SourceProductId INT NOT NULL UNIQUE,
        ProductName NVARCHAR(150) NOT NULL,
        UnitPrice DECIMAL(10,2) NOT NULL,
        LastUpdatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

-- 1.7 - Sales fact table.
IF OBJECT_ID('dbo.RoadmapETL_FactSales', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoadmapETL_FactSales
    (
        SalesKey BIGINT IDENTITY(1,1) PRIMARY KEY,
        SourceOrderItemId INT NOT NULL UNIQUE,
        SourceOrderId INT NOT NULL,
        CustomerKey INT NOT NULL,
        ProductKey INT NOT NULL,
        OrderDate DATETIME2 NOT NULL,
        Quantity INT NOT NULL,
        UnitPrice DECIMAL(10,2) NOT NULL,
        TotalAmount AS
            (CONVERT(DECIMAL(12,2), Quantity * UnitPrice)) PERSISTED,

        CONSTRAINT FK_RoadmapETL_Fact_Customer
            FOREIGN KEY (CustomerKey)
            REFERENCES dbo.RoadmapETL_DimCustomer(CustomerKey),

        CONSTRAINT FK_RoadmapETL_Fact_Product
            FOREIGN KEY (ProductKey)
            REFERENCES dbo.RoadmapETL_DimProduct(ProductKey),

        CONSTRAINT CK_RoadmapETL_Fact_Quantity
            CHECK (Quantity > 0),

        CONSTRAINT CK_RoadmapETL_Fact_Price
            CHECK (UnitPrice >= 0)
    );
END;
GO

-- 1.8 - Rejected records table.
IF OBJECT_ID('dbo.RoadmapETL_RejectedRows', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RoadmapETL_RejectedRows
    (
        RejectedId BIGINT IDENTITY(1,1) PRIMARY KEY,
        BatchId UNIQUEIDENTIFIER NOT NULL,
        EntityName VARCHAR(50) NOT NULL,
        SourceRecordId INT NULL,
        RejectionReason NVARCHAR(500) NOT NULL,
        RejectedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

-- Check the created structure.
SELECT name
FROM sys.tables
WHERE name LIKE 'RoadmapETL_%'
ORDER BY name;
GO

/*
============================================================
LESSON 46 - DATA IMPORT AND DATA QUALITY
============================================================

Before loading data, validate:
- Required fields.
- NULL values.
- Duplicate values.
- Valid prices and quantities.
- Existing relationships.

The example below creates a staging batch
from the source tables.
*/

DECLARE @BatchId UNIQUEIDENTIFIER = NEWID();

INSERT INTO dbo.RoadmapETL_RunLog (BatchId, Status)
VALUES (@BatchId, 'Started');

INSERT INTO dbo.RoadmapETL_StgCustomers
    (BatchId, SourceCustomerId, FullName, Email)
SELECT
    @BatchId,
    CustomerId,
    FullName,
    Email
FROM dbo.Roadmap_Customers;

INSERT INTO dbo.RoadmapETL_StgProducts
    (BatchId, SourceProductId, ProductName, UnitPrice, StockQuantity)
SELECT
    @BatchId,
    ProductId,
    ProductName,
    UnitPrice,
    StockQuantity
FROM dbo.Roadmap_Products;

INSERT INTO dbo.RoadmapETL_StgSales
(
    BatchId,
    SourceOrderItemId,
    SourceOrderId,
    SourceCustomerId,
    SourceProductId,
    OrderDate,
    OrderStatus,
    Quantity,
    UnitPrice
)
SELECT
    @BatchId,
    oi.OrderItemId,
    o.OrderId,
    o.CustomerId,
    oi.ProductId,
    o.OrderDate,
    o.OrderStatus,
    oi.Quantity,
    oi.UnitPrice
FROM dbo.Roadmap_SalesOrderItems oi
INNER JOIN dbo.Roadmap_SalesOrders o
    ON oi.OrderId = o.OrderId;

UPDATE dbo.RoadmapETL_RunLog
SET
    RowsExtracted =
        (SELECT COUNT(*) FROM dbo.RoadmapETL_StgCustomers
         WHERE BatchId = @BatchId)
        +
        (SELECT COUNT(*) FROM dbo.RoadmapETL_StgProducts
         WHERE BatchId = @BatchId)
        +
        (SELECT COUNT(*) FROM dbo.RoadmapETL_StgSales
         WHERE BatchId = @BatchId),
    EndedAt = SYSDATETIME(),
    Status = 'Extracted'
WHERE BatchId = @BatchId;

SELECT @BatchId AS CreatedBatchId;
GO

-- Check customer staging data quality.
SELECT *
FROM dbo.RoadmapETL_StgCustomers
WHERE FullName IS NULL
   OR LTRIM(RTRIM(FullName)) = ''
   OR Email IS NULL
   OR LTRIM(RTRIM(Email)) = '';
GO

SELECT *
FROM dbo.RoadmapETL_StgProducts
WHERE ProductName IS NULL
   OR UnitPrice IS NULL
   OR UnitPrice < 0
   OR StockQuantity IS NULL
   OR StockQuantity < 0;
GO

SELECT *
FROM dbo.RoadmapETL_StgSales
WHERE Quantity IS NULL
   OR Quantity <= 0
   OR UnitPrice IS NULL
   OR UnitPrice < 0;
GO

-- Example of duplicate email validation.
SELECT
    Email,
    COUNT(*) AS DuplicateCount
FROM dbo.RoadmapETL_StgCustomers
GROUP BY Email
HAVING COUNT(*) > 1;
GO

/*
CSV IMPORT - EXAMPLE

BULK INSERT requires a file accessible to the SQL Server
service and appropriate permissions. Adjust the file path
and format before running.

Example command - do not execute without adapting it:

BULK INSERT dbo.RoadmapETL_StgCustomers
FROM 'C:\SQLImports\Customers.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO
*/

/*
============================================================
LESSON 47 - INCREMENTAL LOADING AND DIMENSION UPDATES
============================================================

Incremental loading:
- Updates records that already exist.
- Inserts new records.
- Avoids reloading the entire destination table.

This example uses the latest batch.
*/

DECLARE @LatestBatchId UNIQUEIDENTIFIER;

SELECT TOP (1) @LatestBatchId = BatchId
FROM dbo.RoadmapETL_RunLog
WHERE Status = 'Extracted'
ORDER BY StartedAt DESC;

IF @LatestBatchId IS NOT NULL
BEGIN
    -- Update existing customers.
    UPDATE target
    SET
        target.FullName = source.FullName,
        target.Email = source.Email,
        target.LastUpdatedAt = SYSDATETIME()
    FROM dbo.RoadmapETL_DimCustomer target
    INNER JOIN dbo.RoadmapETL_StgCustomers source
        ON target.SourceCustomerId = source.SourceCustomerId
    WHERE source.BatchId = @LatestBatchId
      AND source.FullName IS NOT NULL
      AND source.Email IS NOT NULL;

    -- Insert new customers.
    INSERT INTO dbo.RoadmapETL_DimCustomer
        (SourceCustomerId, FullName, Email)
    SELECT
        source.SourceCustomerId,
        source.FullName,
        source.Email
    FROM dbo.RoadmapETL_StgCustomers source
    WHERE source.BatchId = @LatestBatchId
      AND source.FullName IS NOT NULL
      AND source.Email IS NOT NULL
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.RoadmapETL_DimCustomer target
          WHERE target.SourceCustomerId = source.SourceCustomerId
      );

    -- Update existing products.
    UPDATE target
    SET
        target.ProductName = source.ProductName,
        target.UnitPrice = source.UnitPrice,
        target.LastUpdatedAt = SYSDATETIME()
    FROM dbo.RoadmapETL_DimProduct target
    INNER JOIN dbo.RoadmapETL_StgProducts source
        ON target.SourceProductId = source.SourceProductId
    WHERE source.BatchId = @LatestBatchId
      AND source.ProductName IS NOT NULL
      AND source.UnitPrice >= 0;

    -- Insert new products.
    INSERT INTO dbo.RoadmapETL_DimProduct
        (SourceProductId, ProductName, UnitPrice)
    SELECT
        source.SourceProductId,
        source.ProductName,
        source.UnitPrice
    FROM dbo.RoadmapETL_StgProducts source
    WHERE source.BatchId = @LatestBatchId
      AND source.ProductName IS NOT NULL
      AND source.UnitPrice >= 0
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.RoadmapETL_DimProduct target
          WHERE target.SourceProductId = source.SourceProductId
      );
END;
GO

SELECT * FROM dbo.RoadmapETL_DimCustomer;
SELECT * FROM dbo.RoadmapETL_DimProduct;
GO

/*
============================================================
LESSON 48 - FACT TABLES AND ANALYTICAL MODELING
============================================================

A fact table stores business events or measures.
Dimensions provide context for analyzing those events.

In this project:
- FactSales: sales.
- DimCustomer: customers.
- DimProduct: products.
*/

DECLARE @LatestBatchId UNIQUEIDENTIFIER;

SELECT TOP (1) @LatestBatchId = BatchId
FROM dbo.RoadmapETL_RunLog
WHERE Status = 'Extracted'
ORDER BY StartedAt DESC;

IF @LatestBatchId IS NOT NULL
BEGIN
    INSERT INTO dbo.RoadmapETL_FactSales
    (
        SourceOrderItemId,
        SourceOrderId,
        CustomerKey,
        ProductKey,
        OrderDate,
        Quantity,
        UnitPrice
    )
    SELECT
        s.SourceOrderItemId,
        s.SourceOrderId,
        c.CustomerKey,
        p.ProductKey,
        s.OrderDate,
        s.Quantity,
        s.UnitPrice
    FROM dbo.RoadmapETL_StgSales s
    INNER JOIN dbo.RoadmapETL_DimCustomer c
        ON s.SourceCustomerId = c.SourceCustomerId
    INNER JOIN dbo.RoadmapETL_DimProduct p
        ON s.SourceProductId = p.SourceProductId
    WHERE s.BatchId = @LatestBatchId
      AND s.Quantity > 0
      AND s.UnitPrice >= 0
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.RoadmapETL_FactSales f
          WHERE f.SourceOrderItemId = s.SourceOrderItemId
      );
END;
GO

-- Query the analytical model.
SELECT
    f.SalesKey,
    f.SourceOrderId,
    c.FullName AS CustomerName,
    p.ProductName,
    f.OrderDate,
    f.Quantity,
    f.UnitPrice,
    f.TotalAmount
FROM dbo.RoadmapETL_FactSales f
INNER JOIN dbo.RoadmapETL_DimCustomer c
    ON f.CustomerKey = c.CustomerKey
INNER JOIN dbo.RoadmapETL_DimProduct p
    ON f.ProductKey = p.ProductKey
ORDER BY f.OrderDate DESC;
GO

/*
============================================================
LESSON 49 - STORED PROCEDURE FOR ETL PROCESSING
============================================================

The procedure below automates:
1. Extraction.
2. Staging.
3. Validation.
4. Dimension updates and inserts.
5. Fact table loading.
6. Audit logging.

The process uses a transaction to protect
the loading operations.
*/

CREATE OR ALTER PROCEDURE dbo.RoadmapETL_RunSalesLoad
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @BatchId UNIQUEIDENTIFIER = NEWID();
    DECLARE @RowsExtracted INT = 0;
    DECLARE @RowsLoaded INT = 0;

    INSERT INTO dbo.RoadmapETL_RunLog (BatchId, Status)
    VALUES (@BatchId, 'Started');

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Extract customers.
        INSERT INTO dbo.RoadmapETL_StgCustomers
            (BatchId, SourceCustomerId, FullName, Email)
        SELECT
            @BatchId, CustomerId, FullName, Email
        FROM dbo.Roadmap_Customers;

        SET @RowsExtracted += @@ROWCOUNT;

        -- Extract products.
        INSERT INTO dbo.RoadmapETL_StgProducts
            (BatchId, SourceProductId, ProductName, UnitPrice, StockQuantity)
        SELECT
            @BatchId, ProductId, ProductName, UnitPrice, StockQuantity
        FROM dbo.Roadmap_Products;

        SET @RowsExtracted += @@ROWCOUNT;

        -- Extract sales.
        INSERT INTO dbo.RoadmapETL_StgSales
        (
            BatchId, SourceOrderItemId, SourceOrderId,
            SourceCustomerId, SourceProductId, OrderDate,
            OrderStatus, Quantity, UnitPrice
        )
        SELECT
            @BatchId,
            oi.OrderItemId,
            o.OrderId,
            o.CustomerId,
            oi.ProductId,
            o.OrderDate,
            o.OrderStatus,
            oi.Quantity,
            oi.UnitPrice
        FROM dbo.Roadmap_SalesOrderItems oi
        INNER JOIN dbo.Roadmap_SalesOrders o
            ON oi.OrderId = o.OrderId;

        SET @RowsExtracted += @@ROWCOUNT;

        -- Register rejected customer records.
        INSERT INTO dbo.RoadmapETL_RejectedRows
            (BatchId, EntityName, SourceRecordId, RejectionReason)
        SELECT
            @BatchId,
            'Customer',
            SourceCustomerId,
            'Missing name or email.'
        FROM dbo.RoadmapETL_StgCustomers
        WHERE BatchId = @BatchId
          AND
          (
              FullName IS NULL
              OR LTRIM(RTRIM(FullName)) = ''
              OR Email IS NULL
              OR LTRIM(RTRIM(Email)) = ''
          );

        -- Register rejected product records.
        INSERT INTO dbo.RoadmapETL_RejectedRows
            (BatchId, EntityName, SourceRecordId, RejectionReason)
        SELECT
            @BatchId,
            'Product',
            SourceProductId,
            'Invalid product name or price.'
        FROM dbo.RoadmapETL_StgProducts
        WHERE BatchId = @BatchId
          AND
          (
              ProductName IS NULL
              OR UnitPrice IS NULL
              OR UnitPrice < 0
          );

        -- Update existing customers.
        UPDATE target
        SET
            target.FullName = source.FullName,
            target.Email = source.Email,
            target.LastUpdatedAt = SYSDATETIME()
        FROM dbo.RoadmapETL_DimCustomer target
        INNER JOIN dbo.RoadmapETL_StgCustomers source
            ON target.SourceCustomerId = source.SourceCustomerId
        WHERE source.BatchId = @BatchId
          AND source.FullName IS NOT NULL
          AND source.Email IS NOT NULL;

        -- Insert new customers.
        INSERT INTO dbo.RoadmapETL_DimCustomer
            (SourceCustomerId, FullName, Email)
        SELECT
            s.SourceCustomerId, s.FullName, s.Email
        FROM dbo.RoadmapETL_StgCustomers s
        WHERE s.BatchId = @BatchId
          AND s.FullName IS NOT NULL
          AND s.Email IS NOT NULL
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.RoadmapETL_DimCustomer d
              WHERE d.SourceCustomerId = s.SourceCustomerId
          );

        -- Update existing products.
        UPDATE target
        SET
            target.ProductName = source.ProductName,
            target.UnitPrice = source.UnitPrice,
            target.LastUpdatedAt = SYSDATETIME()
        FROM dbo.RoadmapETL_DimProduct target
        INNER JOIN dbo.RoadmapETL_StgProducts source
            ON target.SourceProductId = source.SourceProductId
        WHERE source.BatchId = @BatchId
          AND source.ProductName IS NOT NULL
          AND source.UnitPrice >= 0;

        -- Insert new products.
        INSERT INTO dbo.RoadmapETL_DimProduct
            (SourceProductId, ProductName, UnitPrice)
        SELECT
            s.SourceProductId, s.ProductName, s.UnitPrice
        FROM dbo.RoadmapETL_StgProducts s
        WHERE s.BatchId = @BatchId
          AND s.ProductName IS NOT NULL
          AND s.UnitPrice >= 0
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.RoadmapETL_DimProduct d
              WHERE d.SourceProductId = s.SourceProductId
          );

        -- Load the fact table without duplicating source items.
        INSERT INTO dbo.RoadmapETL_FactSales
        (
            SourceOrderItemId,
            SourceOrderId,
            CustomerKey,
            ProductKey,
            OrderDate,
            Quantity,
            UnitPrice
        )
        SELECT
            s.SourceOrderItemId,
            s.SourceOrderId,
            c.CustomerKey,
            p.ProductKey,
            s.OrderDate,
            s.Quantity,
            s.UnitPrice
        FROM dbo.RoadmapETL_StgSales s
        INNER JOIN dbo.RoadmapETL_DimCustomer c
            ON s.SourceCustomerId = c.SourceCustomerId
        INNER JOIN dbo.RoadmapETL_DimProduct p
            ON s.SourceProductId = p.SourceProductId
        WHERE s.BatchId = @BatchId
          AND s.Quantity > 0
          AND s.UnitPrice >= 0
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.RoadmapETL_FactSales f
              WHERE f.SourceOrderItemId = s.SourceOrderItemId
          );

        SET @RowsLoaded = @@ROWCOUNT;

        COMMIT TRANSACTION;

        UPDATE dbo.RoadmapETL_RunLog
        SET
            EndedAt = SYSDATETIME(),
            Status = 'Succeeded',
            RowsExtracted = @RowsExtracted,
            RowsLoaded = @RowsLoaded
        WHERE BatchId = @BatchId;

        SELECT
            @BatchId AS BatchId,
            @RowsExtracted AS RowsExtracted,
            @RowsLoaded AS RowsLoaded,
            'Succeeded' AS Status;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        UPDATE dbo.RoadmapETL_RunLog
        SET
            EndedAt = SYSDATETIME(),
            Status = 'Failed',
            RowsExtracted = @RowsExtracted,
            RowsLoaded = 0,
            ErrorMessage = ERROR_MESSAGE()
        WHERE BatchId = @BatchId;

        THROW;
    END CATCH;
END;
GO

/*
============================================================
LESSON 50 - AUDITING, MONITORING AND ERROR HANDLING
============================================================

The loading procedure records:
- Batch identifier.
- Execution start and end.
- Status.
- Extracted row count.
- Loaded row count.
- Error message.
*/

-- Run the ETL process.
EXEC dbo.RoadmapETL_RunSalesLoad;
GO

-- Execution history.
SELECT
    BatchId,
    StartedAt,
    EndedAt,
    Status,
    RowsExtracted,
    RowsLoaded,
    ErrorMessage
FROM dbo.RoadmapETL_RunLog
ORDER BY StartedAt DESC;
GO

-- Rejected records.
SELECT *
FROM dbo.RoadmapETL_RejectedRows
ORDER BY RejectedAt DESC;
GO

-- Number of records in each destination table.
SELECT 'Customers' AS Entity, COUNT(*) AS TotalRows
FROM dbo.RoadmapETL_DimCustomer
UNION ALL
SELECT 'Products', COUNT(*)
FROM dbo.RoadmapETL_DimProduct
UNION ALL
SELECT 'Sales', COUNT(*)
FROM dbo.RoadmapETL_FactSales;
GO

/*
============================================================
LESSON 51 - SQL SERVER INTEGRATION WITH .NET APPLICATIONS
============================================================

.NET applications can access SQL Server using:
- ADO.NET.
- Microsoft.Data.SqlClient.
- Entity Framework Core.
- Stored procedures.

Best practice:
Use parameters instead of concatenating values
directly into SQL commands.
*/

CREATE OR ALTER PROCEDURE dbo.RoadmapETL_GetSalesReport
    @StartDate DATE,
    @EndDate DATE,
    @CustomerKey INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NULL OR @EndDate IS NULL
        THROW 50010, 'Start date and end date are required.', 1;

    IF @StartDate > @EndDate
        THROW 50011, 'Start date cannot be greater than end date.', 1;

    SELECT
        c.CustomerKey,
        c.FullName AS CustomerName,
        p.ProductName,
        CAST(f.OrderDate AS DATE) AS SaleDate,
        SUM(f.Quantity) AS TotalQuantity,
        SUM(f.TotalAmount) AS TotalSales
    FROM dbo.RoadmapETL_FactSales f
    INNER JOIN dbo.RoadmapETL_DimCustomer c
        ON f.CustomerKey = c.CustomerKey
    INNER JOIN dbo.RoadmapETL_DimProduct p
        ON f.ProductKey = p.ProductKey
    WHERE f.OrderDate >= @StartDate
      AND f.OrderDate < DATEADD(DAY, 1, @EndDate)
      AND (@CustomerKey IS NULL OR c.CustomerKey = @CustomerKey)
    GROUP BY
        c.CustomerKey,
        c.FullName,
        p.ProductName,
        CAST(f.OrderDate AS DATE)
    ORDER BY SaleDate DESC, CustomerName;
END;
GO

-- Procedure test.
EXEC dbo.RoadmapETL_GetSalesReport
    @StartDate = '2020-01-01',
    @EndDate = '2030-12-31',
    @CustomerKey = NULL;
GO

/*
CONCEPTUAL C# EXAMPLE WITH Microsoft.Data.SqlClient

using Microsoft.Data.SqlClient;
using System.Data;

using var connection = new SqlConnection(connectionString);

using var command = new SqlCommand(
    "dbo.RoadmapETL_GetSalesReport",
    connection
);

command.CommandType = CommandType.StoredProcedure;

command.Parameters.Add("@StartDate", SqlDbType.Date).Value =
    new DateTime(2026, 1, 1);

command.Parameters.Add("@EndDate", SqlDbType.Date).Value =
    new DateTime(2026, 12, 31);

command.Parameters.Add("@CustomerKey", SqlDbType.Int).Value =
    DBNull.Value;

await connection.OpenAsync();

using var reader = await command.ExecuteReaderAsync();

while (await reader.ReadAsync())
{
    Console.WriteLine(reader["CustomerName"]);
    Console.WriteLine(reader["TotalSales"]);
}

The connection string should be stored securely,
for example, in protected configuration or a secret manager.
Never place passwords directly in source code.
*/

/*
============================================================
LESSON 52 - FINAL PROJECT: ANALYTICAL QUERIES AND REPORTING
============================================================

Goal:
Build queries that answer business questions:
- How much revenue was generated?
- Which products sold the most?
- Which customers purchased the most?
- What were the monthly sales?
*/

-- 52.1 - Total sales.
SELECT
    COUNT(*) AS TotalSalesItems,
    SUM(Quantity) AS TotalUnitsSold,
    SUM(TotalAmount) AS TotalRevenue
FROM dbo.RoadmapETL_FactSales;
GO

-- 52.2 - Products with the highest revenue.
SELECT
    p.ProductName,
    SUM(f.Quantity) AS UnitsSold,
    SUM(f.TotalAmount) AS Revenue
FROM dbo.RoadmapETL_FactSales f
INNER JOIN dbo.RoadmapETL_DimProduct p
    ON f.ProductKey = p.ProductKey
GROUP BY p.ProductName
ORDER BY Revenue DESC;
GO

-- 52.3 - Customers with the highest purchase volume.
SELECT
    c.FullName AS CustomerName,
    COUNT(DISTINCT f.SourceOrderId) AS TotalOrders,
    SUM(f.TotalAmount) AS TotalPurchased
FROM dbo.RoadmapETL_FactSales f
INNER JOIN dbo.RoadmapETL_DimCustomer c
    ON f.CustomerKey = c.CustomerKey
GROUP BY c.FullName
ORDER BY TotalPurchased DESC;
GO

-- 52.4 - Sales by month.
SELECT
    YEAR(OrderDate) AS SalesYear,
    MONTH(OrderDate) AS SalesMonth,
    SUM(Quantity) AS UnitsSold,
    SUM(TotalAmount) AS MonthlyRevenue
FROM dbo.RoadmapETL_FactSales
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate)
ORDER BY SalesYear, SalesMonth;
GO

-- 52.5 - Create an index for date-based queries.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_RoadmapETL_FactSales_OrderDate'
      AND object_id = OBJECT_ID('dbo.RoadmapETL_FactSales')
)
BEGIN
    CREATE INDEX IX_RoadmapETL_FactSales_OrderDate
    ON dbo.RoadmapETL_FactSales (OrderDate)
    INCLUDE (CustomerKey, ProductKey, Quantity, UnitPrice);
END;
GO

-- 52.6 - Final reporting view.
CREATE OR ALTER VIEW dbo.RoadmapETL_vw_SalesAnalytics
AS
SELECT
    f.SalesKey,
    f.SourceOrderId,
    f.OrderDate,
    c.FullName AS CustomerName,
    p.ProductName,
    f.Quantity,
    f.UnitPrice,
    f.TotalAmount
FROM dbo.RoadmapETL_FactSales f
INNER JOIN dbo.RoadmapETL_DimCustomer c
    ON f.CustomerKey = c.CustomerKey
INNER JOIN dbo.RoadmapETL_DimProduct p
    ON f.ProductKey = p.ProductKey;
GO

SELECT *
FROM dbo.RoadmapETL_vw_SalesAnalytics
ORDER BY OrderDate DESC;
GO

/*
============================================================
MODULE 06 REVIEW
============================================================

Lesson 45 - ETL and staging tables
Lesson 46 - Data import and data quality
Lesson 47 - Incremental loading and dimensions
Lesson 48 - Fact tables and analytical modeling
Lesson 49 - ETL stored procedure
Lesson 50 - Auditing and monitoring
Lesson 51 - .NET integration
Lesson 52 - Final project and reporting

============================================================
END OF MODULE 06
============================================================
*/

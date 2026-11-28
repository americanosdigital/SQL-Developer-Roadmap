
/*
============================================================
SQL DEVELOPER ROADMAP
MODULE 05 - DATABASE DESIGN, TRANSACTIONS AND SECURITY
Database: SQLRoadmapTrainingDB
Lessons: 37 to 44
============================================================
*/

USE SQLRoadmapTrainingDB;
GO

/*
============================================================
LESSON 37 - DATA MODELING AND NORMALIZATION
============================================================

Objectives:
- Separate entities into specific tables.
- Avoid unnecessary data duplication.
- Use primary and foreign keys.
- Apply database normalization concepts.

Example structure:
Customers -> Orders -> Order Items -> Products
Categories -> Products
*/

IF OBJECT_ID('dbo.Roadmap_Customers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Roadmap_Customers
    (
        CustomerId INT IDENTITY(1,1) PRIMARY KEY,
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(150) NOT NULL UNIQUE,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

IF OBJECT_ID('dbo.Roadmap_Categories', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Roadmap_Categories
    (
        CategoryId INT IDENTITY(1,1) PRIMARY KEY,
        CategoryName NVARCHAR(100) NOT NULL UNIQUE
    );
END;
GO

IF OBJECT_ID('dbo.Roadmap_Suppliers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Roadmap_Suppliers
    (
        SupplierId INT IDENTITY(1,1) PRIMARY KEY,
        SupplierName NVARCHAR(150) NOT NULL,
        Email NVARCHAR(150) NULL
    );
END;
GO

IF OBJECT_ID('dbo.Roadmap_Products', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Roadmap_Products
    (
        ProductId INT IDENTITY(1,1) PRIMARY KEY,
        ProductName NVARCHAR(150) NOT NULL,
        CategoryId INT NOT NULL,
        SupplierId INT NOT NULL,
        UnitPrice DECIMAL(10,2) NOT NULL,
        StockQuantity INT NOT NULL DEFAULT 0,

        CONSTRAINT FK_Roadmap_Products_Categories
            FOREIGN KEY (CategoryId)
            REFERENCES dbo.Roadmap_Categories(CategoryId),

        CONSTRAINT FK_Roadmap_Products_Suppliers
            FOREIGN KEY (SupplierId)
            REFERENCES dbo.Roadmap_Suppliers(SupplierId),

        CONSTRAINT CK_Roadmap_Products_Price
            CHECK (UnitPrice >= 0),

        CONSTRAINT CK_Roadmap_Products_Stock
            CHECK (StockQuantity >= 0)
    );
END;
GO

IF OBJECT_ID('dbo.Roadmap_SalesOrders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Roadmap_SalesOrders
    (
        OrderId INT IDENTITY(1,1) PRIMARY KEY,
        CustomerId INT NOT NULL,
        OrderDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        OrderStatus VARCHAR(20) NOT NULL DEFAULT 'Pending',

        CONSTRAINT FK_Roadmap_SalesOrders_Customers
            FOREIGN KEY (CustomerId)
            REFERENCES dbo.Roadmap_Customers(CustomerId),

        CONSTRAINT CK_Roadmap_SalesOrders_Status
            CHECK (OrderStatus IN ('Pending', 'Paid', 'Cancelled'))
    );
END;
GO

IF OBJECT_ID('dbo.Roadmap_SalesOrderItems', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Roadmap_SalesOrderItems
    (
        OrderItemId INT IDENTITY(1,1) PRIMARY KEY,
        OrderId INT NOT NULL,
        ProductId INT NOT NULL,
        Quantity INT NOT NULL,
        UnitPrice DECIMAL(10,2) NOT NULL,

        CONSTRAINT FK_Roadmap_OrderItems_Orders
            FOREIGN KEY (OrderId)
            REFERENCES dbo.Roadmap_SalesOrders(OrderId),

        CONSTRAINT FK_Roadmap_OrderItems_Products
            FOREIGN KEY (ProductId)
            REFERENCES dbo.Roadmap_Products(ProductId),

        CONSTRAINT CK_Roadmap_OrderItems_Quantity
            CHECK (Quantity > 0),

        CONSTRAINT CK_Roadmap_OrderItems_Price
            CHECK (UnitPrice >= 0)
    );
END;
GO

-- Insert sample data without creating duplicates.

IF NOT EXISTS (
    SELECT 1 FROM dbo.Roadmap_Customers
    WHERE Email = 'cliente.roadmap@email.com'
)
BEGIN
    INSERT INTO dbo.Roadmap_Customers (FullName, Email)
    VALUES ('Roadmap Customer', 'cliente.roadmap@email.com');
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.Roadmap_Categories
    WHERE CategoryName = 'Informatica'
)
BEGIN
    INSERT INTO dbo.Roadmap_Categories (CategoryName)
    VALUES ('Informatica');
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.Roadmap_Suppliers
    WHERE SupplierName = 'Roadmap Supplier'
)
BEGIN
    INSERT INTO dbo.Roadmap_Suppliers (SupplierName, Email)
    VALUES ('Roadmap Supplier', 'supplier@email.com');
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.Roadmap_Products
    WHERE ProductName = 'Roadmap Notebook'
)
BEGIN
    INSERT INTO dbo.Roadmap_Products
        (ProductName, CategoryId, SupplierId, UnitPrice, StockQuantity)
    SELECT
        'Roadmap Notebook',
        c.CategoryId,
        s.SupplierId,
        4500.00,
        10
    FROM dbo.Roadmap_Categories c
    CROSS JOIN dbo.Roadmap_Suppliers s
    WHERE c.CategoryName = 'Informatica'
      AND s.SupplierName = 'Roadmap Supplier';
END;
GO

SELECT * FROM dbo.Roadmap_Customers;
SELECT * FROM dbo.Roadmap_Categories;
SELECT * FROM dbo.Roadmap_Suppliers;
SELECT * FROM dbo.Roadmap_Products;
GO

/*
============================================================
LESSON 38 - DENORMALIZATION AND REPORTING QUERIES
============================================================

Normalization reduces redundancy and improves consistency.
Denormalization can simplify read queries, but may increase
data redundancy and maintenance costs.

A VIEW can present data from multiple tables
in a convenient structure for reporting.
*/

CREATE OR ALTER VIEW dbo.Roadmap_vw_OrderSummary
AS
SELECT
    o.OrderId,
    o.OrderDate,
    o.OrderStatus,
    c.FullName AS CustomerName,
    p.ProductName,
    i.Quantity,
    i.UnitPrice,
    CAST(i.Quantity * i.UnitPrice AS DECIMAL(12,2)) AS ItemTotal
FROM dbo.Roadmap_SalesOrders o
INNER JOIN dbo.Roadmap_Customers c
    ON o.CustomerId = c.CustomerId
INNER JOIN dbo.Roadmap_SalesOrderItems i
    ON o.OrderId = i.OrderId
INNER JOIN dbo.Roadmap_Products p
    ON i.ProductId = p.ProductId;
GO

SELECT * FROM dbo.Roadmap_vw_OrderSummary;
GO

-- Example of an aggregated report.
SELECT
    CustomerName,
    COUNT(DISTINCT OrderId) AS TotalOrders,
    SUM(ItemTotal) AS TotalPurchased
FROM dbo.Roadmap_vw_OrderSummary
GROUP BY CustomerName;
GO

/*
============================================================
LESSON 39 - RELATIONSHIPS AND REFERENTIAL INTEGRITY
============================================================

PK: uniquely identifies each record.
FK: ensures that the related record exists.
UNIQUE: prevents duplicate values.
CHECK: validates business rules.
NOT NULL: requires a value.

The relationships in this lesson were defined in Lesson 37.
*/

-- Querying foreign keys in the model.
SELECT
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
WHERE fk.name LIKE 'FK_Roadmap_%';
GO

-- Integrity test: the INSERT below should fail
-- because the specified CustomerId does not exist.
-- Run separately only to observe the validation.
--
-- INSERT INTO dbo.Roadmap_SalesOrders (CustomerId)
-- VALUES (999999);
GO

-- Testing a CHECK constraint.
-- The INSERT below should fail because quantity must be positive.
--
-- INSERT INTO dbo.Roadmap_SalesOrderItems
--     (OrderId, ProductId, Quantity, UnitPrice)
-- VALUES (1, 1, 0, 100.00);
GO

/*
============================================================
LESSON 40 - ACID PROPERTIES AND TRANSACTIONS
============================================================

A - Atomicity: all operations succeed or none do.
C - Consistency: data must satisfy defined rules.
I - Isolation: concurrent transactions are controlled.
D - Durability: committed data remains persisted.

This example demonstrates ROLLBACK.
The stock update will be undone.
*/

DECLARE @ProductId INT;

SELECT @ProductId = ProductId
FROM dbo.Roadmap_Products
WHERE ProductName = 'Roadmap Notebook';

IF @ProductId IS NOT NULL
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.Roadmap_Products
        SET StockQuantity = StockQuantity - 1
        WHERE ProductId = @ProductId
          AND StockQuantity > 0;

        IF @@ROWCOUNT = 0
            THROW 50001, 'Insufficient stock or product not found.', 1;

        SELECT
            ProductName,
            StockQuantity AS StockAfterUpdate
        FROM dbo.Roadmap_Products
        WHERE ProductId = @ProductId;

        -- Undo the update for demonstration purposes.
        ROLLBACK TRANSACTION;

        PRINT 'Transaction rolled back successfully.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        PRINT ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Commit example:
-- Replace ROLLBACK with COMMIT in the previous example
-- to persist the change. Execute carefully.

/*
============================================================
LESSON 41 - TRANSACTION ISOLATION LEVELS
============================================================

READ UNCOMMITTED: allows uncommitted reads.
READ COMMITTED: prevents dirty reads; commonly the default.
REPEATABLE READ: holds read locks until the transaction ends.
SERIALIZABLE: the most restrictive level; protects data ranges.
SNAPSHOT: uses row versioning.

*/

-- Common default isolation level.
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT *
FROM dbo.Roadmap_Products;
GO

-- Uncommitted read example.
-- May return data that another transaction can still roll back.
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT *
FROM dbo.Roadmap_Products;
GO

-- More restrictive isolation level.
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT *
FROM dbo.Roadmap_Products
WHERE ProductId = 1;
GO

-- Returning to the default isolation level.
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

-- SNAPSHOT requires database-level configuration.
-- Plan carefully because this changes a database setting.
-- ALTER DATABASE SQLRoadmapTrainingDB
-- SET ALLOW_SNAPSHOT_ISOLATION ON;
--
-- After enabling it:
-- SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
-- BEGIN TRANSACTION;
-- SELECT * FROM dbo.Roadmap_Products;
-- COMMIT TRANSACTION;
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

/*
============================================================
LESSON 42 - LOCKS, BLOCKING AND DEADLOCKS
============================================================

LOCK: mechanism that controls concurrent data access.
BLOCKING: one session waits for another to release a resource.
DEADLOCK: two or more sessions wait on resources held by each
other, creating a cycle. SQL Server selects a victim transaction.

BLOCKING TEST:
1. Open two query windows in SSMS.
2. Run BLOCK A in the first window.
3. While its transaction is open, run BLOCK B
   in the second window.
4. Observe that the second session may wait.
5. Return to the first window and run ROLLBACK.
*/

-- BLOCK A - SESSION 1
-- Run and keep the transaction open.
--
-- BEGIN TRANSACTION;
-- UPDATE dbo.Roadmap_Products
-- SET UnitPrice = UnitPrice + 1
-- WHERE ProductName = 'Roadmap Notebook';
--
-- Do not run COMMIT yet.
-- After testing the second session:
-- ROLLBACK TRANSACTION;
GO

-- BLOCK B - SESSION 2
-- Run while Session 1's transaction is still open.
--
-- SELECT *
-- FROM dbo.Roadmap_Products
-- WHERE ProductName = 'Roadmap Notebook';
GO

-- Query blocked sessions.
SELECT
    session_id,
    blocking_session_id,
    wait_type,
    wait_time,
    wait_resource,
    status
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;
GO

-- Query active locks in the current database.
SELECT
    request_session_id,
    resource_type,
    request_mode,
    request_status
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID();
GO

/*
DEADLOCK - CONCEPTUAL EXAMPLE

To reproduce, two sessions are required:
- Session A locks resource 1 and then tries to access resource 2.
- Session B locks resource 2 and then tries to access resource 1.

Best practices:
- Access tables in a consistent order.
- Keep transactions short.
- Create appropriate indexes.
- Handle error 1205 and retry the operation when appropriate.
*/

/*
============================================================
LESSON 43 - USERS, ROLES AND PERMISSIONS
============================================================

Principle of least privilege:
grant only the permissions that are necessary.

This example creates a user without login,
suitable for a demonstration inside the database.
It does not create a server-level login.
*/

IF DATABASE_PRINCIPAL_ID('RoadmapReaderRole') IS NULL
    CREATE ROLE RoadmapReaderRole;
GO

IF DATABASE_PRINCIPAL_ID('Roadmap_DemoReader') IS NULL
    CREATE USER Roadmap_DemoReader WITHOUT LOGIN;
GO

-- Grant read access only to the reporting VIEW.
GRANT SELECT ON OBJECT::dbo.Roadmap_vw_OrderSummary
TO RoadmapReaderRole;
GO

-- Add the user to the role.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_role_members drm
    INNER JOIN sys.database_principals r
        ON drm.role_principal_id = r.principal_id
    INNER JOIN sys.database_principals u
        ON drm.member_principal_id = u.principal_id
    WHERE r.name = 'RoadmapReaderRole'
      AND u.name = 'Roadmap_DemoReader'
)
BEGIN
    ALTER ROLE RoadmapReaderRole
    ADD MEMBER Roadmap_DemoReader;
END;
GO

-- Permission test: the user can query the VIEW.
EXECUTE AS USER = 'Roadmap_DemoReader';

SELECT *
FROM dbo.Roadmap_vw_OrderSummary;

REVERT;
GO

-- Review granted permissions.
SELECT
    grantee.name AS PrincipalName,
    permission.permission_name,
    permission.state_desc,
    OBJECT_NAME(permission.major_id) AS ObjectName
FROM sys.database_permissions permission
INNER JOIN sys.database_principals grantee
    ON permission.grantee_principal_id = grantee.principal_id
WHERE grantee.name = 'RoadmapReaderRole';
GO

/*
============================================================
LESSON 44 - BACKUP AND RESTORE
============================================================

BACKUP: creates a database backup.
RESTORE: recovers a database from a backup.
VERIFYONLY: checks whether the backup can be read and whether
the backup set is structurally complete.

IMPORTANT:
- Create the C:\SQLBackups folder before running the backup.
- The SQL Server service account needs write permission.
- The path belongs to the SQL Server machine, not necessarily
  the computer where SSMS is running.
*/

-- FULL DATABASE BACKUP.
BACKUP DATABASE SQLRoadmapTrainingDB
TO DISK = N'C:\SQLBackups\SQLRoadmapTrainingDB_Full.bak'
WITH
    INIT,
    CHECKSUM,
    STATS = 10;
GO

-- Verify the backup file.
RESTORE VERIFYONLY
FROM DISK = N'C:\SQLBackups\SQLRoadmapTrainingDB_Full.bak'
WITH CHECKSUM;
GO

-- Inspect logical file names inside the backup.
RESTORE FILELISTONLY
FROM DISK = N'C:\SQLBackups\SQLRoadmapTrainingDB_Full.bak';
GO

/*
RESTORE TEMPLATE FOR A DIFFERENT DATABASE

1. Run RESTORE FILELISTONLY.
2. Identify the logical data and log file names.
3. Adjust the logical names and physical paths below.
4. Make sure C:\SQLData exists and has the required permissions.

Do not run this template without adapting the names and paths.

RESTORE DATABASE SQLRoadmapTrainingDB_RestoreTest
FROM DISK = N'C:\SQLBackups\SQLRoadmapTrainingDB_Full.bak'
WITH
    MOVE N'LogicalDataFileName'
        TO N'C:\SQLData\SQLRoadmapTrainingDB_RestoreTest.mdf',
    MOVE N'LogicalLogFileName'
        TO N'C:\SQLData\SQLRoadmapTrainingDB_RestoreTest_log.ldf',
    RECOVERY,
    STATS = 10;
GO
*/

-- Check existing databases.
SELECT name, state_desc, recovery_model_desc
FROM sys.databases
WHERE name LIKE 'SQLRoadmapTrainingDB%';
GO

/*
============================================================
MODULE 05 REVIEW
============================================================

Lesson 37 - Data modeling and normalization
Lesson 38 - Denormalization and reporting
Lesson 39 - Relationships and referential integrity
Lesson 40 - ACID and transactions
Lesson 41 - Transaction isolation levels
Lesson 42 - Locks, blocking and deadlocks
Lesson 43 - Users, roles and permissions
Lesson 44 - Backup and restore

============================================================
END OF MODULE 05
============================================================
*/

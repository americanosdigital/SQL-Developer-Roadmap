-- =============================================
-- SQL Developer Roadmap
-- Module 01 - SQL Server Fundamentals
-- English version | English-only comments
-- =============================================


-- =============================================
-- SQL Developer Roadmap
-- Module 01 - SQL Fundamentals
-- Lesson 01 - Database Creation
-- SQL Developer Roadmap
-- Module 01 - SQL Fundamentals
-- Lesson 01 - Database Creation
-- =============================================

-- Creating the database.
-- SQL
IF DB_ID('SQLRoadmapTrainingDB') IS NULL
BEGIN
    CREATE DATABASE SQLRoadmapTrainingDB;
END;
GO

-- Using the created database.
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- Verifying database creation.
-- SQL
SELECT
    name,
    database_id,
    create_date
FROM sys.databases
WHERE name = 'SQLRoadmapTrainingDB';
GO

-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Aula 2: CREATE TABLE e tipos de dados
-- Lesson 2: CREATE TABLE and data types
-- =========================================================
--
--
-- ├── 01-create-database
-- ├── 02-create-customers-table
-- └── 03-create-products-table

-- Understanding data types
-- These are some of the most commonly used data types in SQL Server:
-- These are some of the most commonly used types in SQL Server:
-- Type	Usage	Example
-- Integers :           100
-- Larger integers :    9000000000
-- Variable text :        'John'
-- NVARCHAR stores Unicode text, for example: 'João'.
-- Decimal values :     199.90
-- True or false :   1 ou 0
-- Date : 	                        '2026-11-12'
-- Date and time :        '2026-11-12 10:30:00'

-- Using the created database.
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- Create Customers table.
-- SQL
IF OBJECT_ID('dbo.Customers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Customers
    (
        CustomerId INT IDENTITY(1,1) PRIMARY KEY,
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(150) NOT NULL UNIQUE,
        Phone VARCHAR(20) NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

-- Create Products table.
-- SQL
IF OBJECT_ID('dbo.Products', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Products
    (
        ProductId INT IDENTITY(1,1) PRIMARY KEY,
        ProductName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(500) NULL,
        Price DECIMAL(10,2) NOT NULL,
        StockQuantity INT NOT NULL DEFAULT 0,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

        CONSTRAINT CK_Products_Price
            CHECK (Price >= 0),

        CONSTRAINT CK_Products_Stock
            CHECK (StockQuantity >= 0)
    );
END;
GO

--
-- Review exercises
-- Try to answer without checking the explanations above.
-- Lesson 2 Quiz
-- 3 respondidas
--
-- Correct
--
-- Correct
--
-- Correct

-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Lesson 3 - SQL Server: INSERT INTO and SELECT.
-- Lesson 3 - SQL Server: INSERT INTO and SELECT.
-- =========================================================

-- Checking if the tables exist.
-- SQL
USE SQLRoadmapTrainingDB;
GO

SELECT * FROM Customers;
GO

SELECT * FROM Products;
GO

-- Inserting data into the Customers table.
-- SQL
INSERT INTO Customers (FullName, Email, Phone)
SELECT V.FullName, V.Email, V.Phone
FROM (VALUES
    ('Joao Silva', 'joao@email.com', '21999990001'),
    ('Maria Santos', 'maria@email.com', '21999990002'),
    ('Pedro Oliveira', 'pedro@email.com', '21999990003'),
    ('Ana Costa', 'ana@email.com', '21999990004')
) AS V(FullName, Email, Phone)
WHERE NOT EXISTS
(
    SELECT 1
    FROM Customers C
    WHERE C.Email = V.Email
);
GO

-- checking.
SELECT * FROM Customers
GO

-- Inserting data into the Products table.
-- SQL
INSERT INTO Products (ProductName, Description, Price, StockQuantity)
SELECT V.ProductName, V.Description, V.Price, V.StockQuantity
FROM (VALUES
    ('Notebook Dell', 'Notebook Intel Core i7', 4500.00, 10),
    ('Mouse Logitech', 'Mouse sem fio', 120.00, 50),
    ('Keyboard Logitech', 'Teclado mecânico', 350.00, 20),
    ('Monitor Samsung', 'Monitor 27 polegadas', 1300.00, 15)
) AS V(ProductName, Description, Price, StockQuantity)
WHERE NOT EXISTS
(
    SELECT 1
    FROM Products P
    WHERE P.ProductName = V.ProductName
);
GO

SELECT * FROM Products
GO

-- Work with filters.
-- Search for a specific customer.
-- SQL
SELECT *
FROM Customers
WHERE FullName = 'Joao Silva';

-- Products over R$ 300.
-- SQL
SELECT *
FROM Products
WHERE Price > 300;

-- Products with more than 10 in stock.
-- SQL
SELECT *
FROM Products
WHERE StockQuantity > 10;

-- Sort results

-- Products from most expensive to least expensive.
-- SQL
SELECT *
FROM Products
ORDER BY Price DESC;

-- Clients in alphabetical order.
-- SQL
SELECT *
FROM Customers
ORDER BY FullName ASC;

-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Lesson 4 - SQL Server: UPDATE and DELETE.
-- Lesson 4 - SQL Server: UPDATE and DELETE.
-- =========================================================

-- Checking if the correct database is being used
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- Updating the phone record for Customers using UPDATE.
-- SQL
UPDATE Customers
SET Phone = '21988887777'
WHERE Email = 'joao@email.com';
GO

-- checking.
SELECT *
FROM Customers
WHERE Email = 'joao@email.com';

-- Updating the Price for Products using UPDATE.
-- SQL
UPDATE Products
SET Price = 4999.90
WHERE ProductName = 'Notebook Dell';
GO

-- checking.
SELECT ProductName, Price
FROM Products
WHERE ProductName = 'Notebook Dell';

-- UPDATE with multiple columns
-- SQL
UPDATE Products
SET
    Price = 150.00,
    StockQuantity = 60
WHERE ProductName = 'Mouse Logitech';
GO

-- checking.
SELECT ProductName, Price, StockQuantity
FROM Products
WHERE ProductName = 'Mouse Logitech';


-- WARNING: never execute UPDATE or DELETE, without checking the WHERE condition.

-- DELETE: delete records "!* Never perform an UPDATE or DELETE without checking the "WHERE" condition, if you forget it will delete all records from the table *!."
-- SQL
DELETE FROM Customers
WHERE Email = 'pedro@email.com';
GO

-- checking.
SELECT *
FROM Customers
WHERE Email = 'pedro@email.com';

-- Transactions: BEGIN TRANSACTION. A professional best practice is to use transactions to test changes before committing them.
-- Transactions: BEGIN TRANSACTION — it is a professional best practice to use transactions to test changes before committing them.
-- SQL
BEGIN TRANSACTION;

UPDATE Products
SET Price = 999.90
WHERE ProductName = 'Mouse Logitech';

-- Check the change before rolling it back.
SELECT *
FROM Products
WHERE ProductName = 'Mouse Logitech';

-- Undo the change within the transaction.
ROLLBACK TRANSACTION;
GO


-- Practical exercise: Now try to solve these challenges on your own.
-- Challenges for Lesson 04
-- 1. Update Maria Santos's phone number to 21977776666.
-- 2. Increase the price of the Samsung monitor to R$ 1,500.00.
-- 3. Update the stock for the Dell laptop to 25 units.
-- 4. Consult client Ana Costa before making any changes.
-- 5. Create a transaction that changes the price of the Logitech keyboard, and then undo the change using ROLLBACK.

-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Lesson 5 - SQL Operators and Advanced Filtering
-- Lesson 5 – SQL Operators and Advanced Filtering.
-- =========================================================

-- Learning Objectives
-- - Understand SQL comparison and logical operators.
-- - Apply advanced filtering conditions.
-- - Search records using patterns and ranges.
-- - Identify NULL and non-NULL values.

-- SQL Operators
-- ---       |        ---                          |     ---           |
-- IN             | Matches values in a list            | Compara valores de uma lista |
-- NOT IN         | Excludes values from a list         | Exclui valores de uma lista |
-- BETWEEN        | Filters a range of values           | Filtra um intervalo de valores |
-- IS NULL        | Finds NULL values                   | Localiza valores nulos |
-- IS NOT NULL    | Finds non-NULL values               | Localiza valores preenchidos |

-- Practical Examples
-- Checking if the correct database is being used.
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- AND: Both conditions must be true.
-- SQL
SELECT ProductName, Price, StockQuantity
FROM Products
WHERE Price > 300 AND StockQuantity > 10;
GO

-- OR: At least one condition must be true.
-- SQL
SELECT ProductName, Price
FROM Products
WHERE Price < 200
OR Price > 1000;
GO

-- IN: Search for specific values.
-- SQL
SELECT *
FROM Products
WHERE ProductName IN (
    'Notebook Dell',
    'Mouse Logitech'
);
GO

-- NOT IN: Exclude specific values.
-- SQL
SELECT *
FROM Products
WHERE ProductName NOT IN (
    'Notebook Dell',
    'Mouse Logitech'
);
GO

-- BETWEEN: Filter products by price range.
-- SQL
SELECT ProductName, Price
FROM Products
WHERE Price BETWEEN 100 AND 1500;
GO

-- LIKE: Names starting with M.
-- SQL
SELECT *
FROM Customers
WHERE FullName LIKE 'M%';
GO

-- Names containing "Sil".
-- SQL
SELECT *
FROM Customers
WHERE FullName LIKE '%Sil%';
GO

-- IS NULL: Customers without phone numbers
-- SQL
SELECT *
FROM Customers
WHERE Phone IS NULL;
GO

-- IS NOT NULL: Customers with phone numbers.
-- SQL
SELECT *
FROM Customers
WHERE Phone IS NOT NULL;
GO


-- Practical Exercises
-- 1. Find products with a price greater than R$ 500 and stock greater than 10.
-- 2. Find products with prices between R$ 100 and R$ 2,000.
-- 3. Find customers whose names start with the letter M.
-- 4. List products excluding Notebook Dell and Mouse Logitech.



-- Important Notes
-- - BETWEEN includes both boundary values.
-- - LIKE uses `%` to represent any sequence of characters.
-- - LIKE uses `_` to represent a single character.
-- - NULL must be checked using IS NULL or IS NOT NULL, not `= NULL`.

-- - BETWEEN inclui os dois valores limites.
-- - LIKE uses `%` to represent any sequence of characters.
-- - LIKE uses `_` to represent a single character.
-- - NULL deve ser verificado com IS NULL ou IS NOT NULL, nunca com `= NULL`.


-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Lesson 6 – Aggregate Functions and GROUP BY.
-- =========================================================

-- ### 1. Learning Objectives.
-- - Calculate totals, averages and quantities.
-- - Group records using GROUP BY.
-- - Filter grouped results using HAVING.
-- - Understand aggregate functions.

-- ### 2. Aggregate Functions
-- Function | Description |
-- ---		|		  ---			|		---			|
-- COUNT() 	| Conta registros		| Counts records  |
-- MIN() 		| Retorna o menor valor | Returns the minimum value |
-- MAX() 		| Retorna o maior valor | Returns the maximum value |
-- GROUP BY 	| Agrupa registros		| Groups records |
-- HAVING 	| Filtra grupos         | Filters groups |

-- ### 3. Practical Examples
-- Checking if the correct database is being used
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- COUNT: Total customers.
-- SQL
SELECT COUNT(*) AS TotalCustomers
FROM Customers;
GO

-- COUNT: Total products.
-- SQL
SELECT COUNT(*) AS TotalProducts
FROM Products;
GO

-- SUM: Total inventory value.
-- SQL
SELECT SUM(Price * StockQuantity) AS TotalInventoryValue
FROM Products;
GO

-- AVG: Average product price.
-- SQL
SELECT AVG(Price) AS AveragePrice
FROM Products;
GO

-- MIN: Lowest product price.
-- SQL
SELECT MIN(Price) AS LowestPrice
FROM Products;
GO

-- MAX: Highest product price
-- SQL
SELECT MAX(Price) AS HighestPrice
FROM Products;
GO

-- GROUP BY: Group products by status
-- SQL
SELECT
    IsActive,
    COUNT(*) AS TotalProducts
FROM Products
GROUP BY IsActive;
GO

-- HAVING: Filter grouped results
-- SQL
SELECT
    IsActive,
    COUNT(*) AS TotalProducts
FROM Products
GROUP BY IsActive
HAVING COUNT(*) > 1;
GO

-- ### 4.Practical Exercises
-- 1. Count all registered customers.
-- 2. Calculate the average product price.
-- 3. Find the most expensive product.
-- 4. Find the cheapest product.
-- 5. Calculate the total inventory value.
-- 6. Group products by IsActive.
-- 7. Display only groups containing more than one product.

-- ### 5. Important Notes.
-- - WHERE filters individual rows before grouping.
-- - HAVING filters groups after GROUP BY.
-- - Aggregate functions can be combined with GROUP BY.


-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Lesson 7 – JOINs and Table Relationships.
-- =========================================================

-- ### 1. Learning Objectives
-- - Understand relational database relationships.
-- - Connect multiple tables using JOIN.
-- - Retrieve related information from different tables.
-- - Understand primary and foreign keys.

-- Tipos de JOIN

-- ---			|			---											  |		---			|
-- INNER JOIN			| Retorna registros correspondentes						  | Returns matching records |
-- LEFT JOIN | Returns all records from the left table |
-- RIGHT JOIN | Returns all records from the right table |
-- FULL OUTER JOIN | Returns matching and non-matching records |

-- Checking if the correct database is being used
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- ### 3. Create Orders Table
-- SQL
IF OBJECT_ID('dbo.Orders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders
    (
        OrderId INT IDENTITY(1,1) PRIMARY KEY,
        CustomerId INT NOT NULL,
        OrderDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        OrderStatus NVARCHAR(30) NOT NULL DEFAULT 'Pending',

        CONSTRAINT FK_Orders_Customers
            FOREIGN KEY (CustomerId)
            REFERENCES dbo.Customers(CustomerId)
    );
END;
GO

-- Create OrderItems Table.
-- SQL
IF OBJECT_ID('dbo.OrderItems', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderItems
    (
        OrderItemId INT IDENTITY(1,1) PRIMARY KEY,
        OrderId INT NOT NULL,
        ProductId INT NOT NULL,
        Quantity INT NOT NULL,
        UnitPrice DECIMAL(10,2) NOT NULL,

        CONSTRAINT FK_OrderItems_Orders
            FOREIGN KEY (OrderId)
            REFERENCES dbo.Orders(OrderId),

        CONSTRAINT FK_OrderItems_Products
            FOREIGN KEY (ProductId)
            REFERENCES dbo.Products(ProductId),

        CONSTRAINT CK_OrderItems_Quantity
            CHECK (Quantity > 0),

        CONSTRAINT CK_OrderItems_UnitPrice
            CHECK (UnitPrice >= 0)
    );
END;
GO

-- Insert Sample Orders.
-- Insert sample orders
-- SQL
INSERT INTO Orders (CustomerId, OrderStatus)
SELECT CustomerId, 'Completed'
FROM Customers
WHERE Email = 'joao@email.com'
AND NOT EXISTS (
    SELECT 1 FROM Orders
    WHERE CustomerId = Customers.CustomerId
);

INSERT INTO Orders (CustomerId, OrderStatus)
SELECT CustomerId, 'Pending'
FROM Customers
WHERE Email = 'maria@email.com'
AND NOT EXISTS (
    SELECT 1 FROM Orders
    WHERE CustomerId = Customers.CustomerId
);

INSERT INTO Orders (CustomerId, OrderStatus)
SELECT CustomerId, 'Processing'
FROM Customers
WHERE Email = 'ana@email.com'
AND NOT EXISTS (
    SELECT 1 FROM Orders
    WHERE CustomerId = Customers.CustomerId
);
GO

-- Retrieve orders and customer information
-- SQL
SELECT
    O.OrderId,
    C.FullName,
    O.OrderDate,
    O.OrderStatus
FROM Orders O
INNER JOIN Customers C
    ON O.CustomerId = C.CustomerId;
GO

-- Retrieve all customers, including customers without orders
-- SQL
SELECT
    C.CustomerId,
    C.FullName,
    O.OrderId,
    O.OrderStatus
FROM Customers C
LEFT JOIN Orders O
    ON C.CustomerId = O.CustomerId;
GO


-- Retrieve all orders and their customers
-- SQL
SELECT
    C.FullName,
    O.OrderId,
    O.OrderStatus
FROM Customers C
RIGHT JOIN Orders O
    ON C.CustomerId = O.CustomerId;
GO

-- Retrieve matching and non-matching records
-- SQL
SELECT
    C.FullName,
    O.OrderId,
    O.OrderStatus
FROM Customers C
FULL OUTER JOIN Orders O
    ON C.CustomerId = O.CustomerId;
GO

-- ### 10. Inserir Itens dos Pedidos
-- Insert two Logitech mice into each completed order
-- SQL
INSERT INTO OrderItems
    (OrderId, ProductId, Quantity, UnitPrice)
SELECT
    O.OrderId,
    P.ProductId,
    2,
    P.Price
FROM Orders O
INNER JOIN Products P
    ON P.ProductName = 'Mouse Logitech'
WHERE O.OrderStatus = 'Completed'
AND NOT EXISTS (
    SELECT 1
    FROM OrderItems OI
    WHERE OI.OrderId = O.OrderId
    AND OI.ProductId = P.ProductId
);
GO


-- ### 11. JOIN Multiple Tables
-- Retrieve order details
-- SQL
SELECT
    O.OrderId,
    C.FullName,
    P.ProductName,
    OI.Quantity,
    OI.UnitPrice,
    OI.Quantity * OI.UnitPrice AS Total
FROM Orders O
INNER JOIN Customers C
    ON O.CustomerId = C.CustomerId
INNER JOIN OrderItems OI
    ON O.OrderId = OI.OrderId
INNER JOIN Products P
    ON OI.ProductId = P.ProductId;
GO

-- ### 12. Practical Exercises
-- 1. List all customers and their orders.
-- Find customers who have placed orders.
-- 3. Find customers who have not placed orders.
-- 4. List products sold in each order.
-- 5. Calculate the total value of each order.

-- ### 13. Important Notes
-- - Primary keys uniquely identify records.
-- - Foreign keys establish relationships between tables.
-- - JOIN operations are fundamental for relational databases.
-- - Sample INSERT statements should be executed only once or protected against duplicates.


-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Lesson 8 – Subqueries and EXISTS.
-- =========================================================

-- ### 1. Objetivos de Aprendizagem

-- - Understand nested SQL queries.
-- - Use subqueries with WHERE and IN.
-- - Retrieve records using EXISTS.
-- - Identify records using NOT EXISTS.

-- ### 2. Subquery with WHERE
-- Checking if the correct database is being used
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- -- Products with prices above the average
-- SQL
SELECT
    ProductName,
    Price
FROM Products
WHERE Price > (
    SELECT AVG(Price)
    FROM Products
);
GO

-- ### 3. Subquery with IN.
-- -- Customers who have placed orders
-- SQL
SELECT
    FullName,
    Email
FROM Customers
WHERE CustomerId IN (
    SELECT CustomerId
    FROM Orders
);
GO

-- -- Customers without orders
-- SQL
SELECT
    FullName,
    Email
FROM Customers
WHERE CustomerId NOT IN (
    SELECT CustomerId
    FROM Orders
);
GO

-- -- Find customers with existing orders
-- SQL
SELECT
    C.FullName,
    C.Email
FROM Customers C
WHERE EXISTS (
    SELECT 1
    FROM Orders O
    WHERE O.CustomerId = C.CustomerId
);
GO

-- -- Find customers without orders
-- SQL
SELECT
    C.FullName,
    C.Email
FROM Customers C
WHERE NOT EXISTS (
    SELECT 1
    FROM Orders O
    WHERE O.CustomerId = C.CustomerId
);
GO

-- ### 7. Practical Exercises
-- 1. Find products with prices above the average.
-- 2. Find customers who have placed orders.
-- 3. Find customers without orders.
-- 4. Find products with prices greater than the average product price.
-- 5. Use EXISTS to find customers with completed orders.

-- ### 8. Important Notes
-- - A subquery is a query nested inside another query.
-- - EXISTS checks whether the subquery returns at least one row.
-- - NOT EXISTS is generally safer than NOT IN when NULL values may occur in the subquery.


-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Lesson 9 – SQL Views.
-- =========================================================

-- ### 1. Learning Objectives
-- - Understand SQL Views.
-- - Create reusable queries.
-- - Simplify reporting queries.
-- - Modify existing Views.

-- Checking if the correct database is being used.
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- ### 2. Create Customer Orders View.
-- SQL
CREATE OR ALTER VIEW dbo.vw_CustomerOrders
AS
SELECT
    C.CustomerId,
    C.FullName,
    C.Email,
    O.OrderId,
    O.OrderDate,
    O.OrderStatus
FROM Customers C
INNER JOIN Orders O
    ON C.CustomerId = O.CustomerId;
GO

-- ### 3. Consultar a View
-- SQL
SELECT *
FROM dbo.vw_CustomerOrders;
GO

-- ### 4. Criar View de Estoque
-- SQL
CREATE OR ALTER VIEW dbo.vw_ProductInventory
AS
SELECT
    ProductId,
    ProductName,
    Price,
    StockQuantity,
    Price * StockQuantity AS TotalInventoryValue
FROM Products;
GO

-- ### 5. Consultar Estoque
-- SQL
SELECT *
FROM dbo.vw_ProductInventory
ORDER BY TotalInventoryValue DESC;
GO

-- Practical Exercises
-- 1. Create a View containing customers with orders.
-- 2. Create a View showing products and inventory values.
-- 3. Query a View using WHERE.
-- 4. Sort View results by product price.
-- 5. Explain the difference between a table and a View.

-- ### 7. Important Notes
-- - A standard View stores a query definition, not an independent copy of the underlying data.
-- - Views can simplify complex queries.
-- - Views can be used in SELECT statements like tables.


-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Lesson 10 – Indexes and Query Performance.
-- =========================================================

-- ### 1. Learning Objectives
-- - Understand database indexes.
-- - Create nonclustered indexes.
-- - Analyze query execution plans.
-- - Understand index performance impacts.

-- Checking if the correct database is being used.
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- ### 2. Query Existing Indexes.
SELECT
    name,
    type_desc,
    is_unique
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.Customers');
GO

-- ### 3. Create Nonclustered Index.
-- -- Create an index for customer phone searches
-- SQL
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Customers_Phone'
    AND object_id = OBJECT_ID('dbo.Customers')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Customers_Phone
    ON Customers(Phone);
END;
GO

-- ### 4. Create a Product Index
-- SQL
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Products_ProductName'
    AND object_id = OBJECT_ID('dbo.Products')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Products_ProductName
    ON Products(ProductName);
END;
GO

-- ### 5. Query Using an Indexed Column.
-- SQL
SELECT
    ProductId,
    ProductName,
    Price
FROM Products
WHERE ProductName = 'Notebook Dell';
GO

-- ### 6. Execution Plan |
-- In SQL Server Management Studio:
-- 1. Open the SQL query.
-- 2. Press CTRL + M to enable the actual execution plan.
-- 3. Execute the query.
-- 4. Analyze the execution plan.


-- ---		|		   ---								  | 		---				|
-- Table Scan | Reads all table rows |
-- Index Scan | Scans index entries |
-- Key Lookup | Recupera colunas adicionais da tabela. 	  | Retrieves additional columns from the table |

-- 1. Create an index on Customers.Phone.
-- 2. Create an index on Products.Price.
-- 3. Query products by name.
-- 4. Query customers by phone.
-- 5. Compare execution plans before and after creating indexes.

-- ### 8. Important Notes
-- - Indexes can improve performance, but the optimizer chooses the execution plan based on statistics and estimated cost.
-- - Indexes require additional storage.
-- - Excessive indexes can negatively affect INSERT, UPDATE and DELETE operations.
-- - Existing UNIQUE constraints generally create supporting indexes automatically.


-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Lesson 11 – Transactions and Error Handling.
-- =========================================================

-- ### 1. Learning Objectives
-- - Understand SQL transactions.
-- - Commit and rollback database operations.
-- - Handle SQL errors using TRY...CATCH.
-- - Understand transaction states.

-- ### 2. Transaction Concepts.
-- ---			|		   ---      						 |		---				|
-- TRY...CATCH 		| Handles errors 							 | Trata erros |

-- Checking if the correct database is being used.
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- ### 3. Transaction with ROLLBACK
-- SQL
BEGIN TRANSACTION;
UPDATE Products
SET StockQuantity = StockQuantity - 2
WHERE ProductName = 'Mouse Logitech'
AND StockQuantity >= 2;

SELECT *
FROM Products
WHERE ProductName = 'Mouse Logitech';

-- Undo changes
ROLLBACK TRANSACTION;
GO

-- WARNING: this example permanently adds 5 units to the Logitech Mouse stock.
-- Run only if you want to keep this database change.
-- SQL
BEGIN TRANSACTION;

UPDATE Products
SET StockQuantity = StockQuantity + 5
WHERE ProductName = 'Mouse Logitech';

COMMIT TRANSACTION;
GO

-- Tratamento de Erros
-- SQL
BEGIN TRY
	BEGIN TRANSACTION;
		UPDATE Products
        SET Price = Price
        WHERE ProductName = 'Mouse Logitech';
    IF @@ROWCOUNT = 0
        THROW 50001, 'Product not found.', 1;
    COMMIT TRANSACTION;
    PRINT 'Transaction completed successfully';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- ### 6. Practical Exercises
-- 1. Create a transaction that updates a product price.
-- 2. Use ROLLBACK to undo the change.
-- 3. Use COMMIT to confirm another change.
-- 4. Create a TRY...CATCH structure.
-- 5. Generate a controlled error and capture the error message.

-- ### 7. Important Notes
-- - COMMIT permanently confirms the transaction changes.
-- - ROLLBACK undoes uncommitted transaction changes.
-- - TRY...CATCH helps handle runtime errors.
-- - Always consider transaction boundaries when working with multiple tables.

--
--


-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Lesson 12 – Stored Procedures.
-- =========================================================

-- ### 1. Learning Objectives

-- - Create and execute Stored Procedures.
-- - Use input parameters.
-- - Retrieve data using Stored Procedures.
-- - Perform database updates through procedures.
-- - Handle errors using THROW.

-- Criar Procedure de Clientes
-- SQL
USE SQLRoadmapTrainingDB;
GO

CREATE OR ALTER PROCEDURE dbo.usp_GetAllCustomers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CustomerId,
        FullName,
        Email,
        Phone
    FROM Customers;
END;
GO

-- ### 3. Execute Stored Procedure
-- SQL
EXEC dbo.usp_GetAllCustomers;
GO

-- ### 4. Stored Procedure with Parameters
-- SQL
CREATE OR ALTER PROCEDURE dbo.usp_GetCustomerByEmail
    @Email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CustomerId,
        FullName,
        Email,
        Phone
    FROM Customers
    WHERE Email = @Email;
END;
GO

-- SQL
EXEC dbo.usp_GetCustomerByEmail
    @Email = 'joao@email.com';
GO

-- ### 5. Product Stored Procedure
-- SQL
CREATE OR ALTER PROCEDURE dbo.usp_GetProductsByPrice
    @MinimumPrice DECIMAL(10,2),
    @MaximumPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ProductId,
        ProductName,
        Price,
        StockQuantity
    FROM Products
    WHERE Price BETWEEN @MinimumPrice AND @MaximumPrice
    ORDER BY Price ASC;
END;
GO

-- SQL
EXEC dbo.usp_GetProductsByPrice
    @MinimumPrice = 100,
    @MaximumPrice = 2000;
GO

-- ### 6. Stored Procedure with UPDATE
-- SQL
CREATE OR ALTER PROCEDURE dbo.usp_UpdateProductPrice
    @ProductId INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    IF @NewPrice < 0
        THROW 50001, 'Price cannot be negative.', 1;
    UPDATE Products
    SET Price = @NewPrice
    WHERE ProductId = @ProductId;
    IF @@ROWCOUNT = 0
        THROW 50002, 'Product not found.', 1;
END;
GO

-- Run only after checking the ProductId and deciding on the new price.
-- This example permanently changes data.
-- SQL

-- ### 7. Practical Exercises.
-- 1. Create a Stored Procedure to retrieve all products.
-- 2. Create a Stored Procedure to retrieve a product by ID.
-- 3. Create a Stored Procedure that receives a minimum stock quantity.
-- 4. Create a Stored Procedure to update product stock.
-- 5. Use THROW to handle a product not found error.

-- ### 8. Important Notes.
-- - Stored Procedures are reusable SQL code blocks.
-- - Parameters allow dynamic execution.
-- - CREATE OR ALTER allows procedures to be created or updated.
-- - Use the `usp_` naming convention for user-defined stored procedures.
-- - Avoid concatenating user input into dynamic SQL. Use parameters to help prevent SQL injection.


-- =========================================================

-- =========================================================
-- SQL Developer Roadmap
-- Module 01 - Final Review.
-- Module 01 – Final Review.
-- =========================================================

-- At the end of this module, the developer should be able to:
-- - Create and manage SQL Server databases.
-- - Design relational tables.
-- - Define primary keys, foreign keys and constraints.
-- - Insert, update and delete records.
-- - Write SQL queries using SELECT and WHERE.
-- - Apply logical and comparison operators.
-- - Use aggregate functions and GROUP BY.
-- - Relate tables using JOIN.
-- - Write subqueries and EXISTS statements.
-- - Create and query Views.
-- - Create indexes and analyze execution plans.
-- - Manage transactions and handle errors.
-- - Create and execute Stored Procedures.




---
/*
## Estrutura sugerida no GitHub | Suggested GitHub Structure

```text
SQL-Developer-Roadmap/
│
├── README.md
│
└── Module-01-SQL-Fundamentals/
    └── Modulo_01_Fundamentos_de_SQL.sql
```

**Projeto | Project:** SQL Developer Roadmap
**Módulo | Module:** 01 – Fundamentos de SQL Server | SQL Server Fundamentals
**Status | Status:** Lições 01–12 incluídas. Execute cada seção conforme as instruções e observações.
**Purpose:** Build practical SQL Server skills through hands-on exercises, technical documentation and database scenarios relevant to C#, .NET and Entity Framework Core.
*/


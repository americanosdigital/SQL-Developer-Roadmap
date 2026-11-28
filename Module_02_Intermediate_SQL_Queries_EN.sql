
/*
===============================================================================
SQL DEVELOPER ROADMAP
MODULE 02 — INTERMEDIATE SQL QUERIES
Lessons 13 to 20
===============================================================================

Database used: SQLRoadmapTrainingDB
Prerequisite: complete Module 01 before running this module.

IMPORTANT:
- Run the lessons in order, one section at a time.
- This module was developed for SQL Server / SSMS.
- The main examples are read-only queries (SELECT).
- Challenges are commented out so you can practice without changing data.

===============================================================================
INITIAL SETUP
===============================================================================
*/

USE SQLRoadmapTrainingDB;
GO

SET NOCOUNT ON;
GO

/*
Verify that the required tables exist.
The queries in this module use:
Customers, Products, Orders, and OrderItems.
*/
IF OBJECT_ID('dbo.Customers', 'U') IS NULL
   OR OBJECT_ID('dbo.Products', 'U') IS NULL
   OR OBJECT_ID('dbo.Orders', 'U') IS NULL
   OR OBJECT_ID('dbo.OrderItems', 'U') IS NULL
BEGIN
    THROW 50001, 'One or more tables do not exist. Run Module 01 first.', 1;
END;
GO

/*
===============================================================================
LESSON 13 — CASE WHEN
===============================================================================

Goal:
Create conditional classifications in query results without changing data.

C# equivalent concept:
if / else if / else
*/

-- 13.1 Classify products by price range
SELECT
    ProductId,
    ProductName,
    Price,
    CASE
        WHEN Price >= 3000 THEN 'Premium Product'
        WHEN Price >= 1000 THEN 'Intermediate Product'
        ELSE 'Budget Product'
    END AS PriceCategory
FROM dbo.Products
ORDER BY Price DESC;
GO

-- 13.2 Classify products by stock quantity
SELECT
    ProductId,
    ProductName,
    StockQuantity,
    CASE
        WHEN StockQuantity = 0 THEN 'Out of stock'
        WHEN StockQuantity <= 10 THEN 'Low stock'
        WHEN StockQuantity <= 30 THEN 'Medium stock'
        ELSE 'High stock'
    END AS StockStatus
FROM dbo.Products
ORDER BY StockQuantity;
GO

-- 13.3 Combine CASE WHEN with AND
SELECT
    ProductName,
    Price,
    StockQuantity,
    CASE
        WHEN Price >= 3000 AND StockQuantity > 0
            THEN 'Premium product available'
        WHEN Price >= 3000 AND StockQuantity = 0
            THEN 'Premium product unavailable'
        WHEN StockQuantity = 0
            THEN 'Unavailable'
        ELSE 'Regular product'
    END AS ProductStatus
FROM dbo.Products;
GO

-- 13.4 Conditional aggregation: count available and unavailable products
SELECT
    COUNT(*) AS TotalProducts,
    SUM(CASE WHEN StockQuantity > 0 THEN 1 ELSE 0 END) AS AvailableProducts,
    SUM(CASE WHEN StockQuantity = 0 THEN 1 ELSE 0 END) AS OutOfStockProducts
FROM dbo.Products;
GO

-- 13.5 Classify customers by status
SELECT
    CustomerId,
    FullName,
    Email,
    IsActive,
    CASE
        WHEN IsActive = 1 THEN 'Active customer'
        ELSE 'Inactive customer'
    END AS CustomerStatus
FROM dbo.Customers
ORDER BY FullName;
GO

/*
CHALLENGE 13:
Write a query returning ProductName, Price, StockQuantity, and two columns:
1) PriceLevel: 'Premium' for price >= 4000; 'Intermediate' for price
   >= 1000; otherwise, 'Basic'.
2) StockLevel: 'Unavailable' for stock = 0; 'Low' for stock between
   1 and 10; 'Available' for stock > 10.

Write your solution below.
*/

-- SELECT ...
-- FROM dbo.Products;
-- GO

/*
===============================================================================
LESSON 14 — CTE (COMMON TABLE EXPRESSION)
===============================================================================

Goal:
Organize complex queries into named blocks that can be referenced within
a single SQL statement.

A CTE starts with WITH and must be followed immediately by the statement
that uses it.
*/

-- 14.1 CTE to classify products by total inventory value
;WITH ProductInventory AS
(
    SELECT
        ProductId,
        ProductName,
        Price,
        StockQuantity,
        Price * StockQuantity AS InventoryValue
    FROM dbo.Products
)
SELECT
    ProductName,
    Price,
    StockQuantity,
    InventoryValue
FROM ProductInventory
ORDER BY InventoryValue DESC;
GO

-- 14.2 CTE to calculate each order total
;WITH OrderTotals AS
(
    SELECT
        O.OrderId,
        O.CustomerId,
        O.OrderDate,
        O.OrderStatus,
        SUM(OI.Quantity * OI.UnitPrice) AS OrderTotal
    FROM dbo.Orders AS O
    INNER JOIN dbo.OrderItems AS OI
        ON OI.OrderId = O.OrderId
    GROUP BY
        O.OrderId,
        O.CustomerId,
        O.OrderDate,
        O.OrderStatus
)
SELECT
    OrderId,
    CustomerId,
    OrderDate,
    OrderStatus,
    OrderTotal
FROM OrderTotals
ORDER BY OrderDate DESC;
GO

-- 14.3 CTE to find customers who have placed orders
;WITH CustomersWithOrders AS
(
    SELECT DISTINCT CustomerId
    FROM dbo.Orders
)
SELECT
    C.CustomerId,
    C.FullName,
    C.Email
FROM dbo.Customers AS C
INNER JOIN CustomersWithOrders AS CWO
    ON CWO.CustomerId = C.CustomerId
ORDER BY C.FullName;
GO

/*
CHALLENGE 14:
Create a CTE named CustomerOrderCount to count how many orders each customer
has. Display CustomerId, FullName, and TotalOrders, including customers
with no orders. Hint: use LEFT JOIN and COUNT(O.OrderId).
*/

/*
===============================================================================
LESSON 15 — UNION AND UNION ALL
===============================================================================

Goal:
Combine the results of two or more compatible queries.

Rules:
- Each SELECT must return the same number of columns.
- Corresponding columns must have compatible data types.
- UNION removes duplicate rows.
- UNION ALL keeps duplicate rows and usually avoids the cost of removing them.
*/

-- 15.1 UNION: combine customer names and product names
SELECT
    FullName AS ItemName,
    'Customer' AS ItemType
FROM dbo.Customers

UNION

SELECT
    ProductName AS ItemName,
    'Product' AS ItemType
FROM dbo.Products
ORDER BY ItemType, ItemName;
GO

-- 15.2 UNION ALL: combine pending and completed orders
SELECT
    OrderId,
    OrderDate,
    OrderStatus
FROM dbo.Orders
WHERE OrderStatus = 'Pending'

UNION ALL

SELECT
    OrderId,
    OrderDate,
    OrderStatus
FROM dbo.Orders
WHERE OrderStatus = 'Completed'
ORDER BY OrderDate DESC;
GO

-- 15.3 UNION ALL with labels to create a simple summary
SELECT
    'Customers' AS Category,
    COUNT(*) AS TotalRecords
FROM dbo.Customers

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM dbo.Products

UNION ALL

SELECT
    'Orders',
    COUNT(*)
FROM dbo.Orders;
GO

/*
CHALLENGE 15:
Combine products with low stock (StockQuantity between 1 and 10) and
out-of-stock products (StockQuantity = 0) in one query.
Return ProductId, ProductName, and a StockGroup column.
Use UNION ALL.
*/

/*
===============================================================================
LESSON 16 — WINDOW FUNCTIONS
===============================================================================

Goal:
Calculate values over a set of rows without reducing the result to a single
row, as commonly happens with GROUP BY.

OVER() defines the window of rows used by the function.
*/

-- 16.1 Display each product and the total inventory value for all products
SELECT
    ProductId,
    ProductName,
    Price,
    StockQuantity,
    Price * StockQuantity AS InventoryValue,
    SUM(Price * StockQuantity) OVER () AS TotalInventoryValue
FROM dbo.Products
ORDER BY ProductName;
GO

-- 16.2 Calculate the average price and compare each product with the average
SELECT
    ProductId,
    ProductName,
    Price,
    AVG(Price) OVER () AS AverageProductPrice,
    Price - AVG(Price) OVER () AS DifferenceFromAverage
FROM dbo.Products
ORDER BY Price DESC;
GO

-- 16.3 Calculate a running total of order items within each order
SELECT
    OrderId,
    OrderItemId,
    ProductId,
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS LineTotal,
    SUM(Quantity * UnitPrice) OVER
    (
        PARTITION BY OrderId
        ORDER BY OrderItemId
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningOrderTotal
FROM dbo.OrderItems
ORDER BY OrderId, OrderItemId;
GO

-- 16.4 LAG: compare each order date with the customer's previous order date
SELECT
    CustomerId,
    OrderId,
    OrderDate,
    LAG(OrderDate) OVER
    (
        PARTITION BY CustomerId
        ORDER BY OrderDate, OrderId
    ) AS PreviousOrderDate
FROM dbo.Orders
ORDER BY CustomerId, OrderDate, OrderId;
GO

/*
CHALLENGE 16:
Display each order and its total, along with a column showing the sum of
all order totals. Use SUM(...) OVER().
Hint: first calculate each order total in a CTE, then apply the window
function to the CTE result.
*/

/*
===============================================================================
LESSON 17 — ROW_NUMBER, RANK, AND DENSE_RANK
===============================================================================

Goal:
Number and rank rows according to a sort order.

Differences:
- ROW_NUMBER: always generates a unique sequential number.
- RANK: ties receive the same rank and leave gaps in the sequence.
- DENSE_RANK: ties receive the same rank without leaving gaps.
*/

-- 17.1 Compare the three functions when ranking product prices
SELECT
    ProductName,
    Price,
    ROW_NUMBER() OVER (ORDER BY Price DESC, ProductId) AS RowNumberValue,
    RANK() OVER (ORDER BY Price DESC) AS RankValue,
    DENSE_RANK() OVER (ORDER BY Price DESC) AS DenseRankValue
FROM dbo.Products
ORDER BY Price DESC, ProductId;
GO

-- 17.2 Number each customer's orders from newest to oldest
SELECT
    CustomerId,
    OrderId,
    OrderDate,
    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerId
        ORDER BY OrderDate DESC, OrderId DESC
    ) AS OrderSequence
FROM dbo.Orders
ORDER BY CustomerId, OrderSequence;
GO

-- 17.3 Return only the most recent order for each customer
;WITH RankedOrders AS
(
    SELECT
        CustomerId,
        OrderId,
        OrderDate,
        OrderStatus,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerId
            ORDER BY OrderDate DESC, OrderId DESC
        ) AS RowNum
    FROM dbo.Orders
)
SELECT
    CustomerId,
    OrderId,
    OrderDate,
    OrderStatus
FROM RankedOrders
WHERE RowNum = 1
ORDER BY CustomerId;
GO

/*
CHALLENGE 17:
Create a product ranking by Price, from highest to lowest.
Display ProductName, Price, RANK, and DENSE_RANK.
*/

/*
===============================================================================
LESSON 18 — PARTITION BY
===============================================================================

Goal:
Split rows into groups (partitions) so a window function is calculated
separately for each group without removing individual rows.
*/

-- 18.1 Count orders per customer without collapsing the result into one row
SELECT
    CustomerId,
    OrderId,
    OrderDate,
    COUNT(*) OVER (PARTITION BY CustomerId) AS TotalOrdersByCustomer
FROM dbo.Orders
ORDER BY CustomerId, OrderDate;
GO

-- 18.2 Calculate the total number of units in each order
SELECT
    OrderId,
    OrderItemId,
    ProductId,
    Quantity,
    SUM(Quantity) OVER (PARTITION BY OrderId) AS TotalUnitsInOrder
FROM dbo.OrderItems
ORDER BY OrderId, OrderItemId;
GO

-- 18.3 Rank products by price within each stock group
;WITH ProductsByStock AS
(
    SELECT
        ProductId,
        ProductName,
        Price,
        StockQuantity,
        CASE
            WHEN StockQuantity = 0 THEN 'Out of stock'
            WHEN StockQuantity <= 10 THEN 'Low stock'
            ELSE 'Available stock'
        END AS StockGroup
    FROM dbo.Products
)
SELECT
    ProductName,
    Price,
    StockGroup,
    ROW_NUMBER() OVER
    (
        PARTITION BY StockGroup
        ORDER BY Price DESC, ProductId
    ) AS PositionWithinStockGroup
FROM ProductsByStock
ORDER BY StockGroup, PositionWithinStockGroup;
GO

/*
CHALLENGE 18:
Display OrderId, ProductId, Quantity, and the total number of units per order.
Use SUM(Quantity) OVER (PARTITION BY OrderId).
*/

/*
===============================================================================
LESSON 19 — ADVANCED JOIN QUERIES
===============================================================================

Goal:
Combine JOINs, aggregations, and correlated queries to answer questions
that are closer to real-world scenarios.
*/

-- 19.1 Detailed report: customer, order, product, and item value
SELECT
    C.FullName,
    O.OrderId,
    O.OrderDate,
    O.OrderStatus,
    P.ProductName,
    OI.Quantity,
    OI.UnitPrice,
    OI.Quantity * OI.UnitPrice AS LineTotal
FROM dbo.Customers AS C
INNER JOIN dbo.Orders AS O
    ON O.CustomerId = C.CustomerId
INNER JOIN dbo.OrderItems AS OI
    ON OI.OrderId = O.OrderId
INNER JOIN dbo.Products AS P
    ON P.ProductId = OI.ProductId
ORDER BY O.OrderDate DESC, O.OrderId;
GO

-- 19.2 Customers with no orders: LEFT JOIN with IS NULL
SELECT
    C.CustomerId,
    C.FullName,
    C.Email
FROM dbo.Customers AS C
LEFT JOIN dbo.Orders AS O
    ON O.CustomerId = C.CustomerId
WHERE O.OrderId IS NULL
ORDER BY C.FullName;
GO

-- 19.3 Number of orders and total spending per customer
;WITH CustomerPurchases AS
(
    SELECT
        O.CustomerId,
        COUNT(DISTINCT O.OrderId) AS TotalOrders,
        SUM(OI.Quantity * OI.UnitPrice) AS TotalSpent
    FROM dbo.Orders AS O
    INNER JOIN dbo.OrderItems AS OI
        ON OI.OrderId = O.OrderId
    GROUP BY O.CustomerId
)
SELECT
    C.CustomerId,
    C.FullName,
    COALESCE(CP.TotalOrders, 0) AS TotalOrders,
    COALESCE(CP.TotalSpent, 0) AS TotalSpent
FROM dbo.Customers AS C
LEFT JOIN CustomerPurchases AS CP
    ON CP.CustomerId = C.CustomerId
ORDER BY TotalSpent DESC, C.FullName;
GO

-- 19.4 OUTER APPLY: latest order for each customer, when one exists
SELECT
    C.CustomerId,
    C.FullName,
    LastOrder.OrderId,
    LastOrder.OrderDate,
    LastOrder.OrderStatus
FROM dbo.Customers AS C
OUTER APPLY
(
    SELECT TOP (1)
        O.OrderId,
        O.OrderDate,
        O.OrderStatus
    FROM dbo.Orders AS O
    WHERE O.CustomerId = C.CustomerId
    ORDER BY O.OrderDate DESC, O.OrderId DESC
) AS LastOrder
ORDER BY C.FullName;
GO

/*
Note:
- CROSS APPLY removes rows from the left-side source when the applied
  subquery returns no rows.
- OUTER APPLY keeps rows from the left-side source and returns NULL for
  the applied expression's columns when there is no match.

CHALLENGE 19:
Create a report with all customers, including customers without orders,
showing FullName, order count, and total spending.
Use LEFT JOIN and aggregation. Avoid counting duplicated order-item rows
as separate orders.
*/

/*
===============================================================================
LESSON 20 — PAGINATION WITH OFFSET AND FETCH
===============================================================================

Goal:
Return query results in pages, a common feature in APIs and web applications.

Pagination requires ORDER BY to define a consistent sort order.
OFFSET specifies how many rows to skip.
FETCH NEXT specifies how many rows to return.
*/

-- 20.1 First page: 3 products
SELECT
    ProductId,
    ProductName,
    Price
FROM dbo.Products
ORDER BY ProductId
OFFSET 0 ROWS
FETCH NEXT 3 ROWS ONLY;
GO

-- 20.2 Second page: 3 products
SELECT
    ProductId,
    ProductName,
    Price
FROM dbo.Products
ORDER BY ProductId
OFFSET 3 ROWS
FETCH NEXT 3 ROWS ONLY;
GO

-- 20.3 Pagination using variables
DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

IF @PageNumber < 1 OR @PageSize < 1
    THROW 50002, 'PageNumber and PageSize must be greater than zero.', 1;

DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

SELECT
    ProductId,
    ProductName,
    Price,
    StockQuantity
FROM dbo.Products
ORDER BY ProductName, ProductId
OFFSET @Offset ROWS
FETCH NEXT @PageSize ROWS ONLY;
GO

-- 20.4 Paginate orders with customer names
DECLARE @OrderPageNumber INT = 1;
DECLARE @OrderPageSize INT = 5;

SELECT
    O.OrderId,
    C.FullName,
    O.OrderDate,
    O.OrderStatus
FROM dbo.Orders AS O
INNER JOIN dbo.Customers AS C
    ON C.CustomerId = O.CustomerId
ORDER BY O.OrderDate DESC, O.OrderId DESC
OFFSET (@OrderPageNumber - 1) * @OrderPageSize ROWS
FETCH NEXT @OrderPageSize ROWS ONLY;
GO

/*
CHALLENGE 20:
Write a query to return the third page of customers, with 5 customers per page.
Sort by FullName and CustomerId.
Hint: OFFSET = (PageNumber - 1) * PageSize.
*/

/*
===============================================================================
FINAL REVIEW — MODULE 02
===============================================================================

After completing this module, you will have practiced:

[ ] CASE WHEN
[ ] CTEs (Common Table Expressions)
[ ] UNION and UNION ALL
[ ] Window Functions
[ ] ROW_NUMBER, RANK, and DENSE_RANK
[ ] PARTITION BY
[ ] Advanced JOINs, LEFT JOIN, and APPLY
[ ] Pagination with OFFSET and FETCH

KEY CONCEPTS:
1. CASE WHEN creates conditional values in query results.
2. A CTE organizes a query and is scoped to the following statement.
3. UNION removes duplicates; UNION ALL keeps duplicates.
4. Window Functions calculate over a window without collapsing rows.
5. PARTITION BY restarts the calculation for each group.
6. OFFSET/FETCH requires ORDER BY for consistent pagination.

NEXT STEP:
Review the examples, solve the challenges, and commit the file to GitHub.
You do not need to modify database tables to complete this module.

===============================================================================
END OF MODULE 02 — INTERMEDIATE SQL QUERIES
===============================================================================
*/

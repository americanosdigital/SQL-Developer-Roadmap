
/*
============================================================
SQL DEVELOPER ROADMAP
MODULO 06 - INTEGRACAO, ETL E PROJETO PRATICO
Banco: SQLRoadmapTrainingDB
Aulas: 45 a 52
============================================================

PRE-REQUISITO:
Modulo 05 - Aula 37.
Tabelas utilizadas:
Roadmap_Customers
Roadmap_Products
Roadmap_SalesOrders
Roadmap_SalesOrderItems

Execute uma aula por vez.
============================================================
*/

USE SQLRoadmapTrainingDB;
GO

/*
============================================================
AULA 45 - INTRODUCAO A ETL E TABELAS DE STAGING
============================================================

ETL significa:
E - Extract: extrair dados da origem.
T - Transform: limpar e transformar dados.
L - Load: carregar os dados no destino.

Staging: area temporaria ou intermediaria para receber
os dados antes da validacao e carga final.
*/

-- 1.1 - Tabela de controle das execucoes ETL.
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

-- 1.2 - Staging de clientes.
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

-- 1.3 - Staging de produtos.
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

-- 1.4 - Staging dos itens de venda.
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

-- 1.5 - Dimensao de clientes.
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

-- 1.6 - Dimensao de produtos.
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

-- 1.7 - Tabela fato de vendas.
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

-- 1.8 - Tabela para registrar registros rejeitados.
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

-- Conferindo a estrutura criada.
SELECT name
FROM sys.tables
WHERE name LIKE 'RoadmapETL_%'
ORDER BY name;
GO

/*
============================================================
AULA 46 - IMPORTACAO E QUALIDADE DE DADOS
============================================================

Antes de carregar os dados, precisamos validar:
- Campos obrigatorios.
- Valores nulos.
- Valores duplicados.
- Precos e quantidades validos.
- Relacionamentos existentes.

A demonstracao abaixo cria um lote de staging
a partir das tabelas de origem.
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

SELECT @BatchId AS BatchIdCreated;
GO

-- Verificando a qualidade dos dados de staging.
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

-- Exemplo de validacao de duplicidade de e-mail.
SELECT
    Email,
    COUNT(*) AS DuplicateCount
FROM dbo.RoadmapETL_StgCustomers
GROUP BY Email
HAVING COUNT(*) > 1;
GO

/*
IMPORTACAO DE CSV - EXEMPLO

BULK INSERT exige um arquivo acessivel ao servico SQL Server
e permissoes adequadas. Ajuste o caminho e o formato do arquivo.

Exemplo de comando, nao executar sem adaptar:

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
AULA 47 - CARGA INCREMENTAL E ATUALIZACAO DE DIMENSOES
============================================================

Carga incremental:
- Atualiza registros que ja existem.
- Insere registros novos.
- Evita recarregar toda a tabela de destino.

O exemplo utiliza o lote mais recente.
*/

DECLARE @LatestBatchId UNIQUEIDENTIFIER;

SELECT TOP (1) @LatestBatchId = BatchId
FROM dbo.RoadmapETL_RunLog
WHERE Status = 'Extracted'
ORDER BY StartedAt DESC;

IF @LatestBatchId IS NOT NULL
BEGIN
    -- Atualizando clientes existentes.
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

    -- Inserindo novos clientes.
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

    -- Atualizando produtos existentes.
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

    -- Inserindo novos produtos.
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
AULA 48 - TABELA FATO E MODELO ANALITICO
============================================================

Uma tabela fato armazena eventos ou medidas de negocio.
As dimensoes fornecem o contexto para analisar esses eventos.

Neste projeto:
- FactSales: vendas.
- DimCustomer: clientes.
- DimProduct: produtos.
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

-- Consultando o modelo analitico.
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
AULA 49 - STORED PROCEDURE PARA PROCESSO ETL
============================================================

A procedure abaixo automatiza:
1. Extracao.
2. Staging.
3. Validacao.
4. Atualizacao e insercao das dimensoes.
5. Carga da tabela fato.
6. Registro de auditoria.

O processamento utiliza transacao para proteger
as operacoes de carga.
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
AULA 50 - AUDITORIA, MONITORAMENTO E ERROS
============================================================

A procedure de carga registra:
- Identificador do lote.
- Inicio e fim da execucao.
- Status.
- Quantidade extraida.
- Quantidade carregada.
- Mensagem de erro.
*/

-- Execute o processo ETL.
EXEC dbo.RoadmapETL_RunSalesLoad;
GO

-- Historico de execucoes.
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

-- Registros rejeitados.
SELECT *
FROM dbo.RoadmapETL_RejectedRows
ORDER BY RejectedAt DESC;
GO

-- Quantidade de registros por tabela de destino.
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
AULA 51 - INTEGRACAO SQL SERVER COM APLICACOES .NET
============================================================

Aplicacoes .NET podem acessar o SQL Server usando:
- ADO.NET.
- Microsoft.Data.SqlClient.
- Entity Framework Core.
- Stored procedures.

Boa pratica:
Utilizar parametros em vez de concatenar valores
diretamente no comando SQL.
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

-- Teste da procedure.
EXEC dbo.RoadmapETL_GetSalesReport
    @StartDate = '2020-01-01',
    @EndDate = '2030-12-31',
    @CustomerKey = NULL;
GO

/*
EXEMPLO CONCEITUAL EM C# COM Microsoft.Data.SqlClient

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

A connection string deve ser armazenada com seguranca,
por exemplo, em configuracao protegida ou secret manager.
Nao coloque senhas diretamente no codigo-fonte.
*/

/*
============================================================
AULA 52 - PROJETO FINAL: CONSULTAS ANALITICAS E RELATORIOS
============================================================

Objetivo:
Criar consultas que respondam perguntas de negocio:
- Quanto foi vendido?
- Quais produtos venderam mais?
- Quais clientes compraram mais?
- Qual foi a venda por mes?
*/

-- 52.1 - Total geral de vendas.
SELECT
    COUNT(*) AS TotalSalesItems,
    SUM(Quantity) AS TotalUnitsSold,
    SUM(TotalAmount) AS TotalRevenue
FROM dbo.RoadmapETL_FactSales;
GO

-- 52.2 - Produtos com maior faturamento.
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

-- 52.3 - Clientes com maior volume de compras.
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

-- 52.4 - Vendas por mes.
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

-- 52.5 - Criando indice para consultas por data.
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

-- 52.6 - View final para relatorios.
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
REVISAO DO MODULO 06
============================================================

Aula 45 - ETL e tabelas de staging
Aula 46 - Importacao e qualidade de dados
Aula 47 - Carga incremental e dimensoes
Aula 48 - Tabela fato e modelo analitico
Aula 49 - Stored procedure ETL
Aula 50 - Auditoria e monitoramento
Aula 51 - Integracao com .NET
Aula 52 - Projeto final e relatorios

============================================================
FIM DO MODULO 06
============================================================
*/

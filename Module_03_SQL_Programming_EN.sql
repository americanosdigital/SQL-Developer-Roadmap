
/*
================================================================================
SQL DEVELOPER ROADMAP
MODULO 03 - PROGRAMACAO SQL E OBJETOS DO BANCO
Banco: SQLRoadmapTrainingDB | Aulas 21 a 28
================================================================================
OBJETIVOS
- Variaveis e controle de fluxo em T-SQL.
- Stored procedures com parametros de entrada e saida.
- Funcoes escalares e com valor de tabela.
- Tabelas temporarias e table variables.
- Triggers com suporte a operacoes de varias linhas.
- Tratamento de erros com TRY/CATCH e THROW.
- Dynamic SQL parametrizado.

INSTRUCOES
1. Execute os Modulos 01 e 02 antes deste modulo.
2. Abra no SQL Server Management Studio (SSMS).
3. Execute uma aula por vez.
4. Leia os comentarios antes de executar comandos que criam objetos ou alteram dados.
5. A procedure da Aula 24 altera dados quando executada.
6. O trigger da Aula 26 registra alteracoes de preco em Products.

Os objetos criados neste modulo usam o prefixo Roadmap para reduzir conflitos.
================================================================================
*/
USE SQLRoadmapTrainingDB;
GO

IF OBJECT_ID(N'dbo.Customers', N'U') IS NULL
    THROW 51000, N'A tabela dbo.Customers nao foi encontrada. Execute o Modulo 01.', 1;
GO
IF OBJECT_ID(N'dbo.Products', N'U') IS NULL
    THROW 51001, N'A tabela dbo.Products nao foi encontrada. Execute o Modulo 01.', 1;
GO

/*
================================================================================
AULA 21 - VARIAVEIS E CONTROLE DE FLUXO
================================================================================
*/
DECLARE @ProductCount INT;
DECLARE @MinimumPrice DECIMAL(10,2) = 100.00;

SELECT @ProductCount = COUNT(*) FROM dbo.Products;

SELECT @ProductCount AS TotalProducts, @MinimumPrice AS MinimumPrice;

IF @ProductCount > 0
    PRINT N'Existem produtos cadastrados.';
ELSE
    PRINT N'Nenhum produto foi encontrado.';
GO

DECLARE @Counter INT = 1;
WHILE @Counter <= 5
BEGIN
    PRINT CONCAT(N'Iteracao: ', @Counter);
    SET @Counter += 1;
END;
GO

-- EXERCICIO: declare um preco minimo, conte os produtos acima dele
-- e use IF / ELSE para exibir uma mensagem.

/*
================================================================================
AULA 22 - STORED PROCEDURES COM PARAMETROS
================================================================================
*/
CREATE OR ALTER PROCEDURE dbo.Roadmap_GetProductsByPrice
    @MinimumPrice DECIMAL(10,2),
    @MaximumPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @MinimumPrice < 0 OR @MaximumPrice < 0
        THROW 51002, N'Os precos nao podem ser negativos.', 1;

    IF @MinimumPrice > @MaximumPrice
        THROW 51003, N'O preco minimo nao pode ser maior que o maximo.', 1;

    SELECT ProductId, ProductName, Price, StockQuantity, IsActive
    FROM dbo.Products
    WHERE Price BETWEEN @MinimumPrice AND @MaximumPrice
    ORDER BY Price, ProductName;
END;
GO

-- Consulta somente: executa a procedure para listar produtos.
EXEC dbo.Roadmap_GetProductsByPrice
    @MinimumPrice = 100.00,
    @MaximumPrice = 5000.00;
GO

CREATE OR ALTER PROCEDURE dbo.Roadmap_GetProductCount
    @ActiveOnly BIT = 1,
    @TotalProducts INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @TotalProducts = COUNT(*)
    FROM dbo.Products
    WHERE @ActiveOnly = 0 OR IsActive = 1;
END;
GO

DECLARE @Total INT;
EXEC dbo.Roadmap_GetProductCount
    @ActiveOnly = 1,
    @TotalProducts = @Total OUTPUT;
SELECT @Total AS TotalActiveProducts;
GO

-- EXERCICIO: crie uma procedure que receba @CustomerId e retorne
-- o cliente correspondente. Trate o caso em que ele nao existe.

/*
================================================================================
AULA 23 - FUNCOES DEFINIDAS PELO USUARIO (UDF)
================================================================================
*/
CREATE OR ALTER FUNCTION dbo.Roadmap_CalculateDiscount
(
    @Price DECIMAL(10,2),
    @DiscountPercentage DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    IF @Price IS NULL OR @DiscountPercentage IS NULL
        RETURN NULL;

    IF @Price < 0 OR @DiscountPercentage < 0 OR @DiscountPercentage > 100
        RETURN NULL;

    RETURN CONVERT(DECIMAL(10,2),
        @Price * (1 - (@DiscountPercentage / 100.0)));
END;
GO

SELECT
    ProductName,
    Price AS OriginalPrice,
    dbo.Roadmap_CalculateDiscount(Price, 10.00) AS PriceWith10PercentDiscount
FROM dbo.Products
ORDER BY ProductName;
GO

CREATE OR ALTER FUNCTION dbo.Roadmap_GetActiveProductsAbovePrice
(
    @MinimumPrice DECIMAL(10,2)
)
RETURNS TABLE
AS
RETURN
(
    SELECT ProductId, ProductName, Price, StockQuantity
    FROM dbo.Products
    WHERE IsActive = 1 AND Price >= @MinimumPrice
);
GO

SELECT *
FROM dbo.Roadmap_GetActiveProductsAbovePrice(100.00)
ORDER BY Price DESC;
GO

-- EXERCICIO: crie uma funcao inline que receba @CustomerId e retorne
-- somente o cliente correspondente que esteja ativo.

/*
================================================================================
AULA 24 - PROCEDURE COM VALIDACAO, TRANSACAO E TRATAMENTO DE ERROS
================================================================================
ATENCAO: a procedure altera o preco de um produto quando executada.
A criacao da procedure nao altera dados. A execucao de exemplo fica comentada.
*/
CREATE OR ALTER PROCEDURE dbo.Roadmap_UpdateProductPrice
    @ProductId INT,
    @NewPrice DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @NewPrice IS NULL OR @NewPrice < 0
        THROW 51004, N'O novo preco deve ser maior ou igual a zero.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE ProductId = @ProductId)
            THROW 51005, N'Produto nao encontrado.', 1;

        UPDATE dbo.Products
        SET Price = @NewPrice
        WHERE ProductId = @ProductId;

        COMMIT TRANSACTION;

        SELECT ProductId, ProductName, Price
        FROM dbo.Products
        WHERE ProductId = @ProductId;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- EXECUCAO OPCIONAL: altera permanentemente o preco.
-- Consulte os produtos e escolha um ProductId de teste antes de executar.
-- EXEC dbo.Roadmap_UpdateProductPrice @ProductId = 1, @NewPrice = 4999.90;
-- GO

/*
================================================================================
AULA 25 - TABELAS TEMPORARIAS E TABLE VARIABLES
================================================================================
*/
CREATE TABLE #ProductsOver1000
(
    ProductId INT,
    ProductName NVARCHAR(100),
    Price DECIMAL(10,2)
);

INSERT INTO #ProductsOver1000 (ProductId, ProductName, Price)
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE Price > 1000.00;

SELECT * FROM #ProductsOver1000 ORDER BY Price DESC;
DROP TABLE #ProductsOver1000;
GO

DECLARE @ProductsOver1000 TABLE
(
    ProductId INT,
    ProductName NVARCHAR(100),
    Price DECIMAL(10,2)
);

INSERT INTO @ProductsOver1000 (ProductId, ProductName, Price)
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE Price > 1000.00;

SELECT * FROM @ProductsOver1000 ORDER BY Price DESC;
GO

-- EXERCICIO: armazene clientes ativos em uma tabela temporaria,
-- consulte os registros e depois remova a tabela.

/*
================================================================================
AULA 26 - TRIGGERS E AUDITORIA
================================================================================
A criacao da tabela e do trigger nao altera os produtos existentes.
O trigger sera executado quando um UPDATE alterar o preco de Products.
*/
IF OBJECT_ID(N'dbo.Roadmap_ProductPriceAudit', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Roadmap_ProductPriceAudit
    (
        AuditId BIGINT IDENTITY(1,1) PRIMARY KEY,
        ProductId INT NOT NULL,
        OldPrice DECIMAL(10,2) NOT NULL,
        NewPrice DECIMAL(10,2) NOT NULL,
        ChangedAt DATETIME2 NOT NULL
            CONSTRAINT DF_Roadmap_ProductPriceAudit_ChangedAt
            DEFAULT SYSDATETIME()
    );
END;
GO

CREATE OR ALTER TRIGGER dbo.Roadmap_TR_Products_PriceAudit
ON dbo.Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Roadmap_ProductPriceAudit (ProductId, OldPrice, NewPrice)
    SELECT i.ProductId, d.Price, i.Price
    FROM inserted AS i
    INNER JOIN deleted AS d ON d.ProductId = i.ProductId
    WHERE i.Price <> d.Price;
END;
GO

SELECT AuditId, ProductId, OldPrice, NewPrice, ChangedAt
FROM dbo.Roadmap_ProductPriceAudit
ORDER BY AuditId DESC;
GO

-- TESTE OPCIONAL: o UPDATE altera o preco e o trigger grava a auditoria.
-- Execute apenas se desejar testar. O ROLLBACK desfaz a alteracao e a auditoria.
--
-- BEGIN TRANSACTION;
-- UPDATE dbo.Products
-- SET Price = Price + 1.00
-- WHERE ProductId = (SELECT MIN(ProductId) FROM dbo.Products);
-- SELECT * FROM dbo.Roadmap_ProductPriceAudit ORDER BY AuditId DESC;
-- ROLLBACK TRANSACTION;
-- GO

-- EXERCICIO: amplie a auditoria para registrar tambem alteracoes de
-- StockQuantity. Considere atualizacoes que afetem varias linhas.

/*
================================================================================
AULA 27 - TRATAMENTO DE ERROS COM TRY/CATCH E THROW
================================================================================
*/
BEGIN TRY
    DECLARE @Numerator DECIMAL(10,2) = 100.00;
    DECLARE @Denominator DECIMAL(10,2) = 0.00;

    IF @Denominator = 0
        THROW 51006, N'Nao e permitido dividir por zero neste exemplo.', 1;

    SELECT @Numerator / @Denominator AS Result;
END TRY
BEGIN CATCH
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine;
END CATCH;
GO

-- EXERCICIO: crie um bloco TRY/CATCH que valide um preco.
-- Se for negativo, utilize THROW para gerar um erro controlado.

/*
================================================================================
AULA 28 - DYNAMIC SQL COM SP_EXECUTESQL
================================================================================
Valores devem ser parametrizados. Identificadores, como nomes de colunas,
devem ser validados por uma lista permitida e delimitados com QUOTENAME.
*/
DECLARE @SortColumn SYSNAME = N'ProductName';
DECLARE @SortDirection NVARCHAR(4) = N'ASC';
DECLARE @Sql NVARCHAR(MAX);

IF @SortColumn NOT IN (N'ProductName', N'Price', N'StockQuantity')
    THROW 51007, N'Coluna de ordenacao nao permitida.', 1;

IF @SortDirection NOT IN (N'ASC', N'DESC')
    THROW 51008, N'Direcao de ordenacao invalida.', 1;

SET @Sql =
    N'SELECT ProductId, ProductName, Price, StockQuantity
      FROM dbo.Products
      WHERE Price >= @MinimumPrice
      ORDER BY ' + QUOTENAME(@SortColumn) + N' ' + @SortDirection + N';';

EXEC sys.sp_executesql
    @Sql,
    N'@MinimumPrice DECIMAL(10,2)',
    @MinimumPrice = 100.00;
GO

-- EXERCICIO: altere @SortColumn para Price e StockQuantity.
-- Teste tambem DESC. Tente uma coluna fora da lista permitida.

/*
================================================================================
REVISAO DO MODULO 03
================================================================================
Ao concluir, voce devera conseguir:
1. Declarar variaveis e controlar o fluxo de execucao.
2. Criar procedures com parametros de entrada e saida.
3. Criar e utilizar funcoes escalares e com valor de tabela.
4. Utilizar tabelas temporarias e table variables.
5. Criar triggers que suportem operacoes com varias linhas.
6. Tratar erros com TRY/CATCH, THROW e XACT_STATE.
7. Utilizar Dynamic SQL parametrizado.

DESAFIO FINAL
Crie uma stored procedure que receba preco minimo e maximo, valide os
parametros, armazene os produtos encontrados em uma tabela temporaria,
retorne os produtos ordenados por preco e trate erros com TRY/CATCH e THROW.

FIM DO MODULO 03
================================================================================
*/

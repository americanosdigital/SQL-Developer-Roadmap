

-- =============================================
-- Roteiro para Desenvolvedor SQL
-- Módulo 01 - Fundamentos de SQL
-- Lição 01 - Criação de Banco de Dados
-- SQL Developer Roadmap
-- =============================================

-- Criar o banco de dados.
-- SQL
IF DB_ID('SQLRoadmapTrainingDB') IS NULL
BEGIN
    CREATE DATABASE SQLRoadmapTrainingDB;
END;
GO

-- Usando o banco de dados criado.
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- Verificando a criação do banco de dados.
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
-- Roteiro para Desenvolvedor SQL
-- =========================================================
--
-- 01-Basics

-- Entendendo os tipos de dados
-- Estes são alguns dos tipos mais utilizados no SQL Server:
-- Understanding data types
--   - Tipo  Utilização	Exemplo
--   - INT	            Números inteiros
--   - BIGINT	        Inteiros maiores
--   - VARCHAR(255)	    Texto variável
--   - NVARCHAR(max)	Texto Unicode
--   - DECIMAL(10,2)	Valores decimais
--   - BIT	            Verdadeiro ou falso
--   - DATE         	Data
--   - DATETIME2	    Data e horário

-- Usando o banco de dados criado.
-- SQL
USE SQLRoadmapTrainingDB;
GO

-- Criando a tabela Customers.
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

-- Criando a tabela Products.
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



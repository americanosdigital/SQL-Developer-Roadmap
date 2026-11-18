

<div class="Box-JYjgF4" data-d-align="center" data-d-auto-spacing="" data-d-component="box" data-d-direction="col" style="--smoothing-background-color: #0070BA; border-radius: var(--dil-radius-md); --w-box-gutter-block-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-block-start: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-start: calc(var(--spacing, 0.25rem) * 3); padding-block: calc(var(--spacing, 0.25rem) * 3); padding-inline: calc(var(--spacing, 0.25rem) * 3); background-color: rgb(0, 112, 186);">
<div class="Box-JYjgF4" data-d-align="center" data-d-component="row" data-d-direction="row" data-d-justify="center" style="gap: calc(var(--spacing, 0.25rem) * 2);">
<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-coffee" data-d-component="icon" style="color: rgb(255, 255, 255); font-size: 18px;">
<path d="M10 2v2"></path><path d="M14 2v2"></path><path d="M16 8a1 1 0 0 1 1 1v8a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4V9a1 1 0 0 1 1-1h14a4 4 0 1 1 0 8h-1">
</path>
<path d="M6 2v2">
</path>
</svg>    
<h3 class="TextBase-kDAqPL Title-ij922C" data-d-text-flow="" data-d-component="title" data-d-size="md" data-d-weight="semibold" style="color: rgb(255, 255, 255);">
<span data-d-stream-run="" data-d-text-flow="run" style="--d-stream-ink: rgb(255, 255, 255);">
<strong class="Emphasis-BHzYtQ">
    <a href="https://www.paypal.com/donate/?hosted_button_id=YUM9WDEBUMNXL" target="_blank" >
  <img src="https://shields.io" alt="Compre um café pelo PayPal">
</a>
</strong>
</span>
</h3>    
</div>
</div>


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


<div class="Box-JYjgF4" data-d-align="center" data-d-auto-spacing="" data-d-component="box" data-d-direction="col" style="--smoothing-background-color: #0070BA; border-radius: var(--dil-radius-md); --w-box-gutter-block-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-block-start: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-start: calc(var(--spacing, 0.25rem) * 3); padding-block: calc(var(--spacing, 0.25rem) * 3); padding-inline: calc(var(--spacing, 0.25rem) * 3); background-color: rgb(0, 112, 186);">
<div class="Box-JYjgF4" data-d-align="center" data-d-component="row" data-d-direction="row" data-d-justify="center" style="gap: calc(var(--spacing, 0.25rem) * 2);">
<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-coffee" data-d-component="icon" style="color: rgb(255, 255, 255); font-size: 18px;">
<path d="M10 2v2"></path><path d="M14 2v2"></path><path d="M16 8a1 1 0 0 1 1 1v8a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4V9a1 1 0 0 1 1-1h14a4 4 0 1 1 0 8h-1">
</path>
<path d="M6 2v2">
</path>
</svg>    
<h3 class="TextBase-kDAqPL Title-ij922C" data-d-text-flow="" data-d-component="title" data-d-size="md" data-d-weight="semibold" style="color: rgb(255, 255, 255);">
<span data-d-stream-run="" data-d-text-flow="run" style="--d-stream-ink: rgb(255, 255, 255);">
<strong class="Emphasis-BHzYtQ">
    <a href="https://www.paypal.com/donate/?hosted_button_id=YUM9WDEBUMNXL" target="_blank" >
  <img src="https://shields.io" alt="Compre um café pelo PayPal">
</a>
</strong>
</span>
</h3>    
</div>
</div>

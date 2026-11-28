

--------------------------------------------------------------------------------------------------------------------------------------------------
<div>
## ☕ Apoie o meu trabalho

Se você acha este projeto útil e gostaria de apoiar o meu aprendizado contínuo e as minhas contribuições para projetos de código aberto (open source), considere me pagar um café!

<p align="center">
<a href="https://www.paypal.com/donate/?hosted_button_id=YUM9WDEBUMNXL">
<img src="https://img.shields.io/badge/PayPal-Donate-0070BA?style=for-the-badge&logo=paypal&logoColor=white" alt="Doar pelo PayPal">
</a>
&nbsp; 
<a href="https://www.buymeacoffee.com/americanosdigital" target="_blank">
<img src="https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=americanosdigital&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00" alt="Me pague um café">
</a>
</p>

Obrigado pelo seu apoio! ❤️

</div>
</a>
</div>

</div>
--------------------------------------------------------------------------------------------------------------------------------------------------

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


--------------------------------------------------------------------------------------------------------------------------------------------------
<div>
## ☕ Apoie o meu trabalho

Se você acha este projeto útil e gostaria de apoiar o meu aprendizado contínuo e as minhas contribuições para projetos de código aberto (open source), considere me pagar um café!

<p align="center">
<a href="https://www.paypal.com/donate/?hosted_button_id=YUM9WDEBUMNXL">
<img src="https://img.shields.io/badge/PayPal-Donate-0070BA?style=for-the-badge&logo=paypal&logoColor=white" alt="Doar pelo PayPal">
</a>
&nbsp; 
<a href="https://www.buymeacoffee.com/americanosdigital" target="_blank">
<img src="https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=americanosdigital&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00" alt="Me pague um café">
</a>
</p>

Obrigado pelo seu apoio! ❤️

</div>
</a>
</div>

</div>
--------------------------------------------------------------------------------------------------------------------------------------------------

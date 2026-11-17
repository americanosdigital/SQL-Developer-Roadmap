
/*
============================================================
SQL DEVELOPER ROADMAP
MODULO 05 - MODELAGEM, TRANSACOES E SEGURANCA
Banco: SQLRoadmapTrainingDB
Aulas: 37 a 44
============================================================
*/

USE SQLRoadmapTrainingDB;
GO

/*
============================================================
AULA 37 - MODELAGEM E NORMALIZACAO DE DADOS
============================================================

Objetivo:
- Separar entidades em tabelas especificas.
- Evitar repeticao desnecessaria de informacoes.
- Utilizar chaves primarias e estrangeiras.
- Aplicar conceitos de normalizacao.

Exemplo de estrutura:
Clientes -> Pedidos -> Itens do Pedido -> Produtos
Categorias -> Produtos
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

-- Inserindo dados de exemplo sem duplicar registros.

IF NOT EXISTS (
    SELECT 1 FROM dbo.Roadmap_Customers
    WHERE Email = 'cliente.roadmap@email.com'
)
BEGIN
    INSERT INTO dbo.Roadmap_Customers (FullName, Email)
    VALUES ('Cliente Roadmap', 'cliente.roadmap@email.com');
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
    WHERE SupplierName = 'Fornecedor Roadmap'
)
BEGIN
    INSERT INTO dbo.Roadmap_Suppliers (SupplierName, Email)
    VALUES ('Fornecedor Roadmap', 'fornecedor@email.com');
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.Roadmap_Products
    WHERE ProductName = 'Notebook Roadmap'
)
BEGIN
    INSERT INTO dbo.Roadmap_Products
        (ProductName, CategoryId, SupplierId, UnitPrice, StockQuantity)
    SELECT
        'Notebook Roadmap',
        c.CategoryId,
        s.SupplierId,
        4500.00,
        10
    FROM dbo.Roadmap_Categories c
    CROSS JOIN dbo.Roadmap_Suppliers s
    WHERE c.CategoryName = 'Informatica'
      AND s.SupplierName = 'Fornecedor Roadmap';
END;
GO

SELECT * FROM dbo.Roadmap_Customers;
SELECT * FROM dbo.Roadmap_Categories;
SELECT * FROM dbo.Roadmap_Suppliers;
SELECT * FROM dbo.Roadmap_Products;
GO

/*
============================================================
AULA 38 - DESNORMALIZACAO E CONSULTAS PARA RELATORIOS
============================================================

Normalizacao reduz redundancia e melhora a consistencia.
Desnormalizacao pode simplificar consultas de leitura,
mas pode aumentar redundancia e custo de manutencao.

Uma VIEW pode apresentar dados de varias tabelas
em uma estrutura conveniente para relatorios.
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

-- Exemplo de relatorio agregado.
SELECT
    CustomerName,
    COUNT(DISTINCT OrderId) AS TotalOrders,
    SUM(ItemTotal) AS TotalPurchased
FROM dbo.Roadmap_vw_OrderSummary
GROUP BY CustomerName;
GO

/*
============================================================
AULA 39 - RELACIONAMENTOS E INTEGRIDADE REFERENCIAL
============================================================

PK: identifica unicamente cada registro.
FK: garante que o registro relacionado exista.
UNIQUE: impede valores duplicados.
CHECK: valida regras de negocio.
NOT NULL: exige preenchimento.

Os relacionamentos desta aula foram definidos na Aula 37.
*/

-- Consultando as chaves estrangeiras do modelo.
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

-- Teste de integridade: o INSERT abaixo deve falhar
-- porque o CustomerId informado nao existe.
-- Execute separadamente apenas para observar a validacao.
--
-- INSERT INTO dbo.Roadmap_SalesOrders (CustomerId)
-- VALUES (999999);
GO

-- Testando uma restricao CHECK.
-- O INSERT abaixo deve falhar porque a quantidade precisa ser positiva.
--
-- INSERT INTO dbo.Roadmap_SalesOrderItems
--     (OrderId, ProductId, Quantity, UnitPrice)
-- VALUES (1, 1, 0, 100.00);
GO

/*
============================================================
AULA 40 - PROPRIEDADES ACID E TRANSACOES
============================================================

A - Atomicity: tudo ou nada.
C - Consistency: os dados respeitam as regras.
I - Isolation: transacoes concorrentes sao controladas.
D - Durability: dados confirmados permanecem persistidos.

Este exemplo demonstra ROLLBACK.
A alteracao de estoque sera desfeita.
*/

DECLARE @ProductId INT;

SELECT @ProductId = ProductId
FROM dbo.Roadmap_Products
WHERE ProductName = 'Notebook Roadmap';

IF @ProductId IS NOT NULL
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.Roadmap_Products
        SET StockQuantity = StockQuantity - 1
        WHERE ProductId = @ProductId
          AND StockQuantity > 0;

        IF @@ROWCOUNT = 0
            THROW 50001, 'Estoque insuficiente ou produto inexistente.', 1;

        SELECT
            ProductName,
            StockQuantity AS StockAfterUpdate
        FROM dbo.Roadmap_Products
        WHERE ProductId = @ProductId;

        -- Desfaz a alteracao para fins de demonstracao.
        ROLLBACK TRANSACTION;

        PRINT 'Transacao revertida com sucesso.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        PRINT ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Exemplo de confirmacao:
-- Substitua ROLLBACK por COMMIT no exemplo anterior
-- para persistir a alteracao. Execute com cuidado.

/*
============================================================
AULA 41 - NIVEIS DE ISOLAMENTO
============================================================

READ UNCOMMITTED: permite leituras nao confirmadas.
READ COMMITTED: evita dirty reads; e o padrao usual.
REPEATABLE READ: mantem locks de leitura ate o fim da transacao.
SERIALIZABLE: nivel mais restritivo, protege intervalos de dados.
SNAPSHOT: utiliza controle de versao de linhas.

*/

-- Nivel padrao mais comum.
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT *
FROM dbo.Roadmap_Products;
GO

-- Exemplo de leitura nao confirmada.
-- Pode retornar dados que outra transacao ainda pode desfazer.
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT *
FROM dbo.Roadmap_Products;
GO

-- Nivel mais restritivo.
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT *
FROM dbo.Roadmap_Products
WHERE ProductId = 1;
GO

-- Retornando ao nivel padrao.
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

-- SNAPSHOT exige habilitacao no banco.
-- Execute com planejamento, pois altera uma configuracao do banco.
-- ALTER DATABASE SQLRoadmapTrainingDB
-- SET ALLOW_SNAPSHOT_ISOLATION ON;
--
-- Depois da habilitacao:
-- SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
-- BEGIN TRANSACTION;
-- SELECT * FROM dbo.Roadmap_Products;
-- COMMIT TRANSACTION;
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

/*
============================================================
AULA 42 - LOCKS, BLOCKING E DEADLOCKS
============================================================

LOCK: mecanismo que controla acesso concorrente aos dados.
BLOCKING: uma sessao aguarda outra liberar um recurso.
DEADLOCK: duas ou mais sessoes aguardam recursos entre si,
formando um ciclo. O SQL Server escolhe uma transacao como vitima.

TESTE DE BLOCKING:
1. Abra duas janelas de consulta no SSMS.
2. Execute o BLOCO A na primeira janela.
3. Enquanto a transacao estiver aberta, execute o BLOCO B
   na segunda janela.
4. Observe que a segunda sessao pode ficar aguardando.
5. Volte a primeira janela e execute ROLLBACK.
*/

-- BLOCO A - SESSAO 1
-- Execute e mantenha a transacao aberta.
--
-- BEGIN TRANSACTION;
-- UPDATE dbo.Roadmap_Products
-- SET UnitPrice = UnitPrice + 1
-- WHERE ProductName = 'Notebook Roadmap';
--
-- Nao execute COMMIT ainda.
-- Depois de testar a segunda sessao:
-- ROLLBACK TRANSACTION;
GO

-- BLOCO B - SESSAO 2
-- Execute enquanto a transacao da Sessao 1 estiver aberta.
--
-- SELECT *
-- FROM dbo.Roadmap_Products
-- WHERE ProductName = 'Notebook Roadmap';
GO

-- Consultando sessoes bloqueadas.
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

-- Consultando locks ativos no banco atual.
SELECT
    request_session_id,
    resource_type,
    request_mode,
    request_status
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID();
GO

/*
DEADLOCK - EXEMPLO CONCEITUAL

Para reproduzir, seriam necessarias duas sessoes:
- Sessao A bloqueia o recurso 1 e tenta acessar o recurso 2.
- Sessao B bloqueia o recurso 2 e tenta acessar o recurso 1.

Boas praticas:
- Acessar tabelas sempre na mesma ordem.
- Manter transacoes curtas.
- Criar indices adequados.
- Tratar o erro 1205 e repetir a operacao quando apropriado.
*/

/*
============================================================
AULA 43 - USUARIOS, ROLES E PERMISSOES
============================================================

Principio do menor privilegio:
conceder somente as permissoes necessarias.

Este exemplo cria um usuario sem login,
adequado para demonstracao dentro do banco.
Ele nao cria um login no servidor.
*/

IF DATABASE_PRINCIPAL_ID('RoadmapReaderRole') IS NULL
    CREATE ROLE RoadmapReaderRole;
GO

IF DATABASE_PRINCIPAL_ID('Roadmap_DemoReader') IS NULL
    CREATE USER Roadmap_DemoReader WITHOUT LOGIN;
GO

-- Concede leitura apenas na VIEW de relatorio.
GRANT SELECT ON OBJECT::dbo.Roadmap_vw_OrderSummary
TO RoadmapReaderRole;
GO

-- Adiciona o usuario a role.
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

-- Teste de permissao: o usuario consegue consultar a VIEW.
EXECUTE AS USER = 'Roadmap_DemoReader';

SELECT *
FROM dbo.Roadmap_vw_OrderSummary;

REVERT;
GO

-- Consulte as permissoes concedidas.
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
AULA 44 - BACKUP E RESTORE
============================================================

BACKUP: cria uma copia de seguranca.
RESTORE: recupera o banco a partir de um backup.
VERIFYONLY: verifica se o backup pode ser lido e esta completo
do ponto de vista estrutural do arquivo.

IMPORTANTE:
- Crie a pasta C:\SQLBackups antes de executar.
- O servico do SQL Server precisa ter permissao de escrita nela.
- O caminho e do servidor SQL Server, nao necessariamente
  do computador onde o SSMS esta aberto.
*/

-- BACKUP COMPLETO.
BACKUP DATABASE SQLRoadmapTrainingDB
TO DISK = N'C:\SQLBackups\SQLRoadmapTrainingDB_Full.bak'
WITH
    INIT,
    CHECKSUM,
    STATS = 10;
GO

-- Verificando o arquivo de backup.
RESTORE VERIFYONLY
FROM DISK = N'C:\SQLBackups\SQLRoadmapTrainingDB_Full.bak'
WITH CHECKSUM;
GO

-- Consultando os arquivos logicos dentro do backup.
RESTORE FILELISTONLY
FROM DISK = N'C:\SQLBackups\SQLRoadmapTrainingDB_Full.bak';
GO

/*
MODELO DE RESTORE PARA OUTRO BANCO

1. Execute RESTORE FILELISTONLY.
2. Identifique os nomes logicos dos arquivos de dados e log.
3. Ajuste os nomes logicos e os caminhos fisicos abaixo.
4. Garanta que a pasta C:\SQLData exista e tenha permissao.

Nao execute sem adaptar os nomes e caminhos.

RESTORE DATABASE SQLRoadmapTrainingDB_RestoreTest
FROM DISK = N'C:\SQLBackups\SQLRoadmapTrainingDB_Full.bak'
WITH
    MOVE N'NomeLogicoDados'
        TO N'C:\SQLData\SQLRoadmapTrainingDB_RestoreTest.mdf',
    MOVE N'NomeLogicoLog'
        TO N'C:\SQLData\SQLRoadmapTrainingDB_RestoreTest_log.ldf',
    RECOVERY,
    STATS = 10;
GO
*/

-- Conferindo os bancos existentes.
SELECT name, state_desc, recovery_model_desc
FROM sys.databases
WHERE name LIKE 'SQLRoadmapTrainingDB%';
GO

/*
============================================================
REVISAO DO MODULO 05
============================================================

Aula 37 - Modelagem e normalizacao
Aula 38 - Desnormalizacao e relatorios
Aula 39 - Relacionamentos e integridade referencial
Aula 40 - ACID e transacoes
Aula 41 - Niveis de isolamento
Aula 42 - Locks, blocking e deadlocks
Aula 43 - Usuarios, roles e permissoes
Aula 44 - Backup e restore

============================================================
FIM DO MODULO 05
============================================================
*/

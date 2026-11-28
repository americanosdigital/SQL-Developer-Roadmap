                    buymeacoffee.com/americanosdigital                

/*
===============================================================================
SQL DEVELOPER ROADMAP
MÓDULO 02 — CONSULTAS SQL INTERMEDIÁRIAS
Aulas 13 a 20
===============================================================================

Banco de dados utilizado: SQLRoadmapTrainingDB
Pré-requisito: executar o Módulo 01 antes deste módulo.

IMPORTANTE:
- Execute as aulas na ordem, uma seção por vez.
- Este módulo foi desenvolvido para SQL Server / SSMS.
- Os exemplos principais são consultas de leitura (SELECT).
- Os desafios ficam comentados para você praticar sem alterar os dados.

===============================================================================
CONFIGURAÇÃO INICIAL
===============================================================================
*/

USE SQLRoadmapTrainingDB;
GO

SET NOCOUNT ON;
GO

/*
Verifique se as tabelas necessárias existem.
As consultas deste módulo utilizam:
Customers, Products, Orders e OrderItems.
*/
IF OBJECT_ID('dbo.Customers', 'U') IS NULL
   OR OBJECT_ID('dbo.Products', 'U') IS NULL
   OR OBJECT_ID('dbo.Orders', 'U') IS NULL
   OR OBJECT_ID('dbo.OrderItems', 'U') IS NULL
BEGIN
    THROW 50001, 'Uma ou mais tabelas não existem. Execute primeiro o Módulo 01.', 1;
END;
GO

/*
===============================================================================
AULA 13 — CASE WHEN
===============================================================================

Objetivo:
Criar classificações condicionais nos resultados, sem alterar os dados.

Conceito equivalente em C#:
if / else if / else
*/

-- 13.1 Classificar produtos por faixa de preço
SELECT
    ProductId,
    ProductName,
    Price,
    CASE
        WHEN Price >= 3000 THEN 'Produto Premium'
        WHEN Price >= 1000 THEN 'Produto Intermediário'
        ELSE 'Produto Econômico'
    END AS PriceCategory
FROM dbo.Products
ORDER BY Price DESC;
GO

-- 13.2 Classificar produtos pela quantidade em estoque
SELECT
    ProductId,
    ProductName,
    StockQuantity,
    CASE
        WHEN StockQuantity = 0 THEN 'Sem estoque'
        WHEN StockQuantity <= 10 THEN 'Estoque baixo'
        WHEN StockQuantity <= 30 THEN 'Estoque médio'
        ELSE 'Estoque alto'
    END AS StockStatus
FROM dbo.Products
ORDER BY StockQuantity;
GO

-- 13.3 Combinar CASE WHEN com AND
SELECT
    ProductName,
    Price,
    StockQuantity,
    CASE
        WHEN Price >= 3000 AND StockQuantity > 0
            THEN 'Premium disponível'
        WHEN Price >= 3000 AND StockQuantity = 0
            THEN 'Premium indisponível'
        WHEN StockQuantity = 0
            THEN 'Indisponível'
        ELSE 'Produto regular'
    END AS ProductStatus
FROM dbo.Products;
GO

-- 13.4 Agregação condicional: contar produtos disponíveis e indisponíveis
SELECT
    COUNT(*) AS TotalProducts,
    SUM(CASE WHEN StockQuantity > 0 THEN 1 ELSE 0 END) AS AvailableProducts,
    SUM(CASE WHEN StockQuantity = 0 THEN 1 ELSE 0 END) AS OutOfStockProducts
FROM dbo.Products;
GO

-- 13.5 Classificar clientes pelo status
SELECT
    CustomerId,
    FullName,
    Email,
    IsActive,
    CASE
        WHEN IsActive = 1 THEN 'Cliente ativo'
        ELSE 'Cliente inativo'
    END AS CustomerStatus
FROM dbo.Customers
ORDER BY FullName;
GO

/*
DESAFIO 13:
Crie uma consulta com ProductName, Price, StockQuantity e duas colunas:
1) PriceLevel: 'Premium' para preço >= 4000; 'Intermediário' para preço
   >= 1000; caso contrário, 'Básico'.
2) StockLevel: 'Indisponível' para estoque = 0; 'Baixo' para estoque
   entre 1 e 10; 'Disponível' para estoque > 10.

Espaço para sua solução:
*/

-- SELECT ...
-- FROM dbo.Products;
-- GO

/*
===============================================================================
AULA 14 — CTE (COMMON TABLE EXPRESSION)
===============================================================================

Objetivo:
Organizar consultas complexas em blocos nomeados e reutilizáveis dentro
de uma única instrução SQL.

Uma CTE começa com WITH e é seguida imediatamente pela instrução que a utiliza.
*/

-- 14.1 CTE para classificar produtos por valor total em estoque
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

-- 14.2 CTE para calcular o total de cada pedido
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

-- 14.3 CTE para localizar clientes que possuem pedidos
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
DESAFIO 14:
Crie uma CTE chamada CustomerOrderCount para contar quantos pedidos cada
cliente possui. Exiba CustomerId, FullName e TotalOrders, incluindo clientes
sem pedidos. Dica: utilize LEFT JOIN e COUNT(O.OrderId).
*/

-- ;WITH CustomerOrderCount AS
-- (
--     -- Escreva sua consulta aqui
-- )
-- SELECT ...
-- GO

/*
===============================================================================
AULA 15 — UNION E UNION ALL
===============================================================================

Objetivo:
Combinar os resultados de duas ou mais consultas compatíveis.

Regras:
- Cada SELECT deve retornar a mesma quantidade de colunas.
- As colunas correspondentes devem ter tipos de dados compatíveis.
- UNION remove linhas duplicadas.
- UNION ALL mantém duplicidades e normalmente evita o custo de eliminá-las.
*/

-- 15.1 UNION: combinar nomes de clientes e produtos
SELECT
    FullName AS ItemName,
    'Cliente' AS ItemType
FROM dbo.Customers

UNION

SELECT
    ProductName AS ItemName,
    'Produto' AS ItemType
FROM dbo.Products
ORDER BY ItemType, ItemName;
GO

-- 15.2 UNION ALL: combinar pedidos pendentes e concluídos
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

-- 15.3 UNION ALL com rótulos para formar um resumo simples
SELECT
    'Clientes' AS Category,
    COUNT(*) AS TotalRecords
FROM dbo.Customers

UNION ALL

SELECT
    'Produtos',
    COUNT(*)
FROM dbo.Products

UNION ALL

SELECT
    'Pedidos',
    COUNT(*)
FROM dbo.Orders;
GO

/*
DESAFIO 15:
Combine em uma única consulta os produtos com estoque baixo (StockQuantity
entre 1 e 10) e os produtos sem estoque (StockQuantity = 0).
Retorne ProductId, ProductName e uma coluna chamada StockGroup.
Use UNION ALL.
*/

/*
===============================================================================
AULA 16 — WINDOW FUNCTIONS
===============================================================================

Objetivo:
Calcular valores sobre um conjunto de linhas sem reduzir o resultado a uma
única linha, como normalmente ocorre com GROUP BY.

OVER() define a janela de linhas usada pela função.
*/

-- 16.1 Exibir cada produto e o valor total de estoque de todos os produtos
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

-- 16.2 Calcular a média de preço e comparar cada produto com a média
SELECT
    ProductId,
    ProductName,
    Price,
    AVG(Price) OVER () AS AverageProductPrice,
    Price - AVG(Price) OVER () AS DifferenceFromAverage
FROM dbo.Products
ORDER BY Price DESC;
GO

-- 16.3 Calcular o total acumulado dos itens por pedido
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

-- 16.4 LAG: comparar a data de cada pedido com o pedido anterior do cliente
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
DESAFIO 16:
Exiba cada pedido e o total do pedido, mantendo também uma coluna com a soma
dos totais de todos os pedidos. Use SUM(...) OVER().
Dica: primeiro calcule o total por pedido em uma CTE; depois aplique a função
de janela sobre os resultados da CTE.
*/

/*
===============================================================================
AULA 17 — ROW_NUMBER, RANK E DENSE_RANK
===============================================================================

Objetivo:
Numerar e classificar linhas conforme uma ordenação.

Diferença:
- ROW_NUMBER: sempre gera um número sequencial único.
- RANK: empates recebem a mesma posição e deixam lacunas na sequência.
- DENSE_RANK: empates recebem a mesma posição, sem deixar lacunas.
*/

-- 17.1 Comparar as três funções na classificação de preços
SELECT
    ProductName,
    Price,
    ROW_NUMBER() OVER (ORDER BY Price DESC, ProductId) AS RowNumberValue,
    RANK() OVER (ORDER BY Price DESC) AS RankValue,
    DENSE_RANK() OVER (ORDER BY Price DESC) AS DenseRankValue
FROM dbo.Products
ORDER BY Price DESC, ProductId;
GO

-- 17.2 Numerar os pedidos mais recentes de cada cliente
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

-- 17.3 Retornar somente o pedido mais recente de cada cliente
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
DESAFIO 17:
Crie um ranking dos produtos pelo valor (Price), do maior para o menor.
Exiba ProductName, Price, RANK e DENSE_RANK.
*/

/*
===============================================================================
AULA 18 — PARTITION BY
===============================================================================

Objetivo:
Dividir as linhas em grupos (partições) para que uma função de janela seja
calculada separadamente em cada grupo, sem eliminar as linhas.
*/

-- 18.1 Contar pedidos por cliente sem agrupar o resultado em uma linha
SELECT
    CustomerId,
    OrderId,
    OrderDate,
    COUNT(*) OVER (PARTITION BY CustomerId) AS TotalOrdersByCustomer
FROM dbo.Orders
ORDER BY CustomerId, OrderDate;
GO

-- 18.2 Calcular o total de itens de cada pedido
SELECT
    OrderId,
    OrderItemId,
    ProductId,
    Quantity,
    SUM(Quantity) OVER (PARTITION BY OrderId) AS TotalUnitsInOrder
FROM dbo.OrderItems
ORDER BY OrderId, OrderItemId;
GO

-- 18.3 Classificar produtos por preço dentro de cada faixa de estoque
;WITH ProductsByStock AS
(
    SELECT
        ProductId,
        ProductName,
        Price,
        StockQuantity,
        CASE
            WHEN StockQuantity = 0 THEN 'Sem estoque'
            WHEN StockQuantity <= 10 THEN 'Estoque baixo'
            ELSE 'Estoque disponível'
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
DESAFIO 18:
Exiba OrderId, ProductId, Quantity e a quantidade total de unidades por pedido.
Use SUM(Quantity) OVER (PARTITION BY OrderId).
*/

/*
===============================================================================
AULA 19 — CONSULTAS AVANÇADAS COM JOIN
===============================================================================

Objetivo:
Combinar JOINs, agregações e consultas correlacionadas para responder perguntas
mais próximas de cenários reais.
*/

-- 19.1 Relatório detalhado: cliente, pedido, produto e valor do item
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

-- 19.2 Clientes sem pedidos: LEFT JOIN com filtro IS NULL
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

-- 19.3 Total de pedidos e valor comprado por cliente
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

-- 19.4 CROSS APPLY: último pedido de cada cliente, quando existir
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
Observação:
- CROSS APPLY elimina as linhas da tabela da esquerda quando a subconsulta
  não retorna registros.
- OUTER APPLY mantém as linhas da esquerda e retorna NULL para as colunas
  da expressão aplicada quando não há correspondência.

DESAFIO 19:
Crie um relatório com todos os clientes, incluindo aqueles sem pedidos,
mostrando FullName, quantidade de pedidos e valor total comprado.
Use LEFT JOIN e agregação. Evite contar linhas duplicadas de itens como pedidos.
*/

/*
===============================================================================
AULA 20 — PAGINAÇÃO COM OFFSET E FETCH
===============================================================================

Objetivo:
Retornar os resultados em páginas, recurso comum em APIs e aplicações web.

A paginação exige ORDER BY para garantir uma ordem definida.
OFFSET informa quantas linhas devem ser ignoradas.
FETCH NEXT informa quantas linhas devem ser retornadas.
*/

-- 20.1 Primeira página: 3 produtos
SELECT
    ProductId,
    ProductName,
    Price
FROM dbo.Products
ORDER BY ProductId
OFFSET 0 ROWS
FETCH NEXT 3 ROWS ONLY;
GO

-- 20.2 Segunda página: 3 produtos
SELECT
    ProductId,
    ProductName,
    Price
FROM dbo.Products
ORDER BY ProductId
OFFSET 3 ROWS
FETCH NEXT 3 ROWS ONLY;
GO

-- 20.3 Paginação usando variáveis
DECLARE @PageNumber INT = 1;
DECLARE @PageSize INT = 10;

IF @PageNumber < 1 OR @PageSize < 1
    THROW 50002, 'PageNumber e PageSize devem ser maiores que zero.', 1;

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

-- 20.4 Paginação de pedidos com nome do cliente
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
DESAFIO 20:
Crie uma consulta para retornar a terceira página de clientes, considerando
5 clientes por página. Ordene por FullName e CustomerId.
Dica: OFFSET = (PageNumber - 1) * PageSize.
*/

/*
===============================================================================
REVISÃO FINAL — MÓDULO 02
===============================================================================

Ao concluir este módulo, você terá praticado:

[ ] CASE WHEN
[ ] CTEs (Common Table Expressions)
[ ] UNION e UNION ALL
[ ] Window Functions
[ ] ROW_NUMBER, RANK e DENSE_RANK
[ ] PARTITION BY
[ ] JOINs avançados, LEFT JOIN e APPLY
[ ] Paginação com OFFSET e FETCH

CONCEITOS IMPORTANTES:
1. CASE WHEN cria valores condicionais no resultado.
2. CTE organiza uma consulta e existe no escopo da instrução seguinte.
3. UNION remove duplicidades; UNION ALL mantém duplicidades.
4. Window Functions calculam sobre uma janela sem reduzir as linhas.
5. PARTITION BY reinicia o cálculo para cada grupo.
6. OFFSET/FETCH precisa de ORDER BY para paginação consistente.

PRÓXIMO PASSO:
Revise os exemplos, resolva os desafios e faça commit do arquivo no GitHub.
Não é necessário alterar as tabelas do banco para concluir este módulo.

===============================================================================
FIM DO MÓDULO 02 — CONSULTAS SQL INTERMEDIÁRIAS
===============================================================================
*/

                    buymeacoffee.com/americanosdigital                

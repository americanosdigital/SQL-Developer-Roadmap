https://buymeacoffee.com/americanosdigital

https://www.paypal.com/donate/?hosted_button_id=YUM9WDEBUMNXL

/*
================================================================================
SQL DEVELOPER ROADMAP
MODULO 04 - PERFORMANCE E OTIMIZACAO NO SQL SERVER
Banco: SQLRoadmapTrainingDB | Aulas 29 a 36
================================================================================
OBJETIVOS
- Medir o desempenho de consultas.
- Interpretar planos de execucao.
- Entender Table Scan, Index Scan e Index Seek.
- Criar e analisar indices.
- Utilizar indices compostos e colunas INCLUDE.
- Compreender estatisticas do SQL Server.
- Escrever filtros SARGable.
- Identificar oportunidades de otimizacao.

INSTRUCOES
1. Execute os Modulos 01, 02 e 03 antes deste modulo.
2. Abra este arquivo no SQL Server Management Studio (SSMS).
3. Execute uma aula por vez.
4. Compare os resultados antes e depois das melhorias.
5. Nao crie indices sem analisar as consultas e os planos de execucao.
6. A criacao de indices altera a estrutura do banco, mas nao os dados.

OBSERVACAO
O banco de treinamento pode ter poucos registros. Nesse caso, o SQL Server
pode preferir Table Scan em vez de utilizar um indice. Isso e esperado.
================================================================================
*/

USE SQLRoadmapTrainingDB;
GO

IF OBJECT_ID(N'dbo.Products', N'U') IS NULL
    THROW 52000, N'A tabela dbo.Products nao foi encontrada. Execute o Modulo 01.', 1;
GO

/*
================================================================================
AULA 29 - MEDINDO O DESEMPENHO DAS CONSULTAS
================================================================================
Conceitos:
- CPU time: tempo de processamento utilizado pela CPU.
- Elapsed time: tempo total decorrido.
- Logical reads: paginas lidas da memoria/cache do SQL Server.
- Physical reads: paginas lidas do armazenamento.

No SSMS:
1. Execute a consulta.
2. Abra a aba Messages.
3. Compare os resultados de STATISTICS IO e STATISTICS TIME.
*/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    ProductId,
    ProductName,
    Price,
    StockQuantity
FROM dbo.Products
WHERE Price >= 100.00
ORDER BY Price DESC;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

-- EXERCICIO:
-- 1. Execute uma consulta sem WHERE.
-- 2. Execute outra consulta filtrando por Price.
-- 3. Compare logical reads e o tempo informado pelo SQL Server.
-- 4. Registre suas observacoes.

/*
================================================================================
AULA 30 - EXECUTION PLANS (PLANOS DE EXECUCAO)
================================================================================
O plano de execucao mostra como o SQL Server pretende acessar e processar
os dados de uma consulta.

No SSMS:
- Ctrl + L: exibir o plano estimado.
- Ctrl + M: habilitar o plano de execucao real.
- Execute a consulta para visualizar o plano real.

Observe:
- Table Scan
- Index Scan
- Index Seek
- Sort
- Key Lookup
- Estimated Number of Rows
- Actual Number of Rows

O percentual de custo exibido no plano e uma estimativa relativa, nao uma
medicao direta do tempo real de cada operador.
*/

SELECT
    ProductId,
    ProductName,
    Price
FROM dbo.Products
WHERE ProductId = 1;
GO

SELECT
    ProductId,
    ProductName,
    Price
FROM dbo.Products
WHERE Price >= 1000.00;
GO

-- EXERCICIO:
-- Habilite o plano real com Ctrl + M.
-- Compare as duas consultas e identifique os operadores utilizados.
-- Observe a diferenca entre linhas estimadas e linhas reais.

/*
================================================================================
AULA 31 - TABLE SCAN, INDEX SCAN E INDEX SEEK
================================================================================
TABLE SCAN:
Percorre as paginas de dados da tabela.

INDEX SCAN:
Percorre as entradas de um indice.

INDEX SEEK:
Localiza uma faixa ou chave no indice usando os criterios de busca.

Nenhum operador e sempre melhor. A escolha depende da consulta, dos dados,
dos indices e das estimativas do otimizador.
*/

-- Consulta por chave primaria.
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE ProductId = 1;
GO

-- Consulta por faixa de preco.
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE Price BETWEEN 100.00 AND 2000.00;
GO

-- Consulta que retorna todos os produtos.
SELECT ProductId, ProductName, Price
FROM dbo.Products;
GO

-- EXERCICIO:
-- Visualize os planos reais das tres consultas.
-- Identifique os operadores e explique por que o SQL Server escolheu cada um.

/*
================================================================================
AULA 32 - CRIANDO E ANALISANDO INDICES
================================================================================
Um indice pode melhorar a localizacao de registros, mas tambem aumenta
o custo de INSERT, UPDATE e DELETE, alem de consumir armazenamento.

Antes de criar um indice, analise:
- Colunas usadas em WHERE.
- Colunas usadas em JOIN.
- Colunas usadas em ORDER BY.
- Frequencia e seletividade das consultas.
*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Roadmap_Products_Price'
      AND object_id = OBJECT_ID(N'dbo.Products')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Roadmap_Products_Price
    ON dbo.Products (Price);
END;
GO

-- Verifique os indices existentes na tabela.
SELECT
    name AS IndexName,
    type_desc AS IndexType,
    is_unique AS IsUnique
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'dbo.Products');
GO

-- Execute novamente a consulta por faixa de preco.
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE Price BETWEEN 100.00 AND 2000.00;
GO

-- EXERCICIO:
-- Compare o plano de execucao antes e depois da criacao do indice.
-- Lembre-se: o SQL Server pode continuar escolhendo um Scan se for mais barato.

/*
================================================================================
AULA 33 - INDICES COMPOSTOS E INCLUDE
================================================================================
Indice composto:
Possui mais de uma coluna na chave do indice.

INCLUDE:
Adiciona colunas ao nivel de folha do indice, sem transforma-las em chaves.

Um indice de cobertura pode atender uma consulta sem precisar buscar
colunas adicionais na tabela ou no indice clusterizado.
*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Roadmap_Products_IsActive_Price'
      AND object_id = OBJECT_ID(N'dbo.Products')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Roadmap_Products_IsActive_Price
    ON dbo.Products (IsActive, Price)
    INCLUDE (ProductName, StockQuantity);
END;
GO

-- Consulta alinhada com as colunas do indice composto.
SELECT
    ProductName,
    Price,
    StockQuantity
FROM dbo.Products
WHERE IsActive = 1
  AND Price >= 100.00
ORDER BY Price;
GO

-- Consulte a definicao dos indices criados.
SELECT
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS ColumnName,
    ic.key_ordinal AS KeyOrdinal,
    ic.is_included_column AS IsIncludedColumn
FROM sys.indexes AS i
INNER JOIN sys.index_columns AS ic
    ON i.object_id = ic.object_id
   AND i.index_id = ic.index_id
INNER JOIN sys.columns AS c
    ON ic.object_id = c.object_id
   AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID(N'dbo.Products')
  AND i.name LIKE N'IX_Roadmap%'
ORDER BY i.name, ic.key_ordinal, ic.index_column_id;
GO

-- EXERCICIO:
-- Crie uma consulta que filtre IsActive e Price.
-- Analise se o indice composto pode atender a consulta.
-- Observe quais colunas sao chaves e quais sao INCLUDE.

/*
================================================================================
AULA 34 - ESTATISTICAS DO SQL SERVER
================================================================================
As estatisticas ajudam o otimizador a estimar quantas linhas uma consulta
deve retornar. Estimativas influenciam a escolha do plano de execucao.

Nao atualize estatisticas indiscriminadamente em ambientes de producao.
Considere o volume de dados, a manutencao e as necessidades do ambiente.
*/

-- Consulte as estatisticas existentes em Products.
SELECT
    name AS StatisticsName,
    auto_created AS AutoCreated,
    user_created AS UserCreated,
    is_temporary AS IsTemporary
FROM sys.stats
WHERE object_id = OBJECT_ID(N'dbo.Products');
GO

-- Atualize as estatisticas da tabela.
UPDATE STATISTICS dbo.Products;
GO

-- Exiba as informacoes da estatistica associada ao indice criado na Aula 32.
DBCC SHOW_STATISTICS
(
    N'dbo.Products',
    N'IX_Roadmap_Products_Price'
)
WITH STAT_HEADER, DENSITY_VECTOR, HISTOGRAM;
GO

-- EXERCICIO:
-- Observe o histograma e identifique as informacoes de distribuicao.
-- Explique por que estatisticas ajudam o otimizador a estimar linhas.

/*
================================================================================
AULA 35 - SARGABILITY E OTIMIZACAO DE FILTROS
================================================================================
SARGable significa que um predicado pode ser utilizado de forma eficiente
para buscar dados, permitindo ao otimizador considerar o uso de indices.

Evite aplicar funcoes diretamente na coluna filtrada quando isso puder
impedir uma busca eficiente pelo indice.

EXEMPLO NAO SARGABLE:
YEAR(CreatedAt) = 2025

EXEMPLO SARGABLE:
CreatedAt >= inicio do ano
AND CreatedAt < inicio do proximo ano
*/

-- Forma menos favoravel: funcao aplicada na coluna.
SELECT ProductId, ProductName, CreatedAt
FROM dbo.Products
WHERE YEAR(CreatedAt) = 2025;
GO

-- Forma SARGable: intervalo de datas.
DECLARE @StartDate DATETIME2 = '2025-01-01';
DECLARE @EndDate DATETIME2 = '2026-01-01';

SELECT ProductId, ProductName, CreatedAt
FROM dbo.Products
WHERE CreatedAt >= @StartDate
  AND CreatedAt < @EndDate;
GO

-- Outro exemplo: evite aplicar funcao na coluna do filtro.
-- Menos favoravel:
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE ISNULL(Price, 0) >= 100.00;
GO

-- Alternativa, considerando que Price e NOT NULL na tabela do projeto:
SELECT ProductId, ProductName, Price
FROM dbo.Products
WHERE Price >= 100.00;
GO

-- EXERCICIO:
-- Reescreva uma consulta que utilize funcao na coluna do WHERE.
-- Compare os planos estimados e reais quando houver volume de dados suficiente.

/*
================================================================================
AULA 36 - DIAGNOSTICO E OTIMIZACAO DE CONSULTAS
================================================================================
Roteiro sugerido para investigar uma consulta lenta:

1. Identifique a consulta e reproduza o problema.
2. Meça CPU, elapsed time e logical reads.
3. Analise o plano de execucao real.
4. Compare linhas estimadas e reais.
5. Verifique filtros, JOINs, ordenacao e agregacoes.
6. Avalie indices e estatisticas.
7. Altere uma coisa por vez.
8. Meça novamente e compare os resultados.

A consulta abaixo apresenta estatisticas agregadas de execucoes que ainda
estao no cache de planos. Os dados podem desaparecer apos reinicializacao,
limpeza do cache ou outras operacoes de manutencao.

A permissao VIEW SERVER STATE pode ser necessaria para consultar a DMV.
*/

SELECT TOP (10)
    qs.execution_count AS ExecutionCount,
    qs.total_worker_time / 1000 AS TotalCpuTimeMs,
    qs.total_elapsed_time / 1000 AS TotalElapsedTimeMs,
    qs.total_logical_reads AS TotalLogicalReads,
    qs.total_logical_reads / NULLIF(qs.execution_count, 0)
        AS AvgLogicalReads,
    SUBSTRING
    (
        st.text,
        (qs.statement_start_offset / 2) + 1,
        (
            (
                CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(st.text)
                    ELSE qs.statement_end_offset
                END
                - qs.statement_start_offset
            ) / 2
        ) + 1
    ) AS QueryText
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
WHERE st.dbid = DB_ID()
ORDER BY qs.total_worker_time DESC;
GO

/*
QUERY STORE - CONCEITO ADICIONAL
O Query Store pode armazenar historico de consultas, planos e estatisticas
de execucao, ajudando a investigar regressoes de performance.

A habilitacao deve ser avaliada antes em cada ambiente.
O comando abaixo e opcional e exige permissao adequada.

-- ALTER DATABASE SQLRoadmapTrainingDB SET QUERY_STORE = ON;
*/

-- EXERCICIO FINAL:
-- 1. Escolha uma consulta do Modulo 02.
-- 2. Registre o plano de execucao e as estatisticas de IO e TIME.
-- 3. Identifique uma oportunidade de melhoria.
-- 4. Crie ou ajuste um indice somente se houver justificativa.
-- 5. Reexecute a consulta.
-- 6. Documente os resultados antes e depois.

 /*
================================================================================
REVISAO DO MODULO 04
================================================================================
Ao concluir, voce devera conseguir:
1. Medir o desempenho de consultas com STATISTICS IO e TIME.
2. Interpretar planos estimados e reais.
3. Diferenciar Table Scan, Index Scan e Index Seek.
4. Criar indices nao clusterizados.
5. Compreender indices compostos e INCLUDE.
6. Consultar e atualizar estatisticas.
7. Identificar filtros nao SARGable.
8. Seguir um processo de diagnostico e otimizacao baseado em evidencias.

FIM DO MODULO 04
================================================================================
*/

https://buymeacoffee.com/americanosdigital

https://www.paypal.com/donate/?hosted_button_id=YUM9WDEBUMNXL

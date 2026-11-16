# SQL Developer Roadmap

Repositório de estudos práticos para desenvolver conhecimentos em **SQL Server e T-SQL**, dos fundamentos a conceitos intermediários de desenvolvimento, otimização e integração de bancos de dados.

## Objetivo

Construir uma base sólida e demonstrável em SQL Server, desenvolvendo habilidades relevantes para atuar como **SQL Developer**, com foco em consultas, programação T-SQL, modelagem, performance, segurança e integração com aplicações.

## Tecnologias e ferramentas
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL
- Git e GitHub

## Roadmap de aprendizado

O roadmap está planejado em **6 módulos**, desenvolvidos e validados progressivamente.

| Status | Módulo | Conteúdo |
|---|---|---|
| Concluído | **Módulo 01 – Fundamentos de SQL** | Databases, tabelas, tipos de dados, CRUD, filtros, agregações, relacionamentos, JOINs, subqueries, views, índices, transações e stored procedures |
| Concluído | **Módulo 02 – Consultas SQL Intermediárias** | CASE, CTEs, UNION, window functions, ranking, PARTITION BY, APPLY e paginação |
| Em desenvolvimento | **Módulo 03 – Programação SQL e Objetos do Banco** | Variáveis, controle de fluxo, stored procedures, funções, triggers, tabelas temporárias, tratamento de erros e Dynamic SQL |
| Planejado | **Módulo 04 – Performance e Otimização** | Execution plans, índices, estatísticas, análise e otimização de consultas |
| Planejado | **Módulo 05 – Modelagem, Transações e Segurança** | Normalização, integridade referencial, ACID, isolamento, locks, deadlocks, permissões, backup e restore |
| Planejado | **Módulo 06 – Integração, ETL e Projetos Práticos** | Importação e exportação, conceitos de ETL, integração com .NET, relatórios e projeto prático |

> Os status refletem o andamento dos estudos e exercícios. Um módulo só será considerado concluído depois que seus exemplos forem executados e revisados.

## Estrutura do repositório

```text
SQL-Developer-Roadmap/
├── README.md
├── README-EN.md
├── PT-BR/
│   ├── Modulo-01-Fundamentos-de-SQL/
│   ├── Modulo-02-Consultas-SQL/
│   └── Modulo-03-Programacao-SQL/
└── EN/
    ├── Module-01-SQL-Fundamentals/
    ├── Module-02-SQL-Queries/
    └── Module-03-SQL-Programming/
```

Os nomes das pastas são uma sugestão. Mantenha os caminhos que já existem no repositório ou ajuste-os ao fazer o upload.

## Banco de dados utilizado

Os exercícios utilizam o banco `SQLRoadmapTrainingDB`, criado no Módulo 01. Os módulos seguintes reutilizam as tabelas e os dados de treinamento desse banco.

Antes de executar um módulo, leia as instruções iniciais do respectivo arquivo `.sql` e confirme que os módulos anteriores necessários já foram executados.

## Como utilizar
1. Instale o Microsoft SQL Server e o SSMS.
2. Abra o arquivo `.sql` correspondente ao módulo.
3. Leia os comentários e execute uma aula por vez.
4. Confira os resultados e mensagens do SSMS.
5. Resolva os desafios propostos nos comentários.
6. Registre sua evolução e mantenha os scripts atualizados no GitHub.

## Idiomas
- **PT-BR:** explicações e comentários em português.
- **EN:** explanations and comments in English.

As duas versões seguem a mesma sequência de aulas e os mesmos exemplos técnicos.

## Sobre o projeto

Este é um projeto de aprendizado contínuo e portfólio. O objetivo é praticar SQL Server, documentar a evolução técnica e compartilhar exemplos que possam ser revisados por outros desenvolvedores e recrutadores.

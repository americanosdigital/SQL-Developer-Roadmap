
<div>
<div class="Box-JYjgF4" data-d-align="center" data-d-auto-spacing="" data-d-component="box" data-d-direction="col" style="--smoothing-background-color: #0070BA; border-radius: var(--dil-radius-md); --w-box-gutter-block-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-block-start: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-start: calc(var(--spacing, 0.25rem) * 3); padding-block: calc(var(--spacing, 0.25rem) * 3); padding-inline: calc(var(--spacing, 0.25rem) * 3); background-color: rgb(0, 112, 186);">
    <div class="Box-JYjgF4" data-d-align="center" data-d-component="row" data-d-direction="row" data-d-justify="center" style="gap: calc(var(--spacing, 0.25rem) * 2);">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-coffee" data-d-component="icon" style="color: rgb(255, 255, 255); font-size: 18px;">
            <path d="M10 2v2">                
            </path>
            <path d="M14 2v2">
            </path>
            <path d="M16 8a1 1 0 0 1 1 1v8a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4V9a1 1 0 0 1 1-1h14a4 4 0 1 1 0 8h-1">
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

<div class="Box-JYjgF4" data-d-align="center" data-d-auto-spacing="" data-d-component="box" data-d-direction="col" style="--smoothing-background-color: #0070BA; border-radius: var(--dil-radius-md); --w-box-gutter-block-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-block-start: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-start: calc(var(--spacing, 0.25rem) * 3); padding-block: calc(var(--spacing, 0.25rem) * 3); padding-inline: calc(var(--spacing, 0.25rem) * 3); background-color: rgb(0, 112, 186);">
    <a href="https://www.buymeacoffee.com/americanosdigital">
        <img src="https://img.buymeacoffee.com/button-api/?text=Pague-me um café&emoji=&slug=americanosdigital&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00" />
    </a>
</div>

</div>

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


<div>
<div class="Box-JYjgF4" data-d-align="center" data-d-auto-spacing="" data-d-component="box" data-d-direction="col" style="--smoothing-background-color: #0070BA; border-radius: var(--dil-radius-md); --w-box-gutter-block-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-block-start: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-start: calc(var(--spacing, 0.25rem) * 3); padding-block: calc(var(--spacing, 0.25rem) * 3); padding-inline: calc(var(--spacing, 0.25rem) * 3); background-color: rgb(0, 112, 186);">
    <div class="Box-JYjgF4" data-d-align="center" data-d-component="row" data-d-direction="row" data-d-justify="center" style="gap: calc(var(--spacing, 0.25rem) * 2);">
        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-coffee" data-d-component="icon" style="color: rgb(255, 255, 255); font-size: 18px;">
            <path d="M10 2v2">                
            </path>
            <path d="M14 2v2">
            </path>
            <path d="M16 8a1 1 0 0 1 1 1v8a4 4 0 0 1-4 4H7a4 4 0 0 1-4-4V9a1 1 0 0 1 1-1h14a4 4 0 1 1 0 8h-1">
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

<div class="Box-JYjgF4" data-d-align="center" data-d-auto-spacing="" data-d-component="box" data-d-direction="col" style="--smoothing-background-color: #0070BA; border-radius: var(--dil-radius-md); --w-box-gutter-block-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-block-start: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-end: calc(var(--spacing, 0.25rem) * 3); --w-box-gutter-inline-start: calc(var(--spacing, 0.25rem) * 3); padding-block: calc(var(--spacing, 0.25rem) * 3); padding-inline: calc(var(--spacing, 0.25rem) * 3); background-color: rgb(0, 112, 186);">
    <a href="https://www.buymeacoffee.com/americanosdigital">
        <img src="https://img.buymeacoffee.com/button-api/?text=Pague-me um café&emoji=&slug=americanosdigital&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00" />
    </a>
</div>

</div>

# Projeto Sprint 7 — Zuber Rideshare (Chicago)

## Contexto
Analista de dados da Zuber, empresa de compartilhamento de caronas em Chicago.
Objetivo: encontrar padrões nas preferências dos passageiros e testar o impacto do clima nas corridas.

---

## Banco de Dados — Estrutura das Tabelas

### neighborhoods
| Campo | Tipo | Descrição |
|---|---|---|
| neighborhood_id | INT (PK) | Código do bairro |
| name | VARCHAR | Nome do bairro |

### cabs
| Campo | Tipo | Descrição |
|---|---|---|
| cab_id | INT (PK) | Código do veículo |
| vehicle_id | VARCHAR | Identificação técnica |
| company_name | VARCHAR | Empresa proprietária |

### trips
| Campo | Tipo | Descrição |
|---|---|---|
| trip_id | INT (PK) | Código da corrida |
| cab_id | INT (FK → cabs) | Código do veículo |
| start_ts | TIMESTAMP | Início da corrida (arredondado para hora) |
| end_ts | TIMESTAMP | Fim da corrida (arredondado para hora) |
| duration_seconds | INT | Duração em segundos |
| distance_miles | FLOAT | Distância em milhas |
| pickup_location_id | INT (FK → neighborhoods) | Bairro de retirada |
| dropoff_location_id | INT (FK → neighborhoods) | Bairro de entrega |

### weather_records
| Campo | Tipo | Descrição |
|---|---|---|
| record_id | INT (PK) | Código do registro |
| ts | TIMESTAMP | Data e hora (arredondado para hora) |
| temperature | FLOAT | Temperatura no momento |
| description | VARCHAR | Descrição do clima (ex: "light rain", "scattered clouds") |

---

## Diagrama ER — Relacionamentos entre Tabelas

```
┌─────────────────────┐        ┌──────────────────┐
│        trips        │        │       cabs       │
├─────────────────────┤        ├──────────────────┤
│ PK  trip_id         │───────>│ PK  cab_id       │
│ FK  cab_id          │        │     vehicle_id   │
│     start_ts        │        │     company_name │
│     end_ts          │        └──────────────────┘
│     duration_seconds│
│     distance_miles  │        ┌──────────────────┐
│ FK  pickup_location │───────>│  neighborhoods   │
│ FK  dropoff_location│───────>├──────────────────┤
└─────────────────────┘        │ PK  neighborhood_│
                               │     name         │
                               └──────────────────┘

┌──────────────────────┐
│   weather_records    │  ← SEM chave estrangeira!
├──────────────────────┤     JOIN só por horário:
│ PK  record_id        │     trips.start_ts = weather_records.ts
│     description      │
│     ts               │
│     temperature      │
└──────────────────────┘
```

**Relacionamentos confirmados pelo diagrama:**
- `trips.cab_id` → `cabs.cab_id` (N:1 — várias corridas por veículo)
- `trips.pickup_location_id` → `neighborhoods.neighborhood_id` (N:1)
- `trips.dropoff_location_id` → `neighborhoods.neighborhood_id` (N:1)
- `trips` ↔ `weather_records` → **sem FK direta**, JOIN via `start_ts = ts`

### ⚠️ Atenção
Não há chave estrangeira direta entre `trips` e `weather_records`.
O JOIN deve ser feito por horário: `trips.start_ts = weather_records.ts`

---

## Entregas do Projeto

### PASSO 1 — Web Scraping (Python)
- [ ] Coletar dados climáticos de Chicago em novembro de 2017
- URL: https://practicum-content.s3.us-west-1.amazonaws.com/data-analyst-eng/moved_chicago_weather_2017.html
- Bibliotecas esperadas: `requests`, `BeautifulSoup`, `pandas`
- Salvar resultado estruturado em DataFrame

---

### PASSO 2 — Análise Exploratória de Dados (SQL)

#### Tarefa 2.1
- Corridas por empresa de táxi entre **15 e 16 de novembro de 2017**
- Campos: `company_name`, `trips_amount`
- Ordenar por `trips_amount` DESC

#### Tarefa 2.2
- Corridas de empresas cujo nome contém **"Yellow"** ou **"Blue"**
- Período: **1 a 7 de novembro de 2017**
- Campo resultante: `trips_amount`
- Agrupar por `company_name`

#### Tarefa 2.3
- Focar em **Flash Cab** e **Taxi Affiliation Services**
- Todas as outras empresas → grupo **"Other"**
- Campo de empresas: `company`
- Campo de corridas: `trips_amount`
- Ordenar por `trips_amount` DESC

---

### PASSO 3 — Teste de Hipótese (SQL)

#### Tarefa 3.1
- Buscar `neighborhood_id` de **O'Hare** e **Loop** na tabela `neighborhoods`

#### Tarefa 3.2
- Para cada hora em `weather_records`, classificar condições com `CASE`:
  - `"Bad"` → `description` contém "rain" ou "storm"
  - `"Good"` → demais casos
- Campo resultante: `weather_conditions`
- Retornar: `ts`, `weather_conditions`

#### Tarefa 3.3
- Corridas que:
  - Saíram do **Loop** (`pickup_location_id = 50`)
  - Chegaram em **O'Hare** (`dropoff_location_id = 63`)
  - Ocorreram em um **sábado**
- Incluir: `weather_conditions` e `duration_seconds`
- Ignorar corridas sem dados climáticos disponíveis
- JOIN entre `trips` e `weather_records` por horário

---

### PASSO 4 — Análise Exploratória (Python)

#### Arquivos de entrada
- `project_sql_result_01.csv` → `company_name`, `trips_amount` (15-16/nov)
- `project_sql_result_04.csv` → `dropoff_location_name`, `average_trips` (nov/2017)

#### Checklist
- [ ] Importar os dois CSVs
- [ ] Verificar tipos de dados (`dtypes`, `info()`)
- [ ] Identificar os **10 principais bairros de destino**
- [ ] Gráfico 1: empresas de táxi × número de corridas
- [ ] Gráfico 2: top 10 bairros por corridas como destino
- [ ] Conclusões escritas para cada gráfico

---

### PASSO 5 — Teste de Hipótese (Python)

#### Arquivo de entrada
- `project_sql_result_07.csv` → `start_ts`, `weather_conditions`, `duration_seconds`

#### Hipótese a testar
> "A duração média das corridas do Loop ao Aeroporto O'Hare muda nos sábados chuvosos."

#### Checklist
- [ ] Definir nível de significância (alfa)
- [ ] Formular hipótese nula (H0) e alternativa (H1)
- [ ] Escolher e justificar o teste estatístico
- [ ] Executar o teste
- [ ] Interpretar o resultado e escrever conclusão

---

## Critérios de Avaliação (o que o revisor vai checar)
- Web scraping correto
- Fatiamento e agrupamento de dados
- Uso correto de JOINs
- Formulação correta das hipóteses
- Escolha justificada do critério de teste
- Conclusões claras
- Comentários em cada etapa

---

## Arquivos do Projeto
```
projeto_sprint7/
│
├── notebooks/
│   ├── passo1_webscraping.ipynb
│   ├── passo2_sql_analise.ipynb (ou .sql)
│   ├── passo3_sql_hipotese.ipynb (ou .sql)
│   ├── passo4_eda_python.ipynb
│   └── passo5_teste_hipotese.ipynb
│
├── data/
│   ├── project_sql_result_01.csv
│   ├── project_sql_result_04.csv
│   └── project_sql_result_07.csv
│
└── README.md
```

---

## Status das Entregas
| Passo | Descrição | Status |
|---|---|---|
| 1 | Web Scraping | ⬜ Pendente |
| 2 | EDA SQL | ⬜ Pendente |
| 3 | Hipótese SQL | ⬜ Pendente |
| 4 | EDA Python | ⬜ Pendente |
| 5 | Teste Hipótese Python | ⬜ Pendente |

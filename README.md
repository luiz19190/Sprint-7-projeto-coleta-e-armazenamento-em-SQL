# Sprint 7 — Coleta e Armazenamento de Dados em SQL por Luiz Trajano

Projeto para a tripleten sobre a análise de dados da **Zuber**, uma startup de compartilhamento de caronas em Chicago. O objetivo foi encontrar padrões nas preferências dos passageiros e testar o impacto do clima nas corridas, combinando web scraping, SQL e Python.

---

## Estrutura do Projeto

```
├── notebooks/
│   ├── passo1_webscraping.ipynb       # Web scraping dos dados climáticos
│   ├── passo4_eda_python.ipynb        # Análise exploratória em Python
│   ├── passo5_teste_hipotese.ipynb    # Teste de hipótese em Python
│   ├── queries_sprint7.sql            # Todas as queries SQL comentadas
│   └── projeto_sprint7_completo.ipynb # Notebook final para submissão
│
└── data/
    ├── moved_project_sql_result_01.csv  # Empresas × corridas (15-16/nov)
    ├── moved_project_sql_result_04.csv  # Bairros de destino × média de corridas
    └── moved_project_sql_result_07.csv  # Corridas Loop → O'Hare em sábados
```

---

## Passo 1 — Web Scraping

Coletei dados climáticos de Chicago referentes a novembro de 2017 a partir de uma página HTML usando `requests` e `BeautifulSoup`. A tabela foi localizada pelo atributo `id="weather_records"` e transformada em um DataFrame pandas com 720 registros (30 dias × 24 horas), contendo data/hora, temperatura e descrição do clima.

**Bibliotecas:** `requests`, `BeautifulSoup`, `pandas`

---

## Passo 2 — Análise Exploratória de Dados (SQL)

Analisei o banco de dados de corridas de táxi de Chicago com três consultas principais:

- **Tarefa 1:** Flash Cab liderou com 19.558 corridas nos dias 15 e 16 de novembro — quase o dobro do segundo colocado.
- **Tarefa 2:** Entre as empresas com "Yellow" ou "Blue" no nome, Yellow Cab (33.668) e Taxi Affiliation Service Yellow (29.213) se destacaram na primeira semana de novembro.
- **Tarefa 3:** Agrupando todas as demais empresas como "Other", o grupo somou 335.771 corridas contra 64.084 da Flash Cab e 37.583 da Taxi Affiliation Services — evidenciando a pulverização do restante do mercado.

---

## Passo 3 — Teste de Hipótese (SQL)

Preparei os dados para o teste estatístico:

- Identifiquei os IDs dos bairros: **Loop = 50** e **O'Hare = 63**
- Classifiquei as condições climáticas como `"Bad"` (chuva ou tempestade) e `"Good"` (demais casos) usando `CASE WHEN`
- Extraí as corridas do Loop ao O'Hare realizadas em sábados, com JOIN entre `trips` e `weather_records` feito por horário (`start_ts = ts`)

---

## Passo 4 — Análise Exploratória de Dados (Python)

### Empresas de Táxi

Analisei o top 15 empresas por número de corridas. A Flash Cab domina o mercado com certa folga em relação à Taxi Affiliation Services (top 2), quase que com o dobro do total de viagens. Ainda assim, do segundo ao décimo quinto lugar as reduções são graduais, sem grandes disparidades — o que indica um mercado oligopolizado com seu "campeão" fora da curva.

### Top 10 Bairros de Destino

Fiz uma pesquisa externa para entender melhor os bairros presentes. Loop lidera com folga por ser o vibrante centro financeiro e cultural de Chicago, famoso pelo circuito elevado de trens ("L") e atrações como o Millennium Park. River North, em segundo, é conhecido pela grande concentração de restaurantes, galerias e vida noturna. O'Hare aparece em quinto — apesar de ser uma área predominantemente residencial, circunda o movimentado Aeroporto Internacional O'Hare (ORD), o que justifica seu volume considerável de corridas.

**Bibliotecas:** `pandas`, `numpy`, `matplotlib`, `seaborn`

---

## Passo 5 — Teste de Hipótese (Python)

**Hipótese testada:** "A duração média das corridas do Loop ao Aeroporto O'Hare muda nos sábados chuvosos."

- **H0:** A duração média em dias ruins é igual à duração em dias bons — o clima não afeta a duração
- **H1:** A duração média em dias ruins é diferente da duração em dias bons — o clima afeta a duração
- **Alfa:** 0.05
- **Teste utilizado:** Teste de Welch (`ttest_ind` com `equal_var=False`), pois após verificar as variâncias das amostras (`bad.var()` = 520.294 e `good.var()` = 576.382), constatei que são diferentes — o Teste de Welch é a variante do teste t mais adequada nesse caso, pois ajusta os graus de liberdade e garante um resultado estatisticamente mais confiável

**Resultado:** p-value = 6.74e-12 → **rejeito H0**

O resultado foi visualmente confirmado pelo boxplot: a mediana das corridas em dias de clima ruim ultrapassa 2.500 segundos, enquanto em dias bons fica abaixo de 2.000 segundos.

**Conclusão prática para a Zuber:** O clima é uma variável relevante para a operação. Em sábados chuvosos, as corridas do Loop ao O'Hare duram significativamente mais, impactando o planejamento de frotas, a estimativa de chegada e a precificação dinâmica. Considerar a condição climática como fator preditivo pode melhorar a experiência do passageiro e a eficiência operacional da empresa.

**Bibliotecas:** `pandas`, `scipy.stats`, `matplotlib`

---

## Tecnologias Utilizadas

| Ferramenta | Uso |
|---|---|
| Python | Web scraping, EDA e teste de hipótese |
| SQL (PostgreSQL) | Análise exploratória e preparação dos dados |
| pandas | Manipulação de dados |
| matplotlib / seaborn | Visualizações |
| scipy | Teste estatístico |
| BeautifulSoup | Parsing de HTML |

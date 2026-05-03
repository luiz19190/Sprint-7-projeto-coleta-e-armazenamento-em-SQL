-- ============================================================
-- Sprint 7 — Zuber Rideshare Chicago
-- Análise SQL: Exploratória + Teste de Hipótese
-- ============================================================
--
-- Contexto:
-- Analista de dados da Zuber, empresa de compartilhamento de
-- caronas em Chicago. O objetivo é identificar padrões nas
-- preferências dos passageiros e testar o impacto do clima
-- nas corridas.
--
-- Banco de dados:
--   trips          → corridas realizadas
--   cabs           → veículos e empresas
--   neighborhoods  → bairros de Chicago
--   weather_records → registros climáticos por hora
--
-- Nota: trips e weather_records não possuem FK direta.
-- O JOIN é feito por horário: trips.start_ts = weather_records.ts
-- ============================================================


-- ============================================================
-- PASSO 2 — Análise Exploratória de Dados
-- ============================================================

-- Tarefa 1: Corridas por empresa de táxi (15 e 16/nov/2017)
-- Objetivo: identificar quais empresas tiveram maior volume
-- de corridas nos dias 15 e 16 de novembro de 2017.
-- JOIN: trips → cabs via cab_id
SELECT
    cabs.company_name AS company_name,
    COUNT(trips.trip_id) AS trips_amount
FROM
    trips
LEFT JOIN cabs ON trips.cab_id = cabs.cab_id
WHERE
    trips.start_ts::date BETWEEN '2017-11-15' AND '2017-11-16'
GROUP BY
    company_name
ORDER BY
    trips_amount DESC;


-- Tarefa 2: Corridas de empresas com "Yellow" ou "Blue" no nome (1 a 7/nov/2017)
-- Objetivo: analisar o volume de corridas das empresas que
-- contêm "Yellow" ou "Blue" no nome durante a primeira semana.
-- Filtro por nome usa LIKE com % para busca parcial.
SELECT
    cabs.company_name AS company_name,
    COUNT(trips.trip_id) AS trips_amount
FROM
    trips
LEFT JOIN cabs ON trips.cab_id = cabs.cab_id
WHERE
    (company_name LIKE '%Yellow%' OR company_name LIKE '%Blue%')
    AND trips.start_ts::date BETWEEN '2017-11-01' AND '2017-11-07'
GROUP BY
    company_name
ORDER BY
    trips_amount DESC;


-- Tarefa 3: Flash Cab, Taxi Affiliation Services e grupo "Other" (1 a 7/nov/2017)
-- Objetivo: comparar as duas maiores empresas individualmente
-- contra todas as demais agrupadas como "Other".
-- CASE WHEN cria a coluna company dinamicamente.
SELECT
    CASE
        WHEN cabs.company_name = 'Flash Cab' THEN 'Flash Cab'
        WHEN cabs.company_name = 'Taxi Affiliation Services' THEN 'Taxi Affiliation Services'
        ELSE 'Other'
    END AS company,
    COUNT(trips.trip_id) AS trips_amount
FROM
    trips
INNER JOIN cabs ON trips.cab_id = cabs.cab_id
WHERE
    trips.start_ts::date BETWEEN '2017-11-01' AND '2017-11-07'
GROUP BY
    company
ORDER BY
    trips_amount DESC;


-- ============================================================
-- PASSO 3 — Teste de Hipótese
-- Hipótese: a duração média das corridas do Loop ao Aeroporto
-- O'Hare muda nos sábados chuvosos.
-- ============================================================

-- Tarefa 4: neighborhood_id de O'Hare e Loop
-- Resultado: Loop = 50, O'Hare = 63
-- Esses IDs são usados como filtro na Tarefa 6.
SELECT
    neighborhoods.neighborhood_id AS neighborhood_id,
    neighborhoods.name AS name
FROM
    neighborhoods
WHERE
    neighborhoods.name LIKE '%Hare'
    OR neighborhoods.name = 'Loop';


-- Tarefa 5: Classificar condições climáticas como "Bad" ou "Good"
-- "Bad"  → description contém "rain" ou "storm"
-- "Good" → demais casos
-- Essa lógica é reutilizada diretamente na Tarefa 6.
SELECT
    weather_records.ts AS ts,
    CASE
        WHEN weather_records.description LIKE '%rain%' OR weather_records.description LIKE '%storm%' THEN 'Bad'
        ELSE 'Good'
    END AS weather_conditions
FROM
    weather_records;


-- Tarefa 6: Corridas Loop → O'Hare em sábados com condições climáticas e duração
-- Filtra corridas que saíram do Loop (id 50), chegaram em O'Hare (id 63)
-- e ocorreram em sábados (DOW = 6).
-- INNER JOIN garante que só entram corridas com registro climático disponível.
-- O JOIN entre trips e weather_records é feito por horário (start_ts = ts).
SELECT
    trips.start_ts,
    CASE
        WHEN weather_records.description LIKE '%rain%' OR weather_records.description LIKE '%storm%' THEN 'Bad'
        ELSE 'Good'
    END AS weather_conditions,
    trips.duration_seconds
FROM
    trips
INNER JOIN weather_records ON trips.start_ts = weather_records.ts
WHERE
    trips.pickup_location_id = 50
    AND trips.dropoff_location_id = 63
    AND EXTRACT(DOW FROM trips.start_ts) = 6
ORDER BY
    trips.trip_id;

-- =====================================================================
-- FIAP - Global Solution 2026.2 - CitizenTech
-- Disciplina: Database Design
-- Solução: ROTA SECA
-- Integrantes: Felipe Bernardes de Almeida (RM 564360)
--              Guilherme Romero Nogueira de Lima (RM 564431)
-- ---------------------------------------------------------------------
-- Script 3/3: SQL-DQL (consultas)
-- Executar depois do 01_DDL e do 02_DML
-- =====================================================================

-- ---------------------------------------------------------------------
-- CONSULTA 1 - INNER JOIN entre duas tabelas
-- Objetivo: listar os alagamentos reportados que ainda não foram
-- encerrados, com o local e o nível de risco do ponto, para a Defesa
-- Civil saber onde agir primeiro (pontos mais perigosos no topo).
-- Tabelas: RS_OCORRENCIA x RS_PONTO_RISCO
-- ---------------------------------------------------------------------
SELECT o.ID_OCORRENCIA,
       o.DS_STATUS,
       TO_CHAR(o.DT_OCORRENCIA, 'DD/MM/YYYY HH24:MI') AS DATA_OCORRENCIA,
       o.NR_LAMINA_CM,
       p.DS_LOCAL,
       p.DS_NIVEL_RISCO
  FROM RS_OCORRENCIA o
 INNER JOIN RS_PONTO_RISCO p
    ON p.ID_PONTO_RISCO = o.ID_PONTO_RISCO
 WHERE o.DS_STATUS <> 'ENCERRADA'
 ORDER BY CASE p.DS_NIVEL_RISCO
               WHEN 'MUITO_ALTO' THEN 1
               WHEN 'ALTO'       THEN 2
               WHEN 'MODERADO'   THEN 3
               ELSE 4
          END,
          o.DT_OCORRENCIA;

-- ---------------------------------------------------------------------
-- CONSULTA 2 - INNER JOIN com funções de grupo e GROUP BY
-- Objetivo: resumo da chuva por bairro: quantas leituras houve, a maior
-- e a média de precipitação (mm/h). Mostra quais bairros recebem as
-- chuvas mais fortes e devem ter prioridade no plano de prevenção.
-- Tabelas: RS_BAIRRO x RS_LEITURA_CHUVA
-- Funções de grupo: COUNT, MAX, AVG
-- ---------------------------------------------------------------------
SELECT b.ID_BAIRRO,
       b.NM_BAIRRO,
       COUNT(l.ID_LEITURA)                AS QT_LEITURAS,
       MAX(l.VL_PRECIPITACAO_MM)          AS MAIOR_CHUVA_MM_H,
       ROUND(AVG(l.VL_PRECIPITACAO_MM), 2) AS MEDIA_CHUVA_MM_H
  FROM RS_BAIRRO b
 INNER JOIN RS_LEITURA_CHUVA l
    ON l.ID_BAIRRO = b.ID_BAIRRO
 GROUP BY b.ID_BAIRRO, b.NM_BAIRRO
 ORDER BY MAIOR_CHUVA_MM_H DESC;

-- ---------------------------------------------------------------------
-- CONSULTA 3 - LEFT OUTER JOIN com WHERE e ORDER BY
-- Objetivo: para os bairros mais populosos (30 mil habitantes ou mais),
-- listar os pontos de apoio ATIVOS. Por causa do LEFT OUTER JOIN, o
-- bairro sem ponto de apoio ativo também aparece, com os campos do ponto
-- vazios, e é marcado como prioridade.
-- Tabelas: RS_BAIRRO x RS_PONTO_APOIO
-- Obs.: a condição ST_ATIVO = 'S' fica no ON para não "anular" o LEFT JOIN;
-- o filtro de população fica no WHERE.
-- ---------------------------------------------------------------------
SELECT b.NM_BAIRRO,
       b.NR_POPULACAO,
       pa.NM_PONTO,
       pa.DS_TIPO,
       pa.NR_CAPACIDADE,
       CASE WHEN pa.ID_PONTO_APOIO IS NULL
            THEN 'SEM PONTO DE APOIO ATIVO - PRIORIDADE'
            ELSE 'ATENDIDO'
       END AS SITUACAO
  FROM RS_BAIRRO b
  LEFT OUTER JOIN RS_PONTO_APOIO pa
    ON pa.ID_BAIRRO = b.ID_BAIRRO
   AND pa.ST_ATIVO = 'S'
 WHERE b.NR_POPULACAO >= 30000
 ORDER BY b.NR_POPULACAO DESC, pa.NR_CAPACIDADE DESC;

-- =============================================================================
-- SCRIPT 03: CONSULTAS ANALITICAS OLAP (Q1, Q2 Y Q3) Y RECONCILIACION
-- =============================================================================
USE DM_MINSA_VACUNACION;
GO

-- Q1: Cobertura de 2da Dosis y Semaforo Epidemiologico por Departamento
SELECT 
    u.departamento,
    SUM(CASE WHEN f.num_dosis = 2 THEN f.cant_aplicaciones ELSE 0 END) AS total_segunda_dosis,
    MAX(u.poblacion_meta) AS poblacion_meta_departamental,
    CAST(SUM(CASE WHEN f.num_dosis = 2 THEN f.cant_aplicaciones ELSE 0 END) * 100.0 / MAX(u.poblacion_meta) AS DECIMAL(5,2)) AS pct_cobertura_2da
FROM dbo.FACT_VACUNACION f
INNER JOIN dbo.DIM_UBIGEO u ON f.id_ubigeo = u.id_ubigeo
GROUP BY u.departamento
ORDER BY pct_cobertura_2da DESC;

-- Q2: Tasa de Desercion entre 1ra y 2da Dosis por Etapa de Vida y Fabricante
SELECT 
    g.etapa_vida_minsa,
    v.fabricante,
    SUM(CASE WHEN f.num_dosis = 1 THEN f.cant_aplicaciones ELSE 0 END) AS dosis_1,
    SUM(CASE WHEN f.num_dosis = 2 THEN f.cant_aplicaciones ELSE 0 END) AS dosis_2,
    CAST((SUM(CASE WHEN f.num_dosis = 1 THEN f.cant_aplicaciones ELSE 0 END) - SUM(CASE WHEN f.num_dosis = 2 THEN f.cant_aplicaciones ELSE 0 END)) * 100.0 / 
         NULLIF(SUM(CASE WHEN f.num_dosis = 1 THEN f.cant_aplicaciones ELSE 0 END), 0) AS DECIMAL(5,2)) AS tasa_desercion_pct
FROM dbo.FACT_VACUNACION f
INNER JOIN dbo.DIM_GRUPO_ETARIO g ON f.id_grupo_etario = g.id_grupo_etario
INNER JOIN dbo.DIM_VACUNA v ON f.id_vacuna = v.id_vacuna
GROUP BY g.etapa_vida_minsa, v.fabricante
ORDER BY tasa_desercion_pct DESC;

-- Q3: Avance de Dosis de Refuerzo en Adulto Mayor (60+)
SELECT 
    u.departamento,
    u.distrito,
    SUM(CASE WHEN f.num_dosis = 2 THEN f.cant_aplicaciones ELSE 0 END) AS dosis_2_aplicadas,
    SUM(CASE WHEN f.num_dosis = 3 THEN f.cant_aplicaciones ELSE 0 END) AS dosis_refuerzo_aplicadas,
    CAST(SUM(CASE WHEN f.num_dosis = 3 THEN f.cant_aplicaciones ELSE 0 END) * 100.0 / 
         NULLIF(SUM(CASE WHEN f.num_dosis = 2 THEN f.cant_aplicaciones ELSE 0 END), 0) AS DECIMAL(5,2)) AS avance_refuerzo_pct
FROM dbo.FACT_VACUNACION f
INNER JOIN dbo.DIM_UBIGEO u ON f.id_ubigeo = u.id_ubigeo
INNER JOIN dbo.DIM_GRUPO_ETARIO g ON f.id_grupo_etario = g.id_grupo_etario
WHERE g.etapa_vida_minsa = 'Adulto Mayor (60+)'
GROUP BY u.departamento, u.distrito
ORDER BY avance_refuerzo_pct ASC;

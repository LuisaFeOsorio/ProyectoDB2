-- =============================================================================
-- 03_consultas_analisis.sql · ENTREGA 1 - CONSULTAS DE ANALISIS
-- EJECUTAR COMO: TURISMO (XEPDB1)
-- =============================================================================
SET LINESIZE 200 PAGESIZE 80
SET DEFINE OFF

PROMPT === Q1. OCUPACION POR MUNICIPIO Y MES CON PIVOT ===
SELECT *
FROM (
  SELECT m.nombre AS municipio,
         TO_CHAR(rh.fecha_in,'MM') AS mes,
         COUNT(*) AS noches
  FROM reserva_habitacion rh
  JOIN reserva r ON r.id_reserva = rh.id_reserva
  JOIN alojamiento a ON a.id_alojamiento = r.id_alojamiento
  JOIN municipio m ON m.id_municipio = a.id_municipio
  WHERE r.estado IN ('CONFIRMADA','COMPLETADA')
  GROUP BY m.nombre, TO_CHAR(rh.fecha_in,'MM')
)
PIVOT (
  SUM(noches)
  FOR mes IN ('01' AS ENE,'02' AS FEB,'03' AS MAR,'04' AS ABR,'05' AS MAY,'06' AS JUN,
              '07' AS JUL,'08' AS AGO,'09' AS SEP,'10' AS OCT,'11' AS NOV,'12' AS DIC)
)
ORDER BY municipio;

PROMPT === Q2. INGRESOS POR MUNICIPIO, TIPO Y TEMPORADA CON CUBE + GROUPING ===
SELECT m.nombre AS municipio,
       t.nombre AS tipo_alojamiento,
       tmp.categoria AS temporada,
       SUM(rh.valor_estadia) AS ingreso_estadia,
       GROUPING(m.nombre) AS g_mun,
       GROUPING(t.nombre) AS g_tip,
       GROUPING(tmp.categoria) AS g_temp
FROM reserva_habitacion rh
JOIN reserva r ON r.id_reserva = rh.id_reserva
JOIN alojamiento a ON a.id_alojamiento = r.id_alojamiento
JOIN municipio m ON m.id_municipio = a.id_municipio
JOIN tipo_alojamiento t ON t.id_tipo = a.id_tipo
JOIN v_noche_reserva v ON v.id_reserva_hab = rh.id_reserva_hab
JOIN temporada tmp ON tmp.id_temporada = v.id_temporada
WHERE r.estado = 'COMPLETADA'
GROUP BY CUBE (m.nombre, t.nombre, tmp.categoria)
ORDER BY m.nombre NULLS LAST, t.nombre NULLS LAST, tmp.categoria NULLS LAST;

PROMPT === Q3. TOP 3 ALOJAMIENTOS POR MUNICIPIO CON RANK ===
SELECT * FROM (
  SELECT m.nombre AS municipio,
         a.nombre AS alojamiento,
         SUM(rh.valor_estadia) AS ingreso_total,
         RANK() OVER (PARTITION BY m.nombre ORDER BY SUM(rh.valor_estadia) DESC) AS puesto
  FROM reserva_habitacion rh
  JOIN reserva r ON r.id_reserva = rh.id_reserva
  JOIN alojamiento a ON a.id_alojamiento = r.id_alojamiento
  JOIN municipio m ON m.id_municipio = a.id_municipio
  WHERE r.estado = 'COMPLETADA'
  GROUP BY m.nombre, a.nombre
)
WHERE puesto <= 3
ORDER BY municipio, puesto;

PROMPT === Q4. VARIACION MES A MES CON LAG ===
SELECT municipio, anio, mes, reservas_mes,
       LAG(reservas_mes) OVER (PARTITION BY municipio ORDER BY anio, mes) AS reservas_mes_anterior,
       reservas_mes - NVL(LAG(reservas_mes) OVER (PARTITION BY municipio ORDER BY anio, mes), 0) AS variacion
FROM (
  SELECT m.nombre AS municipio,
         EXTRACT(YEAR FROM r.fecha_checkin) AS anio,
         EXTRACT(MONTH FROM r.fecha_checkin) AS mes,
         COUNT(DISTINCT r.id_reserva) AS reservas_mes
  FROM reserva r
  JOIN alojamiento a ON a.id_alojamiento = r.id_alojamiento
  JOIN municipio m ON m.id_municipio = a.id_municipio
  GROUP BY m.nombre, EXTRACT(YEAR FROM r.fecha_checkin), EXTRACT(MONTH FROM r.fecha_checkin)
)
ORDER BY municipio, anio, mes;

PROMPT === Q5. CONSULTA PARAMETRIZADA POR MUNICIPIO ===
SELECT a.nombre AS alojamiento,
       COUNT(DISTINCT r.id_reserva) AS total_reservas,
       SUM(rh.valor_estadia) AS ingreso
FROM reserva r
JOIN reserva_habitacion rh ON rh.id_reserva = r.id_reserva
JOIN alojamiento a ON a.id_alojamiento = r.id_alojamiento
JOIN municipio m ON m.id_municipio = a.id_municipio
WHERE UPPER(m.nombre) = UPPER('&municipio')
  AND r.estado = 'COMPLETADA'
GROUP BY a.nombre
ORDER BY ingreso DESC;

PROMPT === Q6. UNPIVOT - COMPARATIVO POR TRIMESTRE ===
SELECT municipio, trimestre, tipo_dato, valor
FROM (
  SELECT m.nombre AS municipio,
         SUM(CASE WHEN EXTRACT(MONTH FROM r.fecha_checkin) BETWEEN 1 AND 3 THEN 1 ELSE 0 END) AS T1,
         SUM(CASE WHEN EXTRACT(MONTH FROM r.fecha_checkin) BETWEEN 4 AND 6 THEN 1 ELSE 0 END) AS T2,
         SUM(CASE WHEN EXTRACT(MONTH FROM r.fecha_checkin) BETWEEN 7 AND 9 THEN 1 ELSE 0 END) AS T3,
         SUM(CASE WHEN EXTRACT(MONTH FROM r.fecha_checkin) BETWEEN 10 AND 12 THEN 1 ELSE 0 END) AS T4
  FROM reserva r
  JOIN alojamiento a ON a.id_alojamiento = r.id_alojamiento
  JOIN municipio m ON m.id_municipio = a.id_municipio
  WHERE r.estado = 'COMPLETADA'
  GROUP BY m.nombre
)
UNPIVOT (valor FOR trimestre IN (T1 AS 'TRIMESTRE 1', T2 AS 'TRIMESTRE 2', T3 AS 'TRIMESTRE 3', T4 AS 'TRIMESTRE 4'))
ORDER BY municipio, trimestre;

PROMPT === Q7. BRECHA ENTRE ESTRELLAS VS CALIFICACION REAL ===
SELECT a.nombre AS alojamiento,
       m.nombre AS municipio,
       a.estrellas AS estrellas_asignadas,
       ROUND(AVG(re.calificacion),2) AS calificacion_promedio,
       (a.estrellas - ROUND(AVG(re.calificacion),2)) AS brecha
FROM alojamiento a
JOIN municipio m ON m.id_municipio = a.id_municipio
LEFT JOIN resena re ON re.id_alojamiento = a.id_alojamiento
GROUP BY a.nombre, m.nombre, a.estrellas
HAVING COUNT(re.id_resena) >= 5
ORDER BY ABS(a.estrellas - ROUND(AVG(re.calificacion),2)) DESC;
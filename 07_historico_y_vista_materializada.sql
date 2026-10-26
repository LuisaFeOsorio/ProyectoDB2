-- =============================================================================
-- 07_historico_y_vista_materializada.sql · ENTREGA 2 - HISTORICO Y VISTA MATERIALIZADA
-- EJECUTAR COMO: TURISMO (XEPDB1), DESPUES DE 06_admin_tablespace_historico.sql
-- =============================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF

-- -----------------------------------------------------------------------------
-- 1) TABLA RESERVA_HISTORICO EN TABLESPACE TS_HISTORICO
-- -----------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE reserva_historico CASCADE CONSTRAINTS PURGE';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE reserva_historico (
  id_reserva       NUMBER(10)   PRIMARY KEY,
  id_cliente       NUMBER(8),
  id_alojamiento   NUMBER(6),
  fecha_checkin    DATE,
  fecha_checkout   DATE,
  estado           VARCHAR2(12),
  valor_estadia    NUMBER(12),
  valor_servicios  NUMBER(12),
  total_pagado     NUMBER(12),
  fecha_archivo    DATE DEFAULT SYSDATE
) TABLESPACE ts_historico;

-- -----------------------------------------------------------------------------
-- 2) ARCHIVAR RESERVAS CERRADAS ANTERIORES A 2026-01-01
-- -----------------------------------------------------------------------------
DECLARE
  v_cnt NUMBER := 0;
BEGIN
  INSERT INTO reserva_historico (id_reserva, id_cliente, id_alojamiento, fecha_checkin, fecha_checkout, estado, valor_estadia, valor_servicios, total_pagado)
  SELECT r.id_reserva,
         r.id_cliente,
         r.id_alojamiento,
         r.fecha_checkin,
         r.fecha_checkout,
         r.estado,
         NVL((SELECT SUM(rh.valor_estadia) FROM reserva_habitacion rh WHERE rh.id_reserva = r.id_reserva), 0),
         NVL((SELECT SUM(rs.cantidad * rs.precio_unitario) FROM reserva_servicio rs WHERE rs.id_reserva = r.id_reserva), 0),
         NVL((SELECT SUM(p.monto) FROM pago p WHERE p.id_reserva = r.id_reserva AND p.estado = 'EXITOSO'), 0)
  FROM reserva r
  WHERE r.estado IN ('COMPLETADA','CANCELADA')
    AND r.fecha_checkout < DATE '2026-01-01';

  v_cnt := SQL%ROWCOUNT;
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Registros archivados en RESERVA_HISTORICO: ' || v_cnt);
END;
/

-- -----------------------------------------------------------------------------
-- 3) VISTA MATERIALIZADA MV_OCUPACION_MENSUAL
-- -----------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW mv_ocupacion_mensual';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE MATERIALIZED VIEW mv_ocupacion_mensual
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT a.id_alojamiento,
       m.nombre AS municipio,
       TO_CHAR(rh.fecha_in, 'YYYY-MM') AS periodo,
       COUNT(*) AS noches_ocupadas,
       (SELECT COUNT(*) FROM habitacion h WHERE h.id_alojamiento = a.id_alojamiento) * EXTRACT(DAY FROM LAST_DAY(rh.fecha_in)) AS noches_disponibles,
       ROUND(
         COUNT(*) * 100 /
         NULLIF((SELECT COUNT(*) FROM habitacion h WHERE h.id_alojamiento = a.id_alojamiento) * EXTRACT(DAY FROM LAST_DAY(rh.fecha_in)), 0)
       , 2) AS porcentaje_ocupacion
FROM reserva_habitacion rh
JOIN reserva r ON r.id_reserva = rh.id_reserva
JOIN alojamiento a ON a.id_alojamiento = r.id_alojamiento
JOIN municipio m ON m.id_municipio = a.id_municipio
WHERE r.estado IN ('CONFIRMADA','COMPLETADA')
GROUP BY a.id_al
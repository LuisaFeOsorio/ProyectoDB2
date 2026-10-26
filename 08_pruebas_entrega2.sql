-- =============================================================================
-- 08_pruebas_entrega2.sql · ENTREGA 2 - PRUEBAS Y EVIDENCIA
-- EJECUTAR COMO: TURISMO (XEPDB1)
-- =============================================================================
SET SERVEROUTPUT ON
SET LINESIZE 150

PROMPT === PRUEBA 1: FUNCION FN_VALOR_ESTADIA ===
DECLARE
  v_val NUMBER;
BEGIN
  SELECT MIN(id_habitacion) INTO v_val FROM habitacion;
  v_val := pkg_turismo.fn_valor_estadia(v_val, DATE '2026-06-10', DATE '2026-06-13');
  DBMS_OUTPUT.PUT_LINE('Valor estadia 3 noches: '||v_val);
END;
/

PROMPT === PRUEBA 2: PAQUETE EXISTE ===
SELECT object_name, status FROM user_objects WHERE object_name = 'PKG_TURISMO';

PROMPT === PRUEBA 3: TRIGGERS CREADOS ===
SELECT trigger_name, status FROM user_triggers WHERE trigger_name IN ('TRG_AUD_TARIFA','TRG_SOLAPE_HAB');

PROMPT === PRUEBA 4: TABLESPACE HISTORICO ===
SELECT table_name, tablespace_name FROM user_tables WHERE table_name = 'RESERVA_HISTORICO';

PROMPT === PRUEBA 5: VISTA MATERIALIZADA ===
SELECT mview_name, refresh_method FROM user_mviews WHERE mview_name = 'MV_OCUPACION_MENSUAL';

PROMPT === PRUEBA 6: CONTEO GENERAL ===
SELECT 'RESERVAS' AS TIPO, COUNT(*) AS TOTAL FROM reserva
UNION ALL SELECT 'HABITACIONES POR RESERVA', COUNT(*) FROM reserva_habitacion
UNION ALL SELECT 'PAGOS', COUNT(*) FROM pago
UNION ALL SELECT 'SERVICIOS', COUNT(*) FROM reserva_servicio
UNION ALL SELECT 'RESEÑAS', COUNT(*) FROM resena;
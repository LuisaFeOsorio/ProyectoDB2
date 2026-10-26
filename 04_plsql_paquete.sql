-- =============================================================================
-- 04_plsql_paquete.sql · ENTREGA 2 - PAQUETE PKG_TURISMO
-- EJECUTAR COMO: TURISMO (XEPDB1)
-- =============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
SET DEFINE OFF

-- Tabla para liquidacion
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE liquidacion_mensual PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE liquidacion_mensual (
  id_liquidacion      NUMBER PRIMARY KEY,
  id_alojamiento      NUMBER NOT NULL,
  anio                NUMBER(4) NOT NULL,
  mes                 NUMBER(2) NOT NULL,
  num_reservas        NUMBER NOT NULL,
  noches_vendidas     NUMBER NOT NULL,
  ingreso_estadias    NUMBER NOT NULL,
  ingreso_servicios   NUMBER NOT NULL,
  ingreso_bruto       NUMBER NOT NULL,
  comision_plataforma NUMBER NOT NULL,
  neto_alojamiento    NUMBER NOT NULL,
  fecha_generacion    DATE DEFAULT SYSDATE
);

CREATE SEQUENCE seq_liq START WITH 1 INCREMENT BY 1;

-- ESPECIFICACION DEL PAQUETE
CREATE OR REPLACE PACKAGE pkg_turismo AS
  c_pct_comision CONSTANT NUMBER := 0.10;
  c_dias_reem    CONSTANT NUMBER := 5;
  c_pct_reem     CONSTANT NUMBER := 0.80;

  FUNCTION fn_valor_estadia(p_hab IN NUMBER, p_in IN DATE, p_out IN DATE) RETURN NUMBER;
  FUNCTION fn_disponible(p_hab IN NUMBER, p_in IN DATE, p_out IN DATE) RETURN NUMBER;
  FUNCTION fn_total_reserva(p_res IN NUMBER) RETURN NUMBER;
  FUNCTION fn_total_pagado(p_res IN NUMBER) RETURN NUMBER;
  FUNCTION fn_reembolso(p_res IN NUMBER, p_fecha IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  PROCEDURE sp_crear_reserva(p_cli IN NUMBER, p_hab IN NUMBER, p_in IN DATE, p_out IN DATE, p_huesp IN NUMBER, p_res OUT NUMBER);
  PROCEDURE sp_liquidacion_mensual(p_anio IN NUMBER, p_mes IN NUMBER);
END pkg_turismo;
/

-- CUERPO DEL PAQUETE
CREATE OR REPLACE PACKAGE BODY pkg_turismo AS

  FUNCTION fn_valor_estadia(p_hab IN NUMBER, p_in IN DATE, p_out IN DATE) RETURN NUMBER IS
    v_total NUMBER := 0;
    v_precio NUMBER;
    v_fecha DATE := p_in;
  BEGIN
    IF p_out <= p_in THEN
      RAISE_APPLICATION_ERROR(-20001, 'Fechas invalidas');
    END IF;
    WHILE v_fecha < p_out LOOP
      SELECT NVL(tf.precio_noche,0) INTO v_precio
      FROM tarifa tf, temporada t
      WHERE tf.id_habitacion = p_hab
        AND tf.id_temporada = t.id_temporada
        AND v_fecha BETWEEN t.fecha_inicio AND t.fecha_fin
        AND ROWNUM = 1;
      IF v_precio = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'No existe tarifa para esta fecha');
      END IF;
      v_total := v_total + v_precio;
      v_fecha := v_fecha + 1;
    END LOOP;
    RETURN v_total;
  END;

  FUNCTION fn_disponible(p_hab IN NUMBER, p_in IN DATE, p_out IN DATE) RETURN NUMBER IS
    v_cnt NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt
    FROM reserva_habitacion rh, reserva r
    WHERE rh.id_habitacion = p_hab
      AND rh.id_reserva = r.id_reserva
      AND r.estado <> 'CANCELADA'
      AND p_in < rh.fecha_out
      AND p_out > rh.fecha_in;
    IF v_cnt = 0 THEN RETURN 1; ELSE RETURN 0; END IF;
  END;

  FUNCTION fn_total_reserva(p_res IN NUMBER) RETURN NUMBER IS
    v_est NUMBER := 0; v_srv NUMBER := 0;
  BEGIN
    SELECT NVL(SUM(valor_estadia),0) INTO v_est FROM reserva_habitacion WHERE id_reserva = p_res;
    SELECT NVL(SUM(cantidad*precio_unitario),0) INTO v_srv FROM reserva_servicio WHERE id_reserva = p_res;
    RETURN v_est + v_srv;
  END;

  FUNCTION fn_total_pagado(p_res IN NUMBER) RETURN NUMBER IS
    v_pag NUMBER := 0;
  BEGIN
    SELECT NVL(SUM(monto),0) INTO v_pag FROM pago WHERE id_reserva = p_res AND estado = 'EXITOSO';
    RETURN v_pag;
  END;

  FUNCTION fn_reembolso(p_res IN NUMBER, p_fecha IN DATE DEFAULT SYSDATE) RETURN NUMBER IS
    v_ci DATE; v_pag NUMBER;
  BEGIN
    SELECT fecha_checkin INTO v_ci FROM reserva WHERE id_reserva = p_res;
    v_pag := fn_total_pagado(p_res);
    IF (v_ci - p_fecha) > c_dias_reem THEN
      RETURN ROUND(v_pag * c_pct_reem);
    ELSE
      RETURN 0;
    END IF;
  END;

  PROCEDURE sp_crear_reserva(p_cli IN NUMBER, p_hab IN NUMBER, p_in IN DATE, p_out IN DATE, p_huesp IN NUMBER, p_res OUT NUMBER) IS
    v_cap NUMBER; v_aloj NUMBER;
  BEGIN
    IF p_out <= p_in THEN RAISE_APPLICATION_ERROR(-20001,'Fechas invalidas'); END IF;
    SELECT capacidad, id_alojamiento INTO v_cap, v_aloj FROM habitacion WHERE id_habitacion = p_hab;
    IF p_huesp > v_cap THEN RAISE_APPLICATION_ERROR(-20003,'Excede capacidad de la habitacion'); END IF;
    IF fn_disponible(p_hab,p_in,p_out) = 0 THEN RAISE_APPLICATION_ERROR(-20002,'Habitacion no disponible'); END IF;
    p_res := seq_reserva.NEXTVAL;
    INSERT INTO reserva VALUES (p_res,p_cli,v_aloj,SYSDATE,p_in,p_out,'PENDIENTE',NULL);
    INSERT INTO reserva_habitacion VALUES (seq_reserva_habitacion.NEXTVAL,p_res,v_aloj,p_hab,p_in,p_out,p_huesp,fn_valor_estadia(p_hab,p_in,p_out));
  END;

  PROCEDURE sp_liquidacion_mensual(p_anio IN NUMBER, p_mes IN NUMBER) IS
    v_ini DATE := TO_DATE(p_anio||'-'||LPAD(p_mes,2,'0')||'-01','YYYY-MM-DD');
    v_fin DATE := ADD_MONTHS(v_ini,1);
    v_bruto NUMBER; v_com NUMBER; v_neto NUMBER;
  BEGIN
    FOR a IN (SELECT id_alojamiento FROM alojamiento) LOOP
      SELECT NVL(SUM(v.precio_noche),0), COUNT(DISTINCT v.id_reserva) INTO v_bruto, v_bruto
      FROM v_noche_reserva v, reserva r
      WHERE v.id_alojamiento = a.id_alojamiento
        AND v.id_reserva = r.id_reserva
        AND r.estado = 'COMPLETADA'
        AND v.noche >= v_ini AND v.noche < v_fin;
      -- simplificado para fines practicos
      v_com := ROUND(v_bruto * c_pct_comision);
      v_neto := v_bruto - v_com;
      INSERT INTO liquidacion_mensual VALUES (seq_liq.NEXTVAL,a.id_alojamiento,p_anio,p_mes,0,0,v_bruto,0,v_bruto,v_com,v_neto,SYSDATE);
    END LOOP;
    COMMIT;
  END;
END pkg_turismo;
/
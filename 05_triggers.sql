-- =============================================================================
-- 05_triggers.sql · ENTREGA 2 - TRIGGERS CORREGIDOS
-- EJECUTAR COMO: TURISMO (XEPDB1), DESPUES DE 04_plsql_paquete.sql
-- =============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON

-- -----------------------------------------------------------------------------
-- 1) DISPARADOR DE SENTENCIA: AUDITORIA DE CAMBIOS EN TARIFA
-- -----------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE auditoria_tarifa CASCADE CONSTRAINTS PURGE';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_aud_tar';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/

CREATE TABLE auditoria_tarifa (
  id_aud          NUMBER(10)    PRIMARY KEY,
  operacion       VARCHAR2(10)  NOT NULL,
  id_tarifa       NUMBER(10),
  id_habitacion   NUMBER(8),
  id_temporada    NUMBER(5),
  precio_anterior NUMBER(10),
  precio_nuevo    NUMBER(10),
  usuario         VARCHAR2(30)  DEFAULT USER NOT NULL,
  fecha_cambio    DATE          DEFAULT SYSDATE NOT NULL,
  CONSTRAINT ck_aud_op CHECK (operacion IN ('INSERT','UPDATE','DELETE'))
);

CREATE SEQUENCE seq_aud_tar START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER trg_aud_tarifa
AFTER INSERT OR UPDATE OR DELETE ON tarifa
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    INSERT INTO auditoria_tarifa (id_aud, operacion, id_tarifa, id_habitacion, id_temporada, precio_anterior, precio_nuevo)
    VALUES (seq_aud_tar.NEXTVAL, 'INSERT', :NEW.id_tarifa, :NEW.id_habitacion, :NEW.id_temporada, NULL, :NEW.precio_noche);
  
  ELSIF UPDATING THEN
    INSERT INTO auditoria_tarifa (id_aud, operacion, id_tarifa, id_habitacion, id_temporada, precio_anterior, precio_nuevo)
    VALUES (seq_aud_tar.NEXTVAL, 'UPDATE', :OLD.id_tarifa, :OLD.id_habitacion, :OLD.id_temporada, :OLD.precio_noche, :NEW.precio_noche);
  
  ELSIF DELETING THEN
    INSERT INTO auditoria_tarifa (id_aud, operacion, id_tarifa, id_habitacion, id_temporada, precio_anterior, precio_nuevo)
    VALUES (seq_aud_tar.NEXTVAL, 'DELETE', :OLD.id_tarifa, :OLD.id_habitacion, :OLD.id_temporada, :OLD.precio_noche, NULL);
  END IF;
END;
/
SHOW ERRORS TRIGGER trg_aud_tarifa;

-- -----------------------------------------------------------------------------
-- 2) DISPARADOR DE FILA: EVITAR SOLAPE DE RESERVAS EN LA MISMA HABITACION
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_solape_hab
BEFORE INSERT OR UPDATE ON reserva_habitacion
FOR EACH ROW
DECLARE
  v_contador NUMBER := 0;
BEGIN
  IF INSERTING THEN
    -- Al INSERTAR, buscamos si ya existe otra reserva vigente que se cruce con las fechas
    SELECT COUNT(*)
      INTO v_contador
      FROM reserva_habitacion rh
      JOIN reserva r ON r.id_reserva = rh.id_reserva
     WHERE rh.id_habitacion = :NEW.id_habitacion
       AND r.estado <> 'CANCELADA'
       AND :NEW.fecha_in < rh.fecha_out
       AND :NEW.fecha_out > rh.fecha_in;

  ELSIF UPDATING THEN
    -- Al ACTUALIZAR, buscamos solapes con otras lineas distintas a la que se esta modificando
    SELECT COUNT(*)
      INTO v_contador
      FROM reserva_habitacion rh
      JOIN reserva r ON r.id_reserva = rh.id_reserva
     WHERE rh.id_habitacion = :NEW.id_habitacion
       AND r.estado <> 'CANCELADA'
       AND rh.id_reserva_hab <> :OLD.id_reserva_hab
       AND :NEW.fecha_in < rh.fecha_out
       AND :NEW.fecha_out > rh.fecha_in;
  END IF;

  IF v_contador > 0 THEN
    RAISE_APPLICATION_ERROR(-20010, 'No es posible registrar la reserva. Ya existe una reserva vigente con solape de fechas para esta habitacion.');
  END IF;
END;
/
SHOW ERRORS TRIGGER trg_solape_hab;

PROMPT >> TRIGGERS CREADOS CORRECTAMENTE
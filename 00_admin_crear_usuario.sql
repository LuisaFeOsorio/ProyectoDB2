-- =============================================================================
-- 00_admin_crear_usuario.sql
-- PROYECTO INTEGRADOR BD II - TurismoUQ (Oracle XE 21c)
-- =============================================================================

SET SERVEROUTPUT ON
WHENEVER SQLERROR CONTINUE

-- 1) BORRADO IDEMPOTENTE DEL ESQUEMA
BEGIN
  EXECUTE IMMEDIATE 'DROP USER turismo CASCADE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1918 THEN RAISE; END IF;
END;
/

-- 2) CREACIÓN DEL ESQUEMA DUEÑO DE TODOS LOS OBJETOS
CREATE USER turismo IDENTIFIED BY "Turismo2026#"
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON users;

-- 3) PRIVILEGIOS MÍNIMOS NECESARIOS
GRANT CREATE SESSION,
      CREATE TABLE,
      CREATE VIEW,
      CREATE SEQUENCE,
      CREATE PROCEDURE,
      CREATE TRIGGER,
      CREATE TYPE,
      CREATE SYNONYM,
      CREATE MATERIALIZED VIEW,
      CREATE JOB TO turismo;

PROMPT >> Usuario TURISMO creado. Siguiente paso: conectarse como TURISMO y correr 01_ddl.sql
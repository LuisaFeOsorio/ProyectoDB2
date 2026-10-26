-- =============================================================================
-- 06_admin_tablespace_historico.sql · ENTREGA 2 - TABLESPACE
-- EJECUTAR COMO: SYSTEM @XEPDB1
-- =============================================================================
CREATE TABLESPACE ts_historico
DATAFILE 'ts_historico.dbf' SIZE 50M
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

GRANT CREATE TABLE, CREATE VIEW, UNLIMITED TABLESPACE TO TURISMO;
-- =============================================================================
-- 01_ddl.sql · ENTREGA 1 · MODELO FÍSICO DE TurismoUQ
-- =============================================================================
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- ---------------------------------------------------------------------------
-- SECUENCIAS
-- ---------------------------------------------------------------------------
CREATE SEQUENCE seq_municipio          START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_tipo_alojamiento   START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_alojamiento        START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_habitacion         START WITH 1 INCREMENT BY 1 CACHE 100;
CREATE SEQUENCE seq_temporada          START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_tarifa             START WITH 1 INCREMENT BY 1 CACHE 1000;
CREATE SEQUENCE seq_cliente            START WITH 1 INCREMENT BY 1 CACHE 1000;
CREATE SEQUENCE seq_reserva            START WITH 1 INCREMENT BY 1 CACHE 1000;
CREATE SEQUENCE seq_reserva_habitacion START WITH 1 INCREMENT BY 1 CACHE 1000;
CREATE SEQUENCE seq_pago               START WITH 1 INCREMENT BY 1 CACHE 1000;
CREATE SEQUENCE seq_servicio           START WITH 1 INCREMENT BY 1 CACHE 100;
CREATE SEQUENCE seq_reserva_servicio   START WITH 1 INCREMENT BY 1 CACHE 1000;
CREATE SEQUENCE seq_resena             START WITH 1 INCREMENT BY 1 CACHE 1000;
CREATE SEQUENCE seq_usuario_sistema    START WITH 1 INCREMENT BY 1 NOCACHE;

-- ---------------------------------------------------------------------------
-- 1. MUNICIPIO
-- ---------------------------------------------------------------------------
CREATE TABLE municipio (
  id_municipio  NUMBER(4)     DEFAULT seq_municipio.NEXTVAL NOT NULL,
  nombre        VARCHAR2(60)  NOT NULL,
  CONSTRAINT pk_municipio PRIMARY KEY (id_municipio),
  CONSTRAINT uq_municipio_nombre UNIQUE (nombre)
);
COMMENT ON TABLE municipio IS 'Catálogo de los 12 municipios del Quindío. Cada alojamiento pertenece a exactamente uno.';

-- ---------------------------------------------------------------------------
-- 2. TIPO_ALOJAMIENTO
-- ---------------------------------------------------------------------------
CREATE TABLE tipo_alojamiento (
  id_tipo      NUMBER(3)     DEFAULT seq_tipo_alojamiento.NEXTVAL NOT NULL,
  nombre       VARCHAR2(40)  NOT NULL,
  descripcion  VARCHAR2(200),
  CONSTRAINT pk_tipo_alojamiento PRIMARY KEY (id_tipo),
  CONSTRAINT uq_tipo_alojamiento_nombre UNIQUE (nombre)
);
COMMENT ON TABLE tipo_alojamiento IS 'Catálogo de tipos de alojamiento (finca cafetera, hotel, glamping, hostal, cabaña ecoturística...). Es tabla y no CHECK para poder agregar tipos sin tocar el esquema.';

-- ---------------------------------------------------------------------------
-- 3. ALOJAMIENTO
-- ---------------------------------------------------------------------------
CREATE TABLE alojamiento (
  id_alojamiento NUMBER(6)     DEFAULT seq_alojamiento.NEXTVAL NOT NULL,
  nombre         VARCHAR2(100) NOT NULL,
  id_municipio   NUMBER(4)     NOT NULL,
  id_tipo        NUMBER(3)     NOT NULL,
  direccion      VARCHAR2(150) NOT NULL,
  estrellas      NUMBER(1)     NOT NULL,
  telefono       VARCHAR2(20),
  correo         VARCHAR2(100) NOT NULL,
  activo         CHAR(1)       DEFAULT 'S' NOT NULL,
  CONSTRAINT pk_alojamiento PRIMARY KEY (id_alojamiento),
  CONSTRAINT fk_aloj_municipio FOREIGN KEY (id_municipio) REFERENCES municipio (id_municipio),
  CONSTRAINT fk_aloj_tipo      FOREIGN KEY (id_tipo)      REFERENCES tipo_alojamiento (id_tipo),
  CONSTRAINT uq_aloj_nombre_mun UNIQUE (id_municipio, nombre),
  CONSTRAINT ck_aloj_estrellas CHECK (estrellas BETWEEN 1 AND 5),
  CONSTRAINT ck_aloj_activo    CHECK (activo IN ('S','N')),
  CONSTRAINT ck_aloj_correo    CHECK (correo LIKE '%@%')
);
COMMENT ON TABLE alojamiento IS 'Oferta de alojamiento de la plataforma. Las estrellas son autoasignadas; la calidad percibida real sale de RESENA.';

-- ---------------------------------------------------------------------------
-- 4. HABITACION
-- ---------------------------------------------------------------------------
CREATE TABLE habitacion (
  id_habitacion  NUMBER(8)      DEFAULT seq_habitacion.NEXTVAL NOT NULL,
  id_alojamiento NUMBER(6)      NOT NULL,
  numero         VARCHAR2(10)   NOT NULL,
  capacidad      NUMBER(2)      NOT NULL,
  tipo           VARCHAR2(10)   NOT NULL,
  descripcion    VARCHAR2(200),
  CONSTRAINT pk_habitacion PRIMARY KEY (id_habitacion),
  CONSTRAINT fk_hab_alojamiento FOREIGN KEY (id_alojamiento) REFERENCES alojamiento (id_alojamiento),
  CONSTRAINT uq_hab_numero      UNIQUE (id_alojamiento, numero),
  CONSTRAINT uq_hab_id_aloj     UNIQUE (id_habitacion, id_alojamiento),
  CONSTRAINT ck_hab_capacidad   CHECK (capacidad BETWEEN 1 AND 12),
  CONSTRAINT ck_hab_tipo        CHECK (tipo IN ('SENCILLA','DOBLE','SUITE','CABANA'))
);
COMMENT ON TABLE habitacion IS 'Unidad reservable. El número es único dentro de su alojamiento. CABANA = cabaña (sin tilde para evitar problemas de codificación).';

-- ---------------------------------------------------------------------------
-- 5. TEMPORADA
-- ---------------------------------------------------------------------------
CREATE TABLE temporada (
  id_temporada  NUMBER(5)     DEFAULT seq_temporada.NEXTVAL NOT NULL,
  nombre        VARCHAR2(80)  NOT NULL,
  categoria     VARCHAR2(5)   NOT NULL,
  anio          NUMBER(4)     NOT NULL,
  fecha_inicio  DATE          NOT NULL,
  fecha_fin     DATE          NOT NULL,
  CONSTRAINT pk_temporada PRIMARY KEY (id_temporada),
  CONSTRAINT uq_temporada_nombre UNIQUE (anio, nombre),
  CONSTRAINT ck_temp_categoria CHECK (categoria IN ('ALTA','MEDIA','BAJA')),
  CONSTRAINT ck_temp_fechas    CHECK (fecha_fin >= fecha_inicio),
  CONSTRAINT ck_temp_anio      CHECK (EXTRACT(YEAR FROM fecha_inicio) = anio AND EXTRACT(YEAR FROM fecha_fin) = anio)
);
COMMENT ON TABLE temporada IS 'Calendario de temporadas por año (alta/media/baja). Se define por año: Semana Santa 2025 y 2026 son filas distintas. El calendario debe cubrir todos los días sin traslapes (se valida en la carga).';

-- ---------------------------------------------------------------------------
-- 6. TARIFA
-- ---------------------------------------------------------------------------
CREATE TABLE tarifa (
  id_tarifa     NUMBER(10)  DEFAULT seq_tarifa.NEXTVAL NOT NULL,
  id_habitacion NUMBER(8)   NOT NULL,
  id_temporada  NUMBER(5)   NOT NULL,
  precio_noche  NUMBER(10)  NOT NULL,
  CONSTRAINT pk_tarifa PRIMARY KEY (id_tarifa),
  CONSTRAINT fk_tar_habitacion FOREIGN KEY (id_habitacion) REFERENCES habitacion (id_habitacion),
  CONSTRAINT fk_tar_temporada  FOREIGN KEY (id_temporada)  REFERENCES temporada (id_temporada),
  CONSTRAINT uq_tarifa_hab_temp UNIQUE (id_habitacion, id_temporada),
  CONSTRAINT ck_tar_precio CHECK (precio_noche > 0)
);
COMMENT ON TABLE tarifa IS 'Precio por noche de una habitación en una temporada (valor propio, no porcentaje sobre un base). Una fila por cada cruce habitación x temporada.';

-- ---------------------------------------------------------------------------
-- 7. CLIENTE
-- ---------------------------------------------------------------------------
CREATE TABLE cliente (
  id_cliente      NUMBER(8)     DEFAULT seq_cliente.NEXTVAL NOT NULL,
  tipo_documento  VARCHAR2(10)  NOT NULL,
  documento       VARCHAR2(20)  NOT NULL,
  nombre          VARCHAR2(80)  NOT NULL,
  apellido        VARCHAR2(80)  NOT NULL,
  correo          VARCHAR2(120) NOT NULL,
  telefono        VARCHAR2(20),
  ciudad_origen   VARCHAR2(60)  NOT NULL,
  fecha_registro  DATE          DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
  CONSTRAINT uq_cliente_doc    UNIQUE (tipo_documento, documento),
  CONSTRAINT uq_cliente_correo UNIQUE (correo),
  CONSTRAINT ck_cli_tipo_doc   CHECK (tipo_documento IN ('CC','CE','PASAPORTE')),
  CONSTRAINT ck_cli_correo     CHECK (correo LIKE '%@%')
);
COMMENT ON TABLE cliente IS 'Huéspedes registrados. Un cliente puede tener muchas reservas; el documento es único por tipo de documento.';

-- ---------------------------------------------------------------------------
-- 8. RESERVA
-- ---------------------------------------------------------------------------
CREATE TABLE reserva (
  id_reserva        NUMBER(10)   DEFAULT seq_reserva.NEXTVAL NOT NULL,
  id_cliente        NUMBER(8)    NOT NULL,
  id_alojamiento    NUMBER(6)    NOT NULL,
  fecha_creacion    DATE         NOT NULL,
  fecha_checkin     DATE         NOT NULL,
  fecha_checkout    DATE         NOT NULL,
  estado            VARCHAR2(12) DEFAULT 'PENDIENTE' NOT NULL,
  fecha_cancelacion DATE,
  CONSTRAINT pk_reserva PRIMARY KEY (id_reserva),
  CONSTRAINT fk_res_cliente     FOREIGN KEY (id_cliente)     REFERENCES cliente (id_cliente),
  CONSTRAINT fk_res_alojamiento FOREIGN KEY (id_alojamiento) REFERENCES alojamiento (id_alojamiento),
  CONSTRAINT uq_res_id_aloj     UNIQUE (id_reserva, id_alojamiento),
  CONSTRAINT uq_res_resena      UNIQUE (id_reserva, id_cliente, id_alojamiento, estado),
  CONSTRAINT ck_res_estado      CHECK (estado IN ('PENDIENTE','CONFIRMADA','CANCELADA','COMPLETADA')),
  CONSTRAINT ck_res_fechas      CHECK (fecha_checkout > fecha_checkin),
  CONSTRAINT ck_res_solo_fecha  CHECK (fecha_checkin = TRUNC(fecha_checkin) AND fecha_checkout = TRUNC(fecha_checkout)),
  CONSTRAINT ck_res_cancel      CHECK ((estado = 'CANCELADA' AND fecha_cancelacion IS NOT NULL)
                                    OR  (estado <> 'CANCELADA' AND fecha_cancelacion IS NULL)),
  CONSTRAINT ck_res_cancel_f    CHECK (fecha_cancelacion IS NULL OR fecha_cancelacion >= fecha_creacion)
);
COMMENT ON TABLE reserva IS 'Cabecera de reserva: un cliente, un alojamiento, un rango general de fechas y un estado. Las habitaciones van en RESERVA_HABITACION. La fecha de cancelación es obligatoria solo si está CANCELADA (base de la regla de reembolso).';

-- ---------------------------------------------------------------------------
-- 9. RESERVA_HABITACION
-- ---------------------------------------------------------------------------
CREATE TABLE reserva_habitacion (
  id_reserva_hab  NUMBER(10)   DEFAULT seq_reserva_habitacion.NEXTVAL NOT NULL,
  id_reserva      NUMBER(10)   NOT NULL,
  id_alojamiento  NUMBER(6)    NOT NULL,
  id_habitacion   NUMBER(8)    NOT NULL,
  fecha_in        DATE         NOT NULL,
  fecha_out       DATE         NOT NULL,
  num_huespedes   NUMBER(2)    NOT NULL,
  valor_estadia   NUMBER(12)   NOT NULL,
  CONSTRAINT pk_reserva_habitacion PRIMARY KEY (id_reserva_hab),
  CONSTRAINT fk_rh_reserva    FOREIGN KEY (id_reserva, id_alojamiento)    REFERENCES reserva (id_reserva, id_alojamiento),
  CONSTRAINT fk_rh_habitacion FOREIGN KEY (id_habitacion, id_alojamiento) REFERENCES habitacion (id_habitacion, id_alojamiento),
  CONSTRAINT uq_rh_linea      UNIQUE (id_reserva, id_habitacion, fecha_in),
  CONSTRAINT ck_rh_fechas     CHECK (fecha_out > fecha_in),
  CONSTRAINT ck_rh_max_noches CHECK (fecha_out - fecha_in <= 30),
  CONSTRAINT ck_rh_solo_fecha CHECK (fecha_in = TRUNC(fecha_in) AND fecha_out = TRUNC(fecha_out)),
  CONSTRAINT ck_rh_huespedes  CHECK (num_huespedes >= 1),
  CONSTRAINT ck_rh_valor      CHECK (valor_estadia > 0)
);
COMMENT ON TABLE reserva_habitacion IS 'Línea de reserva: una habitación con sus propias fechas dentro del rango general. Las FK compuestas garantizan que habitación y reserva sean del mismo alojamiento. El no-solape y la capacidad se validan en sp_crear_reserva y en el disparador de la Entrega 2.';

-- ---------------------------------------------------------------------------
-- 10. PAGO
-- ---------------------------------------------------------------------------
CREATE TABLE pago (
  id_pago      NUMBER(10)   DEFAULT seq_pago.NEXTVAL NOT NULL,
  id_reserva   NUMBER(10)   NOT NULL,
  fecha_pago   DATE         NOT NULL,
  monto        NUMBER(12)   NOT NULL,
  metodo       VARCHAR2(20) NOT NULL,
  estado       VARCHAR2(12) NOT NULL,
  CONSTRAINT pk_pago PRIMARY KEY (id_pago),
  CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva) REFERENCES reserva (id_reserva),
  CONSTRAINT ck_pago_monto   CHECK (monto > 0),
  CONSTRAINT ck_pago_metodo  CHECK (metodo IN ('TARJETA_CREDITO','TARJETA_DEBITO','PSE','TRANSFERENCIA','EFECTIVO')),
  CONSTRAINT ck_pago_estado  CHECK (estado IN ('EXITOSO','FALLIDO','PENDIENTE','REEMBOLSADO'))
);
COMMENT ON TABLE pago IS 'Abonos de una reserva (uno o varios). Una reserva está pagada cuando la suma de pagos EXITOSOS cubre estadía + servicios. REEMBOLSADO marca el pago devuelto por cancelación (80% si hay más de 5 días de anticipación).';

-- ---------------------------------------------------------------------------
-- 11. SERVICIO
-- ---------------------------------------------------------------------------
CREATE TABLE servicio (
  id_servicio    NUMBER(8)     DEFAULT seq_servicio.NEXTVAL NOT NULL,
  id_alojamiento NUMBER(6)     NOT NULL,
  nombre         VARCHAR2(60)  NOT NULL,
  descripcion    VARCHAR2(200),
  precio         NUMBER(10)    NOT NULL,
  activo         CHAR(1)       DEFAULT 'S' NOT NULL,
  CONSTRAINT pk_servicio PRIMARY KEY (id_servicio),
  CONSTRAINT fk_serv_alojamiento FOREIGN KEY (id_alojamiento) REFERENCES alojamiento (id_alojamiento),
  CONSTRAINT uq_serv_aloj_nombre UNIQUE (id_alojamiento, nombre),
  CONSTRAINT uq_serv_id_aloj     UNIQUE (id_servicio, id_alojamiento),
  CONSTRAINT ck_serv_precio CHECK (precio > 0),
  CONSTRAINT ck_serv_activo CHECK (activo IN ('S','N'))
);
COMMENT ON TABLE servicio IS 'Servicio complementario que pertenece a UN alojamiento específico (desayuno, tour, spa...).';

-- ---------------------------------------------------------------------------
-- 12. RESERVA_SERVICIO
-- ---------------------------------------------------------------------------
CREATE TABLE reserva_servicio (
  id_reserva_servicio NUMBER(10)  DEFAULT seq_reserva_servicio.NEXTVAL NOT NULL,
  id_reserva          NUMBER(10)  NOT NULL,
  id_alojamiento      NUMBER(6)   NOT NULL,
  id_servicio         NUMBER(8)   NOT NULL,
  cantidad            NUMBER(3)   NOT NULL,
  precio_unitario     NUMBER(10)  NOT NULL,
  CONSTRAINT pk_reserva_servicio PRIMARY KEY (id_reserva_servicio),
  CONSTRAINT fk_rs_reserva  FOREIGN KEY (id_reserva, id_alojamiento)  REFERENCES reserva (id_reserva, id_alojamiento),
  CONSTRAINT fk_rs_servicio FOREIGN KEY (id_servicio, id_alojamiento) REFERENCES servicio (id_servicio, id_alojamiento),
  CONSTRAINT uq_rs_linea    UNIQUE (id_reserva, id_servicio),
  CONSTRAINT ck_rs_cantidad CHECK (cantidad > 0),
  CONSTRAINT ck_rs_precio   CHECK (precio_unitario > 0)
);
COMMENT ON TABLE reserva_servicio IS 'Servicios contratados dentro de una reserva, con cantidad y precio congelado. Solo se pueden contratar servicios del alojamiento de la reserva (FK compuesta).';

-- ---------------------------------------------------------------------------
-- 13. RESENA
-- ---------------------------------------------------------------------------
CREATE TABLE resena (
  id_resena       NUMBER(10)    DEFAULT seq_resena.NEXTVAL NOT NULL,
  id_reserva      NUMBER(10)    NOT NULL,
  id_cliente      NUMBER(8)     NOT NULL,
  id_alojamiento  NUMBER(6)     NOT NULL,
  estado_reserva  VARCHAR2(12)  DEFAULT 'COMPLETADA' NOT NULL,
  calificacion    NUMBER(1)     NOT NULL,
  comentario      VARCHAR2(500),
  fecha_resena    DATE          NOT NULL,
  CONSTRAINT pk_resena PRIMARY KEY (id_resena),
  CONSTRAINT uq_resena_reserva UNIQUE (id_reserva),
  CONSTRAINT fk_resena_reserva FOREIGN KEY (id_reserva, id_cliente, id_alojamiento, estado_reserva)
             REFERENCES reserva (id_reserva, id_cliente, id_alojamiento, estado),
  CONSTRAINT ck_resena_estado CHECK (estado_reserva = 'COMPLETADA'),
  CONSTRAINT ck_resena_calif  CHECK (calificacion BETWEEN 1 AND 5)
);
COMMENT ON TABLE resena IS 'Reseña de un alojamiento ligada a una reserva COMPLETADA del mismo cliente (regla garantizada por la FK compuesta con estado). Calificación 1-5, comentario opcional.';

-- ---------------------------------------------------------------------------
-- 14. USUARIO_SISTEMA
-- ---------------------------------------------------------------------------
CREATE TABLE usuario_sistema (
  id_usuario      NUMBER(6)     DEFAULT seq_usuario_sistema.NEXTVAL NOT NULL,
  username        VARCHAR2(30)  NOT NULL,
  nombre_completo VARCHAR2(120) NOT NULL,
  correo          VARCHAR2(120) NOT NULL,
  rol             VARCHAR2(10)  NOT NULL,
  id_alojamiento  NUMBER(6),
  activo          CHAR(1)       DEFAULT 'S' NOT NULL,
  fecha_creacion  DATE          DEFAULT SYSDATE NOT NULL,
  CONSTRAINT pk_usuario_sistema PRIMARY KEY (id_usuario),
  CONSTRAINT uq_usuario_username UNIQUE (username),
  CONSTRAINT uq_usuario_correo   UNIQUE (correo),
  CONSTRAINT fk_usr_alojamiento  FOREIGN KEY (id_alojamiento) REFERENCES alojamiento (id_alojamiento),
  CONSTRAINT ck_usr_rol    CHECK (rol IN ('ADMIN','GERENTE','AUDITOR','ENCARGADO','RECEPCION')),
  CONSTRAINT ck_usr_activo CHECK (activo IN ('S','N')),
  CONSTRAINT ck_usr_aloj_rol CHECK ((rol IN ('ENCARGADO','RECEPCION') AND id_alojamiento IS NOT NULL)
                                 OR (rol IN ('ADMIN','GERENTE','AUDITOR') AND id_alojamiento IS NULL))
);
COMMENT ON TABLE usuario_sistema IS 'Usuarios internos de la plataforma con su rol. ENCARGADO y RECEPCION están atados a un alojamiento. Base de la Entrega 3 (roles y privilegios).';

-- ---------------------------------------------------------------------------
-- VISTAS DE APOYO
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_noche_reserva AS
SELECT rh.id_reserva_hab,
       rh.id_reserva,
       rh.id_habitacion,
       rh.id_alojamiento,
       r.estado,
       rh.fecha_in + g.n AS noche,
       t.id_temporada,
       t.categoria,
       tf.precio_noche
  FROM reserva_habitacion rh
  JOIN reserva r  ON r.id_reserva = rh.id_reserva
  JOIN (SELECT LEVEL - 1 AS n FROM dual CONNECT BY LEVEL <= 30) g
         ON g.n < (rh.fecha_out - rh.fecha_in)
  JOIN temporada t
         ON (rh.fecha_in + g.n) BETWEEN t.fecha_inicio AND t.fecha_fin
  JOIN tarifa tf
         ON tf.id_habitacion = rh.id_habitacion
        AND tf.id_temporada  = t.id_temporada;
COMMENT ON TABLE v_noche_reserva IS 'Vista: una fila por noche reservada con su temporada y tarifa vigentes (valoración noche a noche).';

CREATE OR REPLACE VIEW v_reserva_total AS
SELECT r.id_reserva,
       r.id_cliente,
       r.id_alojamiento,
       r.estado,
       NVL((SELECT SUM(rh.valor_estadia) FROM reserva_habitacion rh WHERE rh.id_reserva = r.id_reserva), 0) AS valor_estadia,
       NVL((SELECT SUM(rs.cantidad * rs.precio_unitario) FROM reserva_servicio rs WHERE rs.id_reserva = r.id_reserva), 0) AS valor_servicios,
       NVL((SELECT SUM(p.monto) FROM pago p WHERE p.id_reserva = r.id_reserva AND p.estado = 'EXITOSO'), 0) AS total_pagado
  FROM reserva r;
COMMENT ON TABLE v_reserva_total IS 'Vista: valor total (estadía + servicios), pagado exitoso por reserva.';

PROMPT >> 01_ddl.sql terminado: 14 tablas, 14 secuencias, 2 vistas.
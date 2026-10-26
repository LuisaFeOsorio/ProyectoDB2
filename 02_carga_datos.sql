-- =============================================================================
-- 02_carga_datos.sql · VERSIÓN SENCILLA Y CORREGIDA PARA ESTUDIANTES
-- EJECUTAR COMO: TURISMO (XEPDB1), DESPUES DE 01_ddl.sql
-- =============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- -----------------------------------------------------------------------------
-- 2.1 MUNICIPIOS Y TIPOS DE ALOJAMIENTO
-- -----------------------------------------------------------------------------
DECLARE
  TYPE t_mun IS TABLE OF VARCHAR2(60);
  v_mun t_mun := t_mun('Armenia','Buenavista','Calarca','Circasia','Cordoba','Filandia','Genova','La Tebaida','Montenegro','Pijao','Quimbaya','Salento');
BEGIN
  FOR i IN 1 .. v_mun.COUNT LOOP
    INSERT INTO municipio (nombre) VALUES (v_mun(i));
  END LOOP;

  INSERT INTO tipo_alojamiento (nombre, descripcion) VALUES ('Finca cafetera','Finca con hospedaje y experiencias');
  INSERT INTO tipo_alojamiento (nombre, descripcion) VALUES ('Hotel','Hotel urbano o campestre');
  INSERT INTO tipo_alojamiento (nombre, descripcion) VALUES ('Glamping','Alojamiento en contacto con la naturaleza');
  INSERT INTO tipo_alojamiento (nombre, descripcion) VALUES ('Hostal','Alojamiento economico');
  INSERT INTO tipo_alojamiento (nombre, descripcion) VALUES ('Cabanas ecoturisticas','Cabanas independientes');

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Municipios y tipos de alojamiento cargados');
END;
/

-- -----------------------------------------------------------------------------
-- 2.2 TEMPORADAS 2024 - 2026
-- -----------------------------------------------------------------------------
DECLARE
BEGIN
  -- 2024
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Baja Ene-Mar 2024','BAJA',2024,DATE '2024-01-15',DATE '2024-03-22');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Semana Santa 2024','ALTA',2024,DATE '2024-03-23',DATE '2024-03-31');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Baja Abr-Jun 2024','BAJA',2024,DATE '2024-04-01',DATE '2024-06-14');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Mitad de Año 2024','ALTA',2024,DATE '2024-06-15',DATE '2024-07-14');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Media Jul-Oct 2024','MEDIA',2024,DATE '2024-07-15',DATE '2024-10-10');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Puente Octubre 2024','ALTA',2024,DATE '2024-10-11',DATE '2024-10-14');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Media Oct-Nov 2024','MEDIA',2024,DATE '2024-10-15',DATE '2024-10-31');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Puente Noviembre 2024','ALTA',2024,DATE '2024-11-01',DATE '2024-11-04');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Media Nov-Dic 2024','MEDIA',2024,DATE '2024-11-05',DATE '2024-12-13');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Diciembre 2024','ALTA',2024,DATE '2024-12-14',DATE '2024-12-31');

  -- 2025
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Baja Ene-Abr 2025','BAJA',2025,DATE '2025-01-01',DATE '2025-04-11');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Semana Santa 2025','ALTA',2025,DATE '2025-04-12',DATE '2025-04-20');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Baja Abr-Jun 2025','BAJA',2025,DATE '2025-04-21',DATE '2025-06-13');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Mitad de Año 2025','ALTA',2025,DATE '2025-06-14',DATE '2025-07-13');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Media Jul-Ago 2025','MEDIA',2025,DATE '2025-07-14',DATE '2025-08-14');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Puente Agosto 2025','ALTA',2025,DATE '2025-08-15',DATE '2025-08-18');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Media Ago-Oct 2025','MEDIA',2025,DATE '2025-08-19',DATE '2025-10-09');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Puente Octubre 2025','ALTA',2025,DATE '2025-10-10',DATE '2025-10-13');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Media Oct-Nov 2025','MEDIA',2025,DATE '2025-10-14',DATE '2025-10-31');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Puente Noviembre 2025','ALTA',2025,DATE '2025-11-01',DATE '2025-11-03');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Media Nov-Dic 2025','MEDIA',2025,DATE '2025-11-04',DATE '2025-12-12');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Diciembre 2025','ALTA',2025,DATE '2025-12-13',DATE '2025-12-31');

  -- 2026
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Baja Ene-Mar 2026','BAJA',2026,DATE '2026-01-01',DATE '2026-03-27');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Semana Santa 2026','ALTA',2026,DATE '2026-03-28',DATE '2026-04-05');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Baja Abr-Jun 2026','BAJA',2026,DATE '2026-04-06',DATE '2026-06-12');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Mitad de Año 2026','ALTA',2026,DATE '2026-06-13',DATE '2026-07-12');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Media Jul-Ago 2026','MEDIA',2026,DATE '2026-07-13',DATE '2026-08-13');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Puente Agosto 2026','ALTA',2026,DATE '2026-08-14',DATE '2026-08-17');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Media Ago-Oct 2026','MEDIA',2026,DATE '2026-08-18',DATE '2026-10-09');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Puente Octubre 2026','ALTA',2026,DATE '2026-10-10',DATE '2026-10-12');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Media Oct-Nov 2026','MEDIA',2026,DATE '2026-10-13',DATE '2026-10-30');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Puente Noviembre 2026','ALTA',2026,DATE '2026-10-31',DATE '2026-11-02');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Media Nov-Dic 2026','MEDIA',2026,DATE '2026-11-03',DATE '2026-12-11');
  INSERT INTO temporada (nombre,categoria,anio,fecha_inicio,fecha_fin) VALUES ('Alta Diciembre 2026','ALTA',2026,DATE '2026-12-12',DATE '2026-12-31');

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Temporadas cargadas correctamente');
END;
/

-- -----------------------------------------------------------------------------
-- 2.3 ALOJAMIENTOS Y HABITACIONES
-- -----------------------------------------------------------------------------
DECLARE
  v_id_aloj NUMBER;
  v_nh NUMBER;
BEGIN
  -- Armenia: predominan hoteles
  FOR i IN 1..11 LOOP
    INSERT INTO alojamiento (nombre,id_municipio,id_tipo,direccion,estrellas,telefono,correo)
    VALUES ('Hotel Armenia '||i,(SELECT id_municipio FROM municipio WHERE nombre='Armenia'),2,'Centro de Armenia',3,'310'||LPAD(i,7,'0'),'hotelarmenia'||i||'@turismouq.co')
    RETURNING id_alojamiento INTO v_id_aloj;
    v_nh := 16 + TRUNC(DBMS_RANDOM.VALUE(0,12));
    FOR h IN 1..v_nh LOOP
      INSERT INTO habitacion (id_alojamiento,numero,capacidad,tipo,descripcion)
      VALUES (v_id_aloj,'H'||LPAD(h,3,'0'),2 + TRUNC(DBMS_RANDOM.VALUE(0,3)), CASE WHEN MOD(h,4)=0 THEN 'SUITE' ELSE 'DOBLE' END,'Habitacion con baño privado');
    END LOOP;
  END LOOP;

  -- Salento: fincas cafetaleras
  FOR i IN 1..15 LOOP
    INSERT INTO alojamiento (nombre,id_municipio,id_tipo,direccion,estrellas,telefono,correo)
    VALUES ('Finca Cafetera Salento '||i,(SELECT id_municipio FROM municipio WHERE nombre='Salento'),1,'Vereda Cocora, Salento',4,'320'||LPAD(i,7,'0'),'fincasalento'||i||'@turismouq.co')
    RETURNING id_alojamiento INTO v_id_aloj;
    v_nh := 4 + TRUNC(DBMS_RANDOM.VALUE(0,4));
    FOR h IN 1..v_nh LOOP
      INSERT INTO habitacion (id_alojamiento,numero,capacidad,tipo,descripcion)
      VALUES (v_id_aloj,'C'||LPAD(h,2,'0'),4 + TRUNC(DBMS_RANDOM.VALUE(0,3)), 'CABANA','Cabaña familiar con terraza');
    END LOOP;
  END LOOP;

  -- Demás municipios
  FOR m IN (SELECT id_municipio,nombre FROM municipio WHERE nombre NOT IN ('Armenia','Salento')) LOOP
    FOR i IN 1..3 LOOP
      INSERT INTO alojamiento (nombre,id_municipio,id_tipo,direccion,estrellas,telefono,correo)
      VALUES ('Alojamiento '||m.nombre||' '||i,m.id_municipio,3,'Zona Turistica '||m.nombre,3,'311'||LPAD(m.id_municipio*10+i,7,'0'),'aloj'||m.id_municipio||i||'@turismouq.co')
      RETURNING id_alojamiento INTO v_id_aloj;
      v_nh := 5 + TRUNC(DBMS_RANDOM.VALUE(0,6));
      FOR h IN 1..v_nh LOOP
        INSERT INTO habitacion (id_alojamiento,numero,capacidad,tipo,descripcion)
        VALUES (v_id_aloj,'G'||LPAD(h,3,'0'),2 + TRUNC(DBMS_RANDOM.VALUE(0,3)), CASE WHEN MOD(h,5)=0 THEN 'SUITE' ELSE 'DOBLE' END,'Habitacion estandar');
      END LOOP;
    END LOOP;
  END LOOP;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Alojamientos y habitaciones cargados');
END;
/

-- -----------------------------------------------------------------------------
-- 2.4 TARIFAS POR HABITACION Y TEMPORADA
-- -----------------------------------------------------------------------------
BEGIN
  FOR h IN (SELECT id_habitacion FROM habitacion) LOOP
    FOR t IN (SELECT id_temporada,categoria FROM temporada) LOOP
      INSERT INTO tarifa (id_habitacion,id_temporada,precio_noche)
      VALUES (h.id_habitacion,t.id_temporada,
              CASE t.categoria
                WHEN 'ALTA'  THEN 190000 + TRUNC(DBMS_RANDOM.VALUE(0,70000))
                WHEN 'MEDIA' THEN 140000 + TRUNC(DBMS_RANDOM.VALUE(0,50000))
                ELSE             95000  + TRUNC(DBMS_RANDOM.VALUE(0,40000))
              END);
    END LOOP;
  END LOOP;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Tarifas cargadas');
END;
/

-- -----------------------------------------------------------------------------
-- 2.5 SERVICIOS POR ALOJAMIENTO
-- -----------------------------------------------------------------------------
BEGIN
  FOR a IN (SELECT id_alojamiento FROM alojamiento) LOOP
    INSERT INTO servicio (id_alojamiento,nombre,descripcion,precio,activo) VALUES (a.id_alojamiento,'Desayuno tipico','Desayuno campesino',25000,'S');
    INSERT INTO servicio (id_alojamiento,nombre,descripcion,precio,activo) VALUES (a.id_alojamiento,'Tour del cafe','Recorrido guiado por cafetal',45000,'S');
    INSERT INTO servicio (id_alojamiento,nombre,descripcion,precio,activo) VALUES (a.id_alojamiento,'Alquiler de bicicletas','Bicicletas para recorrer el Quindio',20000,'S');
    INSERT INTO servicio (id_alojamiento,nombre,descripcion,precio,activo) VALUES (a.id_alojamiento,'Cabalgata','Paseo a caballo',40000,'S');
    INSERT INTO servicio (id_alojamiento,nombre,descripcion,precio,activo) VALUES (a.id_alojamiento,'Spa y masajes','Sesión de relajación',65000,'S');
  END LOOP;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Servicios cargados');
END;
/

-- -----------------------------------------------------------------------------
-- 2.6 CLIENTES (3200)
-- -----------------------------------------------------------------------------
DECLARE
  TYPE t_nom IS TABLE OF VARCHAR2(40);
  TYPE t_ape IS TABLE OF VARCHAR2(40);
  TYPE t_ciu IS TABLE OF VARCHAR2(40);
  v_nom t_nom := t_nom('Juan','Maria','Carlos','Andres','Camila','Laura','Santiago','Valentina','Diego','Paula','Sebastian','Daniela');
  v_ape t_ape := t_ape('Gomez','Rodriguez','Martinez','Lopez','Garcia','Perez','Ramirez','Torres','Vargas','Ospina','Hernandez','Restrepo');
  v_ciu t_ciu := t_ciu('Bogota','Medellin','Cali','Pereira','Armenia','Manizales','Barranquilla','Bucaramanga','Ibague','Cartagena');
BEGIN
  FOR i IN 1..3200 LOOP
    INSERT INTO cliente (tipo_documento,documento,nombre,apellido,correo,telefono,ciudad_origen)
    VALUES (CASE WHEN MOD(i,12)=0 THEN 'CE' WHEN MOD(i,25)=0 THEN 'PASAPORTE' ELSE 'CC' END,
            TO_CHAR(90000000 + i),
            v_nom(TRUNC(DBMS_RANDOM.VALUE(1,13))),
            v_ape(TRUNC(DBMS_RANDOM.VALUE(1,13))),
            'cliente'||i||'@correo.com',
            '300'||LPAD(TRUNC(DBMS_RANDOM.VALUE(1000000,9999999)),7,'0'),
            v_ciu(TRUNC(DBMS_RANDOM.VALUE(1,11))));
  END LOOP;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Clientes cargados: 3200');
END;
/

-- -----------------------------------------------------------------------------
-- 2.7 USUARIOS DEL SISTEMA (11)
-- -----------------------------------------------------------------------------
BEGIN
  DELETE FROM usuario_sistema;
  COMMIT;

  -- Plataforma
  INSERT INTO usuario_sistema (username,nombre_completo,correo,rol,id_alojamiento) VALUES ('admin.turismo','Administrador de Plataforma','admin@turismouq.co','ADMIN',NULL);
  INSERT INTO usuario_sistema (username,nombre_completo,correo,rol,id_alojamiento) VALUES ('gerente.turismo','Gerencia General','gerente@turismouq.co','GERENTE',NULL);
  INSERT INTO usuario_sistema (username,nombre_completo,correo,rol,id_alojamiento) VALUES ('auditor.turismo','Auditoria Interna','auditor@turismouq.co','AUDITOR',NULL);

  -- Encargado por tipo de alojamiento
  FOR r IN (SELECT ta.id_tipo, MIN(a.id_alojamiento) AS id_aloj
              FROM tipo_alojamiento ta
              JOIN alojamiento a ON a.id_tipo = ta.id_tipo
             GROUP BY ta.id_tipo
             ORDER BY ta.id_tipo) LOOP
    INSERT INTO usuario_sistema (username,nombre_completo,correo,rol,id_alojamiento)
    VALUES ('encargado.tipo'||r.id_tipo,'Encargado Tipo '||r.id_tipo,'encargado'||r.id_tipo||'@turismouq.co','ENCARGADO',r.id_aloj);
  END LOOP;

  -- 3 recepcionistas de los 3 alojamientos con mas habitaciones
  FOR r IN (SELECT id_alojamiento
              FROM (SELECT id_alojamiento, COUNT(*) AS cant_hab
                      FROM habitacion
                     GROUP BY id_alojamiento
                     ORDER BY cant_hab DESC)
             WHERE ROWNUM <= 3) LOOP
    INSERT INTO usuario_sistema (username,nombre_completo,correo,rol,id_alojamiento)
    VALUES ('recepcion.aloj'||r.id_alojamiento,'Recepcion Alojamiento '||r.id_alojamiento,'recepcion'||r.id_alojamiento||'@turismouq.co','RECEPCION',r.id_alojamiento);
  END LOOP;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Usuarios del sistema cargados: 11');
END;
/

-- -----------------------------------------------------------------------------
-- 2.8 RESERVAS, RESERVA_HABITACION, SERVICIOS, PAGOS Y RESEÑAS
-- -----------------------------------------------------------------------------
DECLARE
  v_res        NUMBER;
  v_cli        NUMBER;
  v_aloj       NUMBER;
  v_hab        NUMBER;
  v_cap        NUMBER;
  v_in         DATE;
  v_out        DATE;
  v_crea       DATE;
  v_estado     VARCHAR2(12);
  v_noches     NUMBER;
  v_huesp      NUMBER;
  v_precio     NUMBER;
  v_val_est    NUMBER;
  v_srv_id     NUMBER;
  v_val_srv    NUMBER;
  v_total      NUMBER;
  v_cnt_res    NUMBER := 0;
BEGIN
  FOR h IN (SELECT id_habitacion, id_alojamiento, capacidad FROM habitacion ORDER BY id_habitacion) LOOP
    EXIT WHEN v_cnt_res >= 25500;
    FOR x IN 1..65 LOOP
      EXIT WHEN v_cnt_res >= 25500;

      -- Cliente aleatorio
      SELECT id_cliente INTO v_cli FROM (SELECT id_cliente FROM cliente ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1;

      v_aloj := h.id_alojamiento;
      v_hab  := h.id_habitacion;
      v_cap  := h.capacidad;

      -- Fechas
      v_in  := DATE '2024-01-01' + TRUNC(DBMS_RANDOM.VALUE(0, 980));
      v_noches := 1 + TRUNC(DBMS_RANDOM.VALUE(0, 5));
      v_out := v_in + v_noches;

      IF v_out > DATE '2026-10-22' THEN
        v_in  := DATE '2026-03-15' + TRUNC(DBMS_RANDOM.VALUE(0, 170));
        v_out := v_in + v_noches;
      END IF;

      -- Estado
      IF v_out < DATE '2026-10-01' THEN
        IF DBMS_RANDOM.VALUE(0,1) < 0.92 THEN
          v_estado := 'COMPLETADA';
        ELSE
          v_estado := 'CANCELADA';
        END IF;
      ELSIF v_in < DATE '2026-10-23' THEN
        v_estado := 'CONFIRMADA';
      ELSE
        IF DBMS_RANDOM.VALUE(0,1) < 0.70 THEN
          v_estado := 'CONFIRMADA';
        ELSIF DBMS_RANDOM.VALUE(0,1) < 0.92 THEN
          v_estado := 'PENDIENTE';
        ELSE
          v_estado := 'CANCELADA';
        END IF;
      END IF;

      v_crea := v_in - TRUNC(DBMS_RANDOM.VALUE(3, 45));
      IF v_crea < DATE '2023-12-01' THEN v_crea := DATE '2023-12-10'; END IF;

      v_huesp := 1 + TRUNC(DBMS_RANDOM.VALUE(0, v_cap));
      IF v_huesp < 1 THEN v_huesp := 1; END IF;
      IF v_huesp > v_cap THEN v_huesp := v_cap; END IF;

      -- Crear reserva
      v_res := seq_reserva.NEXTVAL;
      INSERT INTO reserva (id_reserva,id_cliente,id_alojamiento,fecha_creacion,fecha_checkin,fecha_checkout,estado,fecha_cancelacion)
      VALUES (v_res, v_cli, v_aloj, v_crea, v_in, v_out, v_estado,
              CASE WHEN v_estado = 'CANCELADA' THEN v_crea + TRUNC(DBMS_RANDOM.VALUE(1,6)) ELSE NULL END);

      -- Valor estadía
      v_precio := 115000 + TRUNC(DBMS_RANDOM.VALUE(0, 95000));
      v_val_est := v_precio * v_noches;

      INSERT INTO reserva_habitacion (id_reserva_hab,id_reserva,id_alojamiento,id_habitacion,fecha_in,fecha_out,num_huespedes,valor_estadia)
      VALUES (seq_reserva_habitacion.NEXTVAL, v_res, v_aloj, v_hab, v_in, v_out, v_huesp, v_val_est);

      -- Servicios
      v_val_srv := 0;
      IF DBMS_RANDOM.VALUE(0,1) < 0.95 THEN
        FOR s IN 1..(1 + TRUNC(DBMS_RANDOM.VALUE(0,3))) LOOP
          BEGIN
            SELECT id_servicio INTO v_srv_id
            FROM (SELECT id_servicio FROM servicio WHERE id_alojamiento = v_aloj AND activo = 'S' ORDER BY DBMS_RANDOM.VALUE)
            WHERE ROWNUM = 1;

            INSERT INTO reserva_servicio (id_reserva_servicio,id_reserva,id_alojamiento,id_servicio,cantidad,precio_unitario)
            SELECT seq_reserva_servicio.NEXTVAL, v_res, v_aloj, id_servicio, 1, precio
            FROM servicio
            WHERE id_servicio = v_srv_id;
          EXCEPTION
            WHEN OTHERS THEN NULL;
          END;
        END LOOP;
        SELECT NVL(SUM(cantidad * precio_unitario),0) INTO v_val_srv FROM reserva_servicio WHERE id_reserva = v_res;
      END IF;

      v_total := v_val_est + v_val_srv;

      -- Pagos
      IF v_estado = 'COMPLETADA' THEN
        INSERT INTO pago (id_pago,id_reserva,fecha_pago,monto,metodo,estado)
        VALUES (seq_pago.NEXTVAL, v_res, v_crea + 1, ROUND(v_total*0.4,-3), 'TARJETA_CREDITO', 'EXITOSO');
        INSERT INTO pago (id_pago,id_reserva,fecha_pago,monto,metodo,estado)
        VALUES (seq_pago.NEXTVAL, v_res, v_in, v_total - ROUND(v_total*0.4,-3), 'EFECTIVO', 'EXITOSO');

        IF DBMS_RANDOM.VALUE(0,1) < 0.58 THEN
          BEGIN
            INSERT INTO resena (id_resena,id_reserva,id_cliente,id_alojamiento,estado_reserva,calificacion,comentario,fecha_resena)
            VALUES (seq_resena.NEXTVAL, v_res, v_cli, v_aloj, 'COMPLETADA', 4+TRUNC(DBMS_RANDOM.VALUE(0,2)),'Excelente experiencia, muy recomendado', v_out + TRUNC(DBMS_RANDOM.VALUE(1,8)));
          EXCEPTION
            WHEN OTHERS THEN NULL;
          END;
        END IF;

      ELSIF v_estado = 'CONFIRMADA' THEN
        INSERT INTO pago (id_pago,id_reserva,fecha_pago,monto,metodo,estado)
        VALUES (seq_pago.NEXTVAL, v_res, v_crea, ROUND(v_total*0.5,-3), 'TARJETA_DEBITO', 'EXITOSO');

      ELSIF v_estado = 'PENDIENTE' THEN
        INSERT INTO pago (id_pago,id_reserva,fecha_pago,monto,metodo,estado)
        VALUES (seq_pago.NEXTVAL, v_res, v_crea, v_total, 'PSE', 'PENDIENTE');

      ELSIF v_estado = 'CANCELADA' THEN
        IF DBMS_RANDOM.VALUE(0,1) < 0.75 THEN
          INSERT INTO pago (id_pago,id_reserva,fecha_pago,monto,metodo,estado)
          VALUES (seq_pago.NEXTVAL, v_res, v_crea, ROUND(v_total*0.6,-3), 'TARJETA_CREDITO', 'REEMBOLSADO');
        ELSE
          INSERT INTO pago (id_pago,id_reserva,fecha_pago,monto,metodo,estado)
          VALUES (seq_pago.NEXTVAL, v_res, v_crea, ROUND(v_total*0.4,-3), 'TRANSFERENCIA', 'EXITOSO');
        END IF;
      END IF;

      v_cnt_res := v_cnt_res + 1;
      IF MOD(v_cnt_res,2000)=0 THEN
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('  ... '||v_cnt_res||' reservas generadas');
      END IF;
    END LOOP;
  END LOOP;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Reservas generadas: '||v_cnt_res);
END;
/

-- -----------------------------------------------------------------------------
-- 2.9 VERIFICACION
-- -----------------------------------------------------------------------------
PROMPT === VERIFICACION CARGA ===
SELECT 'RESERVA' TABLA, COUNT(*) FILAS FROM reserva
UNION ALL SELECT 'RESERVA_HABITACION', COUNT(*) FROM reserva_habitacion
UNION ALL SELECT 'PAGO', COUNT(*) FROM pago
UNION ALL SELECT 'RESERVA_SERVICIO', COUNT(*) FROM reserva_servicio
UNION ALL SELECT 'RESENA', COUNT(*) FROM resena
UNION ALL SELECT 'CLIENTE', COUNT(*) FROM cliente
UNION ALL SELECT 'USUARIO_SISTEMA', COUNT(*) FROM usuario_sistema;
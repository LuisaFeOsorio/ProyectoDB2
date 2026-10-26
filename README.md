# TurismoUQ · 

## Cómo ejecutar 



Usar SQL Developer (F5 "Ejecutar script")  . Contraseña del esquema: `Turismo2026#`.


Hacer, en orden

1. Tener Oracle XE instalado  
2. Abrir SQL Developer y conectarte como SYSTEM al servicio XEPDB1.  
3. Ejecutar 00\_admin\_crear\_usuario.sql.  
4. Conectarte como TURISMO (clave Turismo2026\#) y ejecutar 01, 02, 03, 04 y 05\.  
5. Conectarte otra vez como SYSTEM y ejecutar 06\.  
6. Conectarte como TURISMO y ejecutar 07 y 08\.

El script 02 tarda entre 1 y 3 minutos, porque está generando unas 25.500 reservas. Es normal que parezca que no pasa nada un rato.
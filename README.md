# Librería en Línea — DDL (MySQL 8.x)

Este script (`libreria_db.sql`) crea la base **libreria_db**, define tablas con **PK/FK** y **restricciones**, y aplica las **modificaciones** solicitadas; además **elimina** tablas y **trunca** `pedidos` .

## Contenido

1) Crear BD  
2) Tablas:
- `clientes` (PK auto, `correo_cliente` UNIQUE, `telefono_cliente` con CHECK inicial de 10 dígitos)
- `libros` (PK auto, `precio_libro` DEC(10,2), `cantidad_disponible` CHECK >= 0)
- `pedidos` (PK auto, FK `id_cliente` → `clientes`)
- `detalles_pedido` (PK auto, FK `id_pedido` → `pedidos` con CASCADE; FK `id_libro` → `libros`)
- `pagos` (PK auto, FK `id_pedido` → `pedidos`)

3) Modificaciones:
- `clientes.telefono_cliente` → `VARCHAR(20)` + nuevo CHECK internacional
- `libros.precio_libro` → `DECIMAL(10,3)`
- `pagos` + `fecha_confirmacion DATETIME`

4) Eliminar tablas:
- `DROP TABLE detalles_pedido`
- `DROP TABLE pagos`

5) Truncar:
- `TRUNCATE TABLE pedidos` (sin FKs hijas después de los DROP)

## Requisitos
- **MySQL 8.x** (InnoDB). Ejecutar completo en Workbench/phpMyAdmin/CLI:
```sql
SOURCE /ruta/a/libreria_db.sql;

-- =========================================================
-- Librería en Línea — DDL mínimo (MySQL 8.x, InnoDB)
-- Crea BD, tablas con PK/FK/Restricciones y realiza
-- las MODIFICACIONES, DROP y TRUNCATE solicitados.
-- =========================================================

/* 1) Crear la base de datos */
CREATE DATABASE IF NOT EXISTS libreria_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
USE libreria_db;

/* Limpieza segura por si existen restos previos */
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalles_pedido;
DROP TABLE IF EXISTS pagos;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS libros;
DROP TABLE IF EXISTS clientes;
SET FOREIGN_KEY_CHECKS = 1;

/* 2) Definir y crear tablas con restricciones */

/* 2.1) Clientes */
CREATE TABLE clientes (
  id_cliente        INT NOT NULL AUTO_INCREMENT,
  nombre_cliente    VARCHAR(100) NOT NULL,
  correo_cliente    VARCHAR(100) NOT NULL,
  telefono_cliente  VARCHAR(15)  NOT NULL,
  direccion_cliente VARCHAR(255) NOT NULL,
  CONSTRAINT pk_clientes PRIMARY KEY (id_cliente),
  CONSTRAINT uq_clientes_correo UNIQUE (correo_cliente),
  /* Solo 10 dígitos numéricos inicialmente */
  CONSTRAINT ck_clientes_tel_10d CHECK (telefono_cliente REGEXP '^[0-9]{10}$')
) ENGINE=InnoDB;

/* 2.2) Libros */
CREATE TABLE libros (
  id_libro            INT NOT NULL AUTO_INCREMENT,
  titulo_libro        VARCHAR(255) NOT NULL,
  autor_libro         VARCHAR(100) NOT NULL,
  precio_libro        DECIMAL(10,2) NOT NULL,
  cantidad_disponible INT NOT NULL,
  categoria_libro     VARCHAR(50)  NOT NULL,
  CONSTRAINT pk_libros PRIMARY KEY (id_libro),
  /* No permitir negativos */
  CONSTRAINT ck_libros_cantidad_nn CHECK (cantidad_disponible >= 0)
) ENGINE=InnoDB;

/* 2.3) Pedidos */
CREATE TABLE pedidos (
  id_pedido     INT NOT NULL AUTO_INCREMENT,
  id_cliente    INT NOT NULL,
  fecha_pedido  DATE NOT NULL,
  total_pedido  DECIMAL(10,2) NOT NULL,
  estado_pedido VARCHAR(50) NOT NULL,
  CONSTRAINT pk_pedidos PRIMARY KEY (id_pedido),
  CONSTRAINT fk_pedidos_clientes
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB;

/* 2.4) Detalles_Pedido */
CREATE TABLE detalles_pedido (
  id_detalle      INT NOT NULL AUTO_INCREMENT,
  id_pedido       INT NOT NULL,
  id_libro        INT NOT NULL,
  cantidad_libro  INT NOT NULL,
  precio_libro    DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_detalles PRIMARY KEY (id_detalle),
  CONSTRAINT fk_detalles_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_detalles_libros
    FOREIGN KEY (id_libro) REFERENCES libros(id_libro)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB;

/* 2.5) Pagos */
CREATE TABLE pagos (
  id_pago      INT NOT NULL AUTO_INCREMENT,
  id_pedido    INT NOT NULL,
  fecha_pago   DATE NOT NULL,
  monto_pago   DECIMAL(10,2) NOT NULL,
  metodo_pago  VARCHAR(50) NOT NULL,
  CONSTRAINT pk_pagos PRIMARY KEY (id_pago),
  CONSTRAINT fk_pagos_pedidos
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB;

/* 3) MODIFICACIONES a la estructura (según instrucciones) */

/* 3.1) Cambiar tipo de telefono_cliente a VARCHAR(20)
        y actualizar la restricción para mayor flexibilidad */
ALTER TABLE clientes
  MODIFY telefono_cliente VARCHAR(20) NOT NULL;

ALTER TABLE clientes
  DROP CHECK ck_clientes_tel_10d;

-- Permitir formatos internacionales simples (dígitos/+/-/espacio, 7–20 chars)
ALTER TABLE clientes
  ADD CONSTRAINT ck_clientes_tel_intl
  CHECK (telefono_cliente REGEXP '^[0-9+ -]{7,20}$');

/* 3.2) Modificar precio_libro a DECIMAL(10,3) */
ALTER TABLE libros
  MODIFY precio_libro DECIMAL(10,3) NOT NULL;

/* 3.3) Agregar campo fecha_confirmacion a Pagos */
ALTER TABLE pagos
  ADD COLUMN fecha_confirmacion DATETIME NULL AFTER fecha_pago;

/* 3.4) Eliminar la tabla Detalles_Pedido (cuando se haya confirmado la entrega) */
DROP TABLE detalles_pedido;

/* 4) Eliminar una tabla: Pagos (después de los cambios) */
DROP TABLE pagos;

/* 5) Truncar la tabla Pedidos (sin afectar integridad referencial) */
TRUNCATE TABLE pedidos;

/* Fin del script */

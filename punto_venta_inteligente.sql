-- Crear el schema para el sistema de punto de venta
CREATE SCHEMA IF NOT EXISTS pos;

-- Crear tipos enumerados
CREATE TYPE pos.estado_usuario AS ENUM ('activo', 'inactivo', 'suspendido');
CREATE TYPE pos.estado_producto AS ENUM ('activo', 'inactivo', 'descontinuado');
CREATE TYPE pos.metodo_pago AS ENUM ('efectivo', 'tarjeta_credito', 'tarjeta_debito', 'transferencia', 'qr');
CREATE TYPE pos.estado_venta AS ENUM ('pendiente', 'completada', 'cancelada', 'devuelta');
CREATE TYPE pos.tipo_descuento AS ENUM ('porcentaje', 'monto_fijo');
CREATE TYPE pos.formato_reporte AS ENUM ('pdf', 'excel', 'csv');

-- Tabla de Usuarios
CREATE TABLE pos.usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    estado pos.estado_usuario DEFAULT 'activo',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Roles
CREATE TABLE pos.roles (
    id_rol SERIAL PRIMARY KEY,
    nombre_rol VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    permisos JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de asignación de roles a usuarios
CREATE TABLE pos.usuarios_roles (
    id_usuario_rol SERIAL PRIMARY KEY,
    id_usuario INTEGER REFERENCES pos.usuarios(id_usuario) ON DELETE CASCADE,
    id_rol INTEGER REFERENCES pos.roles(id_rol) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(id_usuario, id_rol)
);

-- Tabla de Categorías
CREATE TABLE pos.categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    descripcion TEXT,
    imagen VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Productos
CREATE TABLE pos.productos (
    id_producto SERIAL PRIMARY KEY,
    codigo_barras VARCHAR(50) UNIQUE,
    nombre_producto VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio_compra DECIMAL(10, 2) NOT NULL,
    precio_venta DECIMAL(10, 2) NOT NULL,
    imagen VARCHAR(255),
    id_categoria INTEGER REFERENCES pos.categorias(id_categoria) ON DELETE SET NULL,
    estado pos.estado_producto DEFAULT 'activo',
    destacado BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Inventario
CREATE TABLE pos.inventario (
    id_inventario SERIAL PRIMARY KEY,
    id_producto INTEGER REFERENCES pos.productos(id_producto) ON DELETE CASCADE,
    stock_actual INTEGER NOT NULL DEFAULT 0,
    stock_minimo INTEGER NOT NULL DEFAULT 5,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(id_producto)
);

-- Tabla de Proveedores
CREATE TABLE pos.proveedores (
    id_proveedor SERIAL PRIMARY KEY,
    nombre_empresa VARCHAR(200) NOT NULL,
    contacto_nombre VARCHAR(100),
    email VARCHAR(255),
    telefono VARCHAR(20),
    direccion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de relación Productos-Proveedores
CREATE TABLE pos.productos_proveedores (
    id_producto_proveedor SERIAL PRIMARY KEY,
    id_producto INTEGER REFERENCES pos.productos(id_producto) ON DELETE CASCADE,
    id_proveedor INTEGER REFERENCES pos.proveedores(id_proveedor) ON DELETE CASCADE,
    precio_compra DECIMAL(10, 2),
    codigo_proveedor VARCHAR(50),
    es_proveedor_principal BOOLEAN DEFAULT FALSE,
    ultima_compra TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(id_producto, id_proveedor)
);

-- Tabla de Clientes
CREATE TABLE pos.clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    telefono VARCHAR(20),
    nit_ci VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Ventas
CREATE TABLE pos.ventas (
    id_venta SERIAL PRIMARY KEY,
    numero_factura VARCHAR(20) UNIQUE,
    id_cliente INTEGER REFERENCES pos.clientes(id_cliente) ON DELETE RESTRICT,
    id_usuario INTEGER REFERENCES pos.usuarios(id_usuario) ON DELETE RESTRICT,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10, 2) NOT NULL,
    descuento DECIMAL(10, 2) DEFAULT 0,
    impuestos DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    metodo_pago pos.metodo_pago DEFAULT 'efectivo',
    estado pos.estado_venta DEFAULT 'pendiente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Detalle de Ventas
CREATE TABLE pos.detalle_ventas (
    id_detalle_venta SERIAL PRIMARY KEY,
    id_venta INTEGER REFERENCES pos.ventas(id_venta) ON DELETE CASCADE,
    id_producto INTEGER REFERENCES pos.productos(id_producto) ON DELETE RESTRICT,
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    descuento DECIMAL(10, 2) DEFAULT 0,
    subtotal DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Descuentos
CREATE TABLE pos.descuentos (
    id_descuento SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo pos.tipo_descuento NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    id_producto INTEGER REFERENCES pos.productos(id_producto) ON DELETE CASCADE NULL,
    id_categoria INTEGER REFERENCES pos.categorias(id_categoria) ON DELETE CASCADE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (fecha_fin > fecha_inicio),
    CHECK (id_producto IS NOT NULL OR id_categoria IS NOT NULL)
);

-- Tabla de Pasarela de Pagos
CREATE TABLE pos.pasarela_pagos (
    id_pago SERIAL PRIMARY KEY,
    id_venta INTEGER REFERENCES pos.ventas(id_venta) ON DELETE CASCADE,
    proveedor VARCHAR(50) NOT NULL,
    referencia_externa VARCHAR(100),
    monto DECIMAL(10, 2) NOT NULL,
    estado VARCHAR(20) NOT NULL,
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    datos_adicionales JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Comandos de Voz
CREATE TABLE pos.comandos_voz (
    id_comando SERIAL PRIMARY KEY,
    frase_comando VARCHAR(100) NOT NULL,
    variaciones JSONB NOT NULL,
    id_accion INTEGER NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Acciones del Sistema
CREATE TABLE pos.acciones_sistema (
    id_accion SERIAL PRIMARY KEY,
    nombre_accion VARCHAR(100) NOT NULL,
    endpoint_api VARCHAR(255),
    parametros JSONB,
    tipo_accion VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Reportes
CREATE TABLE pos.reportes (
    id_reporte SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    formato pos.formato_reporte DEFAULT 'pdf',
    parametros JSONB,
    id_usuario INTEGER REFERENCES pos.usuarios(id_usuario) ON DELETE SET NULL,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Función para actualizar el timestamp de actualización
CREATE OR REPLACE FUNCTION pos.update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger de timestamp a todas las tablas con updated_at
DO $$
DECLARE
    t record;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at'
        AND table_schema = 'pos'
    LOOP
        EXECUTE format('CREATE TRIGGER trg_update_timestamp
                        BEFORE UPDATE ON pos.%I
                        FOR EACH ROW
                        EXECUTE FUNCTION pos.update_timestamp()',
                       t.table_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Función para generar número de factura automáticamente
CREATE OR REPLACE FUNCTION pos.generar_numero_factura()
RETURNS TRIGGER AS $$
DECLARE
    prefijo VARCHAR(8);
    ultimo_numero INTEGER;
    nuevo_numero VARCHAR(20);
BEGIN
    prefijo := TO_CHAR(CURRENT_DATE, 'YYYYMMDD');
    
    SELECT COALESCE(MAX(SUBSTRING(numero_factura FROM 10)::INTEGER), 0)
    INTO ultimo_numero
    FROM pos.ventas
    WHERE numero_factura LIKE prefijo || '%';
    
    nuevo_numero := prefijo || LPAD((ultimo_numero + 1)::TEXT, 5, '0');
    NEW.numero_factura := nuevo_numero;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para generar número de factura
CREATE TRIGGER trg_generar_numero_factura
BEFORE INSERT ON pos.ventas
FOR EACH ROW
WHEN (NEW.numero_factura IS NULL)
EXECUTE FUNCTION pos.generar_numero_factura();

-- Insertar datos iniciales
-- Roles básicos
INSERT INTO pos.roles (nombre_rol, descripcion, permisos) VALUES 
('administrador', 'Control total del sistema', '{"usuarios":["crear","editar","eliminar","ver"],"productos":["crear","editar","eliminar","ver"],"ventas":["crear","anular","ver"],"reportes":["generar"]}'),
('vendedor', 'Gestión de ventas y clientes', '{"productos":["ver"],"ventas":["crear","ver"],"clientes":["crear","editar","ver"]}'),
('inventario', 'Gestión de inventario', '{"productos":["crear","editar","ver"],"inventario":["actualizar","ver"]}');

-- Usuario administrador inicial
INSERT INTO pos.usuarios (nombre, apellido, email, password, estado)
VALUES ('Admin', 'Sistema', 'admin@sistema.com', '$2a$10$X7VYJfYRcK6.HEk/4xCV8.Ot1KJpDYYd.9/aUZE9M.QXaJY0F8jKa', 'activo');
-- La contraseña es 'admin123' hasheada con bcrypt

-- Asignar rol administrador
INSERT INTO pos.usuarios_roles (id_usuario, id_rol)
VALUES (1, 1);

-- Categorías iniciales
INSERT INTO pos.categorias (nombre_categoria, descripcion)
VALUES 
('Electrónicos', 'Productos electrónicos y gadgets'),
('Alimentos', 'Productos alimenticios'),
('Bebidas', 'Bebidas alcohólicas y no alcohólicas'),
('Limpieza', 'Productos de limpieza para el hogar');

-- Comandos de voz iniciales
INSERT INTO pos.acciones_sistema (nombre_accion, endpoint_api, tipo_accion) VALUES
('buscar_producto', '/api/productos/buscar', 'consulta'),
('agregar_al_carrito', '/api/carrito/agregar', 'transaccion'),
('procesar_venta', '/api/ventas/procesar', 'transaccion'),
('aplicar_descuento', '/api/ventas/descuento', 'transaccion');

INSERT INTO pos.comandos_voz (frase_comando, variaciones, id_accion) VALUES
('buscar producto', '["busca producto", "encuentra producto", "buscar artículo"]', 1),
('agregar al carrito', '["añadir al carrito", "poner en carrito", "agregar producto"]', 2),
('procesar venta', '["finalizar venta", "completar venta", "terminar compra"]', 3),
('aplicar descuento', '["poner descuento", "dar descuento", "aplicar promoción"]', 4);

-- Crear índices para optimizar consultas frecuentes
CREATE INDEX idx_productos_codigo_barras ON pos.productos(codigo_barras);
CREATE INDEX idx_productos_categoria ON pos.productos(id_categoria);
CREATE INDEX idx_inventario_stock ON pos.inventario(stock_actual);
CREATE INDEX idx_ventas_fecha ON pos.ventas(fecha_venta);
CREATE INDEX idx_ventas_cliente ON pos.ventas(id_cliente);
CREATE INDEX idx_detalle_ventas_producto ON pos.detalle_ventas(id_producto);
-- Crear la base de datos
CREATE DATABASE punto_venta_inteligente;

-- Conectar a la base de datos
\c punto_venta_inteligente

-- Crear extensiones útiles
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Crear esquemas para organizar las tablas
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS ai;
CREATE SCHEMA IF NOT EXISTS reports;

-- Crear tipos enumerados
CREATE TYPE core.estado_usuario AS ENUM ('activo', 'inactivo', 'suspendido');
CREATE TYPE core.estado_producto AS ENUM ('activo', 'inactivo', 'descontinuado');
CREATE TYPE core.metodo_pago AS ENUM ('efectivo', 'tarjeta_credito', 'tarjeta_debito', 'transferencia', 'qr');
CREATE TYPE core.estado_venta AS ENUM ('pendiente', 'completada', 'cancelada', 'devuelta');
CREATE TYPE core.tipo_descuento AS ENUM ('porcentaje', 'monto_fijo');
CREATE TYPE ai.tipo_recomendacion AS ENUM ('apriori', 'frecuencia', 'colaborativo', 'personalizado');

-- Tablas de usuarios y roles
CREATE TABLE core.usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP,
    estado core.estado_usuario DEFAULT 'activo',
    foto_perfil VARCHAR(255),
    token_recuperacion VARCHAR(255),
    fecha_token TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.roles (
    id_rol SERIAL PRIMARY KEY,
    nombre_rol VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.permisos (
    id_permiso SERIAL PRIMARY KEY,
    nombre_permiso VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT,
    modulo VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.roles_permisos (
    id_rol_permiso SERIAL PRIMARY KEY,
    id_rol INTEGER REFERENCES core.roles(id_rol) ON DELETE CASCADE,
    id_permiso INTEGER REFERENCES core.permisos(id_permiso) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(id_rol, id_permiso)
);

CREATE TABLE core.roles_usuarios (
    id_rol_usuario SERIAL PRIMARY KEY,
    id_usuario INTEGER REFERENCES core.usuarios(id_usuario) ON DELETE CASCADE,
    id_rol INTEGER REFERENCES core.roles(id_rol) ON DELETE CASCADE,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(id_usuario, id_rol)
);

-- Tablas de productos e inventario
CREATE TABLE core.categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    descripcion TEXT,
    imagen VARCHAR(255),
    estado BOOLEAN DEFAULT TRUE,
    categoria_padre_id INTEGER REFERENCES core.categorias(id_categoria) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.productos (
    id_producto SERIAL PRIMARY KEY,
    codigo_barras VARCHAR(50) UNIQUE,
    nombre_producto VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio_compra DECIMAL(10, 2) NOT NULL,
    precio_venta DECIMAL(10, 2) NOT NULL,
    imagen VARCHAR(255),
    id_categoria INTEGER REFERENCES core.categorias(id_categoria) ON DELETE SET NULL,
    estado core.estado_producto DEFAULT 'activo',
    destacado BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.inventario (
    id_inventario SERIAL PRIMARY KEY,
    id_producto INTEGER REFERENCES core.productos(id_producto) ON DELETE CASCADE,
    stock_actual INTEGER NOT NULL DEFAULT 0,
    stock_minimo INTEGER NOT NULL DEFAULT 5,
    ubicacion_almacen VARCHAR(100),
    fecha_ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(id_producto)
);

CREATE TABLE core.notificaciones_inventario (
    id_notificacion SERIAL PRIMARY KEY,
    id_producto INTEGER REFERENCES core.productos(id_producto) ON DELETE CASCADE,
    tipo_notificacion VARCHAR(20) NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    leido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.proveedores (
    id_proveedor SERIAL PRIMARY KEY,
    nombre_empresa VARCHAR(200) NOT NULL,
    contacto_nombre VARCHAR(100),
    email VARCHAR(255),
    telefono VARCHAR(20),
    direccion TEXT,
    notas TEXT,
    estado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.compras_proveedor (
    id_compra SERIAL PRIMARY KEY,
    id_proveedor INTEGER REFERENCES core.proveedores(id_proveedor) ON DELETE RESTRICT,
    id_usuario INTEGER REFERENCES core.usuarios(id_usuario) ON DELETE RESTRICT,
    fecha_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12, 2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'completada',
    notas TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.detalle_compra (
    id_detalle_compra SERIAL PRIMARY KEY,
    id_compra INTEGER REFERENCES core.compras_proveedor(id_compra) ON DELETE CASCADE,
    id_producto INTEGER REFERENCES core.productos(id_producto) ON DELETE RESTRICT,
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablas de ventas y clientes
CREATE TABLE core.clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    telefono VARCHAR(20),
    direccion TEXT,
    nit_ci VARCHAR(20),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultima_compra TIMESTAMP,
    notas TEXT,
    estado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.ventas (
    id_venta SERIAL PRIMARY KEY,
    numero_factura VARCHAR(20) UNIQUE,
    id_cliente INTEGER REFERENCES core.clientes(id_cliente) ON DELETE RESTRICT,
    id_usuario INTEGER REFERENCES core.usuarios(id_usuario) ON DELETE RESTRICT,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(12, 2) NOT NULL,
    descuento_total DECIMAL(12, 2) DEFAULT 0,
    impuestos DECIMAL(12, 2) DEFAULT 0,
    total DECIMAL(12, 2) NOT NULL,
    metodo_pago core.metodo_pago DEFAULT 'efectivo',
    estado_pago VARCHAR(20) DEFAULT 'completado',
    estado_venta core.estado_venta DEFAULT 'completada',
    notas TEXT,
    dispositivo VARCHAR(20) DEFAULT 'web',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.detalle_venta (
    id_detalle_venta SERIAL PRIMARY KEY,
    id_venta INTEGER REFERENCES core.ventas(id_venta) ON DELETE CASCADE,
    id_producto INTEGER REFERENCES core.productos(id_producto) ON DELETE RESTRICT,
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    descuento_unitario DECIMAL(10, 2) DEFAULT 0,
    subtotal DECIMAL(12, 2) NOT NULL,
    notas TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.descuentos (
    id_descuento SERIAL PRIMARY KEY,
    nombre_descuento VARCHAR(100) NOT NULL,
    tipo core.tipo_descuento NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    id_producto INTEGER REFERENCES core.productos(id_producto) ON DELETE CASCADE,
    id_categoria INTEGER REFERENCES core.categorias(id_categoria) ON DELETE CASCADE,
    codigo_promocion VARCHAR(50) UNIQUE,
    min_cantidad INTEGER DEFAULT 1,
    max_usos INTEGER,
    usos_actuales INTEGER DEFAULT 0,
    estado BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (id_producto IS NOT NULL OR id_categoria IS NOT NULL)
);

CREATE TABLE core.carritos (
    id_carrito SERIAL PRIMARY KEY,
    id_usuario INTEGER REFERENCES core.usuarios(id_usuario) ON DELETE CASCADE,
    id_cliente INTEGER REFERENCES core.clientes(id_cliente) ON DELETE SET NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'activo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.detalle_carrito (
    id_detalle_carrito SERIAL PRIMARY KEY,
    id_carrito INTEGER REFERENCES core.carritos(id_carrito) ON DELETE CASCADE,
    id_producto INTEGER REFERENCES core.productos(id_producto) ON DELETE CASCADE,
    cantidad INTEGER NOT NULL DEFAULT 1,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablas para reconocimiento de voz
CREATE TABLE ai.comandos_voz (
    id_comando SERIAL PRIMARY KEY,
    frase_comando VARCHAR(200) NOT NULL,
    variaciones_comando JSONB,
    id_accion INTEGER,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ai.acciones_sistema (
    id_accion SERIAL PRIMARY KEY,
    nombre_accion VARCHAR(100) NOT NULL,
    descripcion TEXT,
    endpoint_api VARCHAR(255),
    parametros_requeridos JSONB,
    tipo_accion VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE ai.comandos_voz 
ADD CONSTRAINT fk_comandos_accion 
FOREIGN KEY (id_accion) REFERENCES ai.acciones_sistema(id_accion) ON DELETE SET NULL;

CREATE TABLE ai.historial_comandos_voz (
    id_historial SERIAL PRIMARY KEY,
    id_usuario INTEGER REFERENCES core.usuarios(id_usuario) ON DELETE SET NULL,
    id_comando INTEGER REFERENCES ai.comandos_voz(id_comando) ON DELETE SET NULL,
    comando_detectado TEXT NOT NULL,
    precision_deteccion FLOAT,
    accion_ejecutada VARCHAR(255),
    resultado TEXT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dispositivo VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablas para recomendaciones inteligentes
CREATE TABLE ai.historial_recomendaciones (
    id_recomendacion SERIAL PRIMARY KEY,
    id_cliente INTEGER REFERENCES core.clientes(id_cliente) ON DELETE CASCADE,
    id_producto_recomendado INTEGER REFERENCES core.productos(id_producto) ON DELETE CASCADE,
    id_producto_origen INTEGER REFERENCES core.productos(id_producto) ON DELETE SET NULL,
    tipo_recomendacion ai.tipo_recomendacion NOT NULL,
    score_confianza FLOAT,
    mostrado BOOLEAN DEFAULT FALSE,
    aceptado BOOLEAN DEFAULT FALSE,
    fecha_recomendacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ai.reglas_asociacion (
    id_regla SERIAL PRIMARY KEY,
    productos_antecedente JSONB NOT NULL,
    productos_consecuente JSONB NOT NULL,
    soporte FLOAT NOT NULL,
    confianza FLOAT NOT NULL,
    lift FLOAT NOT NULL,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tablas para reportes y configuración
CREATE TABLE reports.reportes (
    id_reporte SERIAL PRIMARY KEY,
    nombre_reporte VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo_reporte VARCHAR(50) NOT NULL,
    parametros JSONB,
    formato VARCHAR(10) DEFAULT 'PDF',
    programado BOOLEAN DEFAULT FALSE,
    frecuencia VARCHAR(50),
    ultimo_generado TIMESTAMP,
    proximo_generado TIMESTAMP,
    id_usuario INTEGER REFERENCES core.usuarios(id_usuario) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.configuracion_sistema (
    id_configuracion SERIAL PRIMARY KEY,
    nombre_empresa VARCHAR(200) NOT NULL,
    logo VARCHAR(255),
    direccion TEXT,
    telefono VARCHAR(20),
    email VARCHAR(255),
    moneda VARCHAR(10) DEFAULT 'BOB',
    formato_fecha VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    zona_horaria VARCHAR(50) DEFAULT 'America/La_Paz',
    impuesto_porcentaje FLOAT DEFAULT 13.0,
    habilitar_voz BOOLEAN DEFAULT TRUE,
    umbral_precision_voz FLOAT DEFAULT 0.7,
    habilitar_recomendaciones BOOLEAN DEFAULT TRUE,
    umbral_recomendaciones FLOAT DEFAULT 0.5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE core.historial_configuracion (
    id_historial SERIAL PRIMARY KEY,
    id_configuracion INTEGER REFERENCES core.configuracion_sistema(id_configuracion) ON DELETE CASCADE,
    id_usuario INTEGER REFERENCES core.usuarios(id_usuario) ON DELETE SET NULL,
    cambios_realizados JSONB NOT NULL,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índices para optimizar consultas
CREATE INDEX idx_productos_codigo_barras ON core.productos(codigo_barras);
CREATE INDEX idx_productos_categoria ON core.productos(id_categoria);
CREATE INDEX idx_inventario_producto ON core.inventario(id_producto);
CREATE INDEX idx_inventario_stock ON core.inventario(stock_actual);
CREATE INDEX idx_ventas_fecha ON core.ventas(fecha_venta);
CREATE INDEX idx_ventas_cliente ON core.ventas(id_cliente);
CREATE INDEX idx_detalle_venta_producto ON core.detalle_venta(id_producto);
CREATE INDEX idx_comandos_voz_frase ON ai.comandos_voz(frase_comando);
CREATE INDEX idx_usuarios_email ON core.usuarios(email);

-- Crear funciones y triggers para automatización
-- Trigger para actualizar stock después de una venta
CREATE OR REPLACE FUNCTION core.actualizar_stock_venta()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE core.inventario
    SET stock_actual = stock_actual - NEW.cantidad,
        fecha_ultima_actualizacion = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE id_producto = NEW.id_producto;
    
    -- Verificar si se alcanzó el stock mínimo
    INSERT INTO core.notificaciones_inventario (id_producto, tipo_notificacion, mensaje)
    SELECT 
        i.id_producto,
        CASE 
            WHEN i.stock_actual <= 0 THEN 'sin_stock'
            WHEN i.stock_actual <= i.stock_minimo THEN 'bajo_stock'
        END,
        CASE 
            WHEN i.stock_actual <= 0 THEN 'El producto ha quedado sin stock'
            WHEN i.stock_actual <= i.stock_minimo THEN 'El producto ha alcanzado el stock mínimo'
        END
    FROM core.inventario i
    WHERE i.id_producto = NEW.id_producto
    AND (i.stock_actual <= i.stock_minimo OR i.stock_actual <= 0);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_stock_venta
AFTER INSERT ON core.detalle_venta
FOR EACH ROW
EXECUTE FUNCTION core.actualizar_stock_venta();

-- Trigger para actualizar stock después de una compra a proveedor
CREATE OR REPLACE FUNCTION core.actualizar_stock_compra()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE core.inventario
    SET stock_actual = stock_actual + NEW.cantidad,
        fecha_ultima_actualizacion = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE id_producto = NEW.id_producto;
    
    -- Si no existe el producto en inventario, crearlo
    IF NOT FOUND THEN
        INSERT INTO core.inventario (id_producto, stock_actual, stock_minimo, fecha_ultima_actualizacion)
        VALUES (NEW.id_producto, NEW.cantidad, 5, CURRENT_TIMESTAMP);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_stock_compra
AFTER INSERT ON core.detalle_compra
FOR EACH ROW
EXECUTE FUNCTION core.actualizar_stock_compra();

-- Función para generar número de factura automáticamente
CREATE OR REPLACE FUNCTION core.generar_numero_factura()
RETURNS TRIGGER AS $$
DECLARE
    prefijo VARCHAR(8);
    ultimo_numero INTEGER;
    nuevo_numero VARCHAR(20);
BEGIN
    prefijo := TO_CHAR(CURRENT_DATE, 'YYYYMMDD');
    
    SELECT COALESCE(MAX(SUBSTRING(numero_factura FROM 10)::INTEGER), 0)
    INTO ultimo_numero
    FROM core.ventas
    WHERE numero_factura LIKE prefijo || '%';
    
    nuevo_numero := prefijo || LPAD((ultimo_numero + 1)::TEXT, 5, '0');
    NEW.numero_factura := nuevo_numero;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_generar_numero_factura
BEFORE INSERT ON core.ventas
FOR EACH ROW
WHEN (NEW.numero_factura IS NULL)
EXECUTE FUNCTION core.generar_numero_factura();

-- Función para actualizar timestamps
CREATE OR REPLACE FUNCTION update_timestamp()
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
        SELECT table_schema, table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at'
        AND table_schema IN ('core', 'ai', 'reports')
    LOOP
        EXECUTE format('CREATE TRIGGER trg_update_timestamp
                        BEFORE UPDATE ON %I.%I
                        FOR EACH ROW
                        EXECUTE FUNCTION update_timestamp()',
                       t.table_schema, t.table_name);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Insertar datos iniciales
-- Roles básicos
INSERT INTO core.roles (nombre_rol, descripcion) VALUES 
('administrador', 'Control total del sistema'),
('vendedor', 'Gestión de ventas y clientes'),
('supervisor_inventario', 'Gestión y supervisión de inventario'),
('cliente', 'Usuario cliente del sistema');

-- Permisos básicos
INSERT INTO core.permisos (nombre_permiso, descripcion, modulo) VALUES
('crear_usuario', 'Crear nuevos usuarios', 'usuarios'),
('editar_usuario', 'Editar usuarios existentes', 'usuarios'),
('eliminar_usuario', 'Eliminar usuarios', 'usuarios'),
('ver_usuarios', 'Ver listado de usuarios', 'usuarios'),
('crear_producto', 'Crear nuevos productos', 'productos'),
('editar_producto', 'Editar productos existentes', 'productos'),
('eliminar_producto', 'Eliminar productos', 'productos'),
('ver_productos', 'Ver listado de productos', 'productos'),
('crear_venta', 'Crear nuevas ventas', 'ventas'),
('anular_venta', 'Anular ventas existentes', 'ventas'),
('ver_ventas', 'Ver listado de ventas', 'ventas'),
('generar_reporte', 'Generar reportes del sistema', 'reportes'),
('configurar_sistema', 'Modificar configuración del sistema', 'configuracion');

-- Asignar permisos a roles
-- Administrador
INSERT INTO core.roles_permisos (id_rol, id_permiso)
SELECT 1, id_permiso FROM core.permisos;

-- Vendedor
INSERT INTO core.roles_permisos (id_rol, id_permiso)
SELECT 2, id_permiso FROM core.permisos 
WHERE nombre_permiso IN ('ver_productos', 'crear_venta', 'ver_ventas');

-- Supervisor de inventario
INSERT INTO core.roles_permisos (id_rol, id_permiso)
SELECT 3, id_permiso FROM core.permisos 
WHERE nombre_permiso IN ('crear_producto', 'editar_producto', 'ver_productos', 'ver_ventas');

-- Usuario administrador inicial
INSERT INTO core.usuarios (nombre, apellido, email, password, estado)
VALUES ('Admin', 'Sistema', 'admin@sistema.com', crypt('admin123', gen_salt('bf')), 'activo');

-- Asignar rol administrador
INSERT INTO core.roles_usuarios (id_usuario, id_rol)
VALUES (1, 1);

-- Configuración inicial del sistema
INSERT INTO core.configuracion_sistema (
    nombre_empresa, 
    moneda, 
    impuesto_porcentaje, 
    habilitar_voz, 
    habilitar_recomendaciones
) VALUES (
    'Mi Tienda Inteligente', 
    'BOB', 
    13.0, 
    TRUE, 
    TRUE
);

-- Comandos de voz iniciales
INSERT INTO ai.acciones_sistema (nombre_accion, descripcion, endpoint_api, tipo_accion) VALUES
('buscar_producto', 'Busca un producto por nombre', '/api/productos/buscar', 'consulta'),
('agregar_al_carrito', 'Agrega un producto al carrito', '/api/carrito/agregar', 'transaccion'),
('procesar_venta', 'Procesa la venta actual', '/api/ventas/procesar', 'transaccion'),
('aplicar_descuento', 'Aplica un descuento a la venta', '/api/ventas/descuento', 'transaccion');

INSERT INTO ai.comandos_voz (frase_comando, variaciones_comando, id_accion, activo) VALUES
('buscar producto', '["busca producto", "encuentra producto", "buscar artículo"]', 1, TRUE),
('agregar al carrito', '["añadir al carrito", "poner en carrito", "agregar producto"]', 2, TRUE),
('procesar venta', '["finalizar venta", "completar venta", "terminar compra"]', 3, TRUE),
('aplicar descuento', '["poner descuento", "dar descuento", "aplicar promoción"]', 4, TRUE);
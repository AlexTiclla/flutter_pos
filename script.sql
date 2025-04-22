-- Script para agregar más detalles de venta para mejorar las recomendaciones con Apriori

-- Primero, creamos nuevas ventas (25 ventas adicionales)
INSERT INTO venta (id_venta, numero_factura, id_usuario, fecha_venta, subtotal, descuento, total, metodo_pago, estado)
SELECT 
    35 + row_number() OVER (ORDER BY (SELECT NULL)), -- id_venta comenzando en 36
    CONCAT('FAC-', LPAD((35 + row_number() OVER (ORDER BY (SELECT NULL)))::text, 3, '0')), -- numero_factura (FAC-036, FAC-037, etc.)
    1, -- id_usuario fijo en 1 para todas las ventas
    CURRENT_DATE - (RANDOM() * 30)::int, -- fecha_venta (últimos 30 días)
    0, -- subtotal (se actualizará después)
    0, -- descuento
    0, -- total (se actualizará después)
    CASE 
        WHEN RANDOM() < 0.7 THEN 'efectivo'
        WHEN RANDOM() < 0.9 THEN 'tarjeta'
        ELSE 'transferencia'
    END, -- metodo_pago
    'completada' -- estado
FROM generate_series(1, 25);

-- Ahora agregaremos detalles de venta con patrones lógicos para el algoritmo Apriori

-- Patrón 1: iPhone (ID 7) + Funda para iPhone (ID 17)
INSERT INTO detalleventa (id_venta, id_producto, cantidad, precio_unitario, descuento, subtotal)
VALUES
    (36, 7, 1, 5100, 0, 5100),
    (36, 17, 1, 120, 0, 120),
    (37, 7, 1, 5100, 0, 5100),
    (37, 17, 2, 120, 0, 240),
    (38, 7, 1, 5100, 0, 5100),
    (38, 17, 1, 120, 0, 120),
    (38, 49, 1, 120, 0, 120); -- Tarjeta SD para el iPhone

-- Patrón 2: MacBook (ID 33) + Cargador USB-C (ID 27)
INSERT INTO detalleventa (id_venta, id_producto, cantidad, precio_unitario, descuento, subtotal)
VALUES
    (39, 33, 1, 4500, 0, 4500),
    (39, 27, 1, 100, 0, 100),
    (40, 33, 1, 4500, 0, 4500),
    (40, 27, 2, 100, 0, 200);

-- Patrón 3: Smart TV (IDs 1, 28, 29) + Barra de Sonido (IDs 12, 43)
INSERT INTO detalleventa (id_venta, id_producto, cantidad, precio_unitario, descuento, subtotal)
VALUES
    (41, 1, 1, 3400, 0, 3400),
    (41, 12, 1, 1200, 0, 1200),
    (42, 28, 1, 4200, 0, 4200),
    (42, 43, 1, 2300, 0, 2300),
    (43, 29, 1, 2600, 0, 2600),
    (43, 12, 1, 1200, 0, 1200);

-- Patrón 4: Laptops (IDs 5, 6, 34, 35) + Mouse (ID 16)
INSERT INTO detalleventa (id_venta, id_producto, cantidad, precio_unitario, descuento, subtotal)
VALUES
    (44, 5, 1, 3600, 0, 3600),
    (44, 16, 1, 140, 0, 140),
    (45, 6, 1, 3700, 0, 3700),
    (45, 16, 1, 140, 0, 140),
    (46, 34, 1, 4000, 0, 4000),
    (46, 16, 1, 140, 0, 140),
    (47, 35, 1, 6300, 0, 6300),
    (47, 16, 1, 140, 0, 140);

-- Patrón 5: Smartphones (IDs 8, 36, 37, 38) + Cargador rápido (ID 47) + Funda (ID 48)
INSERT INTO detalleventa (id_venta, id_producto, cantidad, precio_unitario, descuento, subtotal)
VALUES
    (48, 8, 1, 5800, 0, 5800),
    (48, 47, 1, 180, 0, 180),
    (49, 36, 1, 3400, 0, 3400),
    (49, 47, 1, 180, 0, 180),
    (49, 48, 1, 220, 0, 220),
    (50, 37, 1, 1100, 0, 1100),
    (50, 47, 1, 180, 0, 180),
    (50, 48, 1, 220, 0, 220),
    (51, 38, 1, 1800, 0, 1800),
    (51, 47, 1, 180, 0, 180);

-- Patrón 6: Cámaras (IDs 13, 45, 46) + Tarjeta SD (ID 49)
INSERT INTO detalleventa (id_venta, id_producto, cantidad, precio_unitario, descuento, subtotal)
VALUES
    (52, 13, 1, 4200, 0, 4200),
    (52, 49, 1, 120, 0, 120),
    (53, 45, 1, 2200, 0, 2200),
    (53, 49, 1, 120, 0, 120),
    (54, 46, 1, 3000, 0, 3000),
    (54, 49, 2, 120, 0, 240);

-- Patrón 7: Refrigeradores (IDs 3, 4, 31, 32) + Licuadora (IDs 21, 39)
INSERT INTO detalleventa (id_venta, id_producto, cantidad, precio_unitario, descuento, subtotal)
VALUES
    (55, 3, 1, 2800, 0, 2800),
    (55, 21, 1, 300, 0, 300),
    (56, 4, 1, 4000, 0, 4000),
    (56, 39, 1, 480, 0, 480),
    (57, 31, 1, 5200, 0, 5200),
    (57, 21, 1, 300, 0, 300),
    (58, 32, 1, 950, 0, 950),
    (58, 39, 1, 480, 0, 480);

-- Patrón 8: Productos de audio (IDs 11, 44, 51) a menudo se compran juntos
INSERT INTO detalleventa (id_venta, id_producto, cantidad, precio_unitario, descuento, subtotal)
VALUES
    (59, 11, 1, 250, 0, 250),
    (59, 44, 1, 550, 0, 550),
    (60, 44, 1, 550, 0, 550),
    (60, 51, 1, 450, 0, 450);

-- Actualizar los totales de las ventas
UPDATE venta v
SET 
    subtotal = (SELECT SUM(subtotal) FROM detalleventa WHERE id_venta = v.id_venta),
    total = (SELECT SUM(subtotal) FROM detalleventa WHERE id_venta = v.id_venta)
WHERE id_venta BETWEEN 36 AND 60;
# Rutas de API para Carrito de Compras

## Modelo de datos

Las tablas ya están creadas en la base de datos:

```sql
CREATE TABLE CarritoCompra (
    id_carrito SERIAL PRIMARY KEY,
    id_usuario INTEGER REFERENCES users(id) ON DELETE SET NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado estado_carrito DEFAULT 'activo',
    subtotal DECIMAL(10, 2) DEFAULT 0
);

CREATE TABLE DetalleCarrito (
    id_detalle_carrito SERIAL PRIMARY KEY,
    id_carrito INTEGER REFERENCES CarritoCompra(id_carrito) ON DELETE CASCADE,
    id_producto INTEGER REFERENCES products(id) ON DELETE RESTRICT,
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    descuento DECIMAL(10, 2) DEFAULT 0,
    subtotal DECIMAL(10, 2) NOT NULL
);
```

## Rutas de API necesarias

### 1. Obtener el carrito activo de un usuario

```
GET /api/v1/carts/user/:userId/active
```

- Descripción: Devuelve el carrito activo del usuario o crea uno si no existe.
- Respuesta: Objeto con los datos del carrito

### 2. Obtener los items de un carrito

```
GET /api/v1/carts/:cartId/items
```

- Descripción: Devuelve todos los items de un carrito específico.
- Respuesta: Array de objetos con los detalles de los items incluyendo información del producto

### 3. Actualizar la cantidad de un item en el carrito

```
PATCH /api/v1/cart-items/:itemId
```

- Descripción: Actualiza la cantidad de un item y recalcula su subtotal.
- Body: `{ "cantidad": 5 }`
- Respuesta: Objeto con los datos del item actualizado

### 4. Eliminar un item del carrito

```
DELETE /api/v1/cart-items/:itemId
```

- Descripción: Elimina un item del carrito.
- Respuesta: Estado 200 o 204

### 5. Procesar el carrito (checkout)

```
POST /api/v1/carts/:cartId/checkout
```

- Descripción: Procesa el carrito para convertirlo en una venta.
- Body: `{ "metodo_pago": "efectivo" }`
- Respuesta: Mensaje de confirmación o ID de la venta creada

## Implementación Backend

Para implementar estas rutas en el backend, es necesario:

1. Crear los controladores para manejar las operaciones CRUD en los modelos de CarritoCompra y DetalleCarrito.
2. Implementar la lógica de negocio para:
   - Creación automática de carritos para usuarios nuevos
   - Cálculo de subtotales al añadir/modificar/eliminar items
   - Conversión de un carrito a una venta durante el checkout
3. Validación de datos entrantes y manejo de errores
4. Documentación de API

## Consideraciones

- Los precios se deben guardar en el momento de añadir al carrito para mantener historial.
- Al obtener los items del carrito, se debe enriquecer la información con datos del producto como nombre e imagen.
- En el checkout, se debe validar stock disponible antes de procesar la venta.
- Se debe manejar transacciones para operaciones críticas como el checkout. 
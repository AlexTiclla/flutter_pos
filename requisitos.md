# PARTE II - PROCESO UNIFICADO DE DESARROLLO DE SOFTWARE

## FLUJO DE TRABAJO CAPTURA REQUISITOS

### Identificación de Actores y Casos de Uso

#### Actores del Sistema

Los actores son todas aquellas entidades externas que interactúan con el sistema, ya sean personas o sistemas externos.

En este proyecto de Punto de Venta Inteligente, los actores identificados son:

1. **Cliente:** Persona que realiza la compra usando la aplicación web o móvil.

2. **Vendedor (Cajero):** Usuario del sistema encargado de realizar y gestionar ventas.

3. **Administrador:** Usuario con control total del sistema, gestiona inventario, productos, usuarios y roles, y genera reportes.

4. **Supervisor de Inventario (Almacén):** Usuario encargado de gestionar y supervisar los niveles de inventario.

5. **Pasarela de Pago:** Sistema externo (Libélula, Stripe, etc.) que gestiona y procesa pagos en línea.

6. **Motor de Reconocimiento de Voz:** Sistema externo (Google Cloud Speech-to-Text, Vosk, etc.) que procesa comandos de voz.

#### Casos de Uso Principales

##### CU-01: Gestión de Usuarios

| Aspecto | Descripción |
|---------|-------------|
| **Actores** | Administrador |
| **Descripción** | Permite crear, modificar, eliminar y consultar usuarios del sistema |
| **Precondiciones** | El administrador debe estar autenticado con permisos adecuados |
| **Flujo Principal** | 1. El administrador accede al módulo de gestión de usuarios<br>2. Puede crear nuevos usuarios asignando roles<br>3. Puede modificar datos de usuarios existentes<br>4. Puede desactivar o eliminar usuarios<br>5. Puede consultar el historial de actividades |
| **Flujos Alternativos** | - Si el usuario ya existe, se muestra mensaje de error<br>- Si faltan datos obligatorios, se solicita completarlos |
| **Postcondiciones** | Los cambios quedan registrados en el sistema |

##### CU-02: Procesamiento de Ventas

| Aspecto | Descripción |
|---------|-------------|
| **Actores** | Vendedor, Cliente, Pasarela de Pago |
| **Descripción** | Permite registrar ventas de productos, aplicar descuentos y procesar pagos |
| **Precondiciones** | El vendedor debe estar autenticado y tener una sesión activa |
| **Flujo Principal** | 1. El vendedor selecciona productos por código o búsqueda<br>2. El sistema calcula el total<br>3. Se aplican descuentos si corresponde<br>4. Se procesa el pago (efectivo o tarjeta)<br>5. Se genera el comprobante de venta |
| **Flujos Alternativos** | - Si un producto no tiene stock, se notifica<br>- Si el pago es rechazado, se cancela la transacción |
| **Postcondiciones** | - El inventario se actualiza<br>- La venta queda registrada<br>- Se emite comprobante |

##### CU-03: Gestión de Inventario

| Aspecto | Descripción |
|---------|-------------|
| **Actores** | Administrador, Supervisor de Inventario |
| **Descripción** | Permite controlar el stock de productos, registrar entradas y salidas |
| **Precondiciones** | El usuario debe tener permisos de gestión de inventario |
| **Flujo Principal** | 1. El usuario accede al módulo de inventario<br>2. Puede registrar nuevos productos<br>3. Puede actualizar existencias<br>4. Puede configurar alertas de stock mínimo<br>5. Puede generar reportes de inventario |
| **Flujos Alternativos** | - Si se detectan inconsistencias, se genera alerta<br>- Si un producto llega a stock mínimo, se notifica |
| **Postcondiciones** | El inventario queda actualizado con trazabilidad de cambios |

##### CU-04: Control por Voz

| Aspecto | Descripción |
|---------|-------------|
| **Actores** | Vendedor, Motor de Reconocimiento de Voz |
| **Descripción** | Permite controlar funciones del sistema mediante comandos de voz |
| **Precondiciones** | El sistema de reconocimiento de voz debe estar activo |
| **Flujo Principal** | 1. El usuario activa el modo de reconocimiento de voz<br>2. Pronuncia comandos específicos<br>3. El sistema interpreta los comandos<br>4. Se ejecutan las acciones correspondientes |
| **Flujos Alternativos** | - Si el comando no es reconocido, se solicita repetirlo<br>- Si hay ruido ambiental excesivo, se sugiere usar interfaz manual |
| **Postcondiciones** | Las acciones solicitadas por voz se ejecutan correctamente |

### Requisitos Funcionales

1. **RF-01:** El sistema debe permitir la gestión completa de usuarios y roles.
2. **RF-02:** El sistema debe procesar ventas con múltiples formas de pago.
3. **RF-03:** El sistema debe gestionar el inventario en tiempo real.
4. **RF-04:** El sistema debe generar reportes de ventas e inventario.
5. **RF-05:** El sistema debe permitir control por comandos de voz.
6. **RF-06:** El sistema debe emitir comprobantes de venta.
7. **RF-07:** El sistema debe gestionar devoluciones y cambios.
8. **RF-08:** El sistema debe permitir aplicar descuentos y promociones.

### Requisitos No Funcionales

1. **RNF-01:** El sistema debe ser accesible desde dispositivos móviles y de escritorio.
2. **RNF-02:** El sistema debe responder en menos de 2 segundos a cualquier operación.
3. **RNF-03:** El sistema debe garantizar la seguridad de los datos mediante encriptación.
4. **RNF-04:** El sistema debe estar disponible 24/7 con un uptime mínimo del 99.5%.
5. **RNF-05:** El sistema debe ser intuitivo y fácil de usar para minimizar la curva de aprendizaje.
6. **RNF-06:** El sistema debe ser escalable para manejar incrementos en el volumen de transacciones.

### Modelo de Dominio

El modelo de dominio del sistema de Punto de Venta Inteligente incluye las siguientes entidades principales:

- **Usuario:** Representa a los usuarios del sistema con sus roles y permisos.
- **Producto:** Representa los artículos disponibles para la venta.
- **Inventario:** Gestiona las existencias de productos.
- **Venta:** Registra las transacciones de venta realizadas.
- **Cliente:** Almacena información de los clientes registrados.
- **Pago:** Gestiona las diferentes formas de pago.
- **Comprobante:** Representa los documentos generados tras una venta.

### Implementación y Despliegue

El sistema ha sido implementado utilizando tecnologías modernas y está disponible para su consulta en:

**Link de la página:** [https://frontend-pos-production.up.railway.app/](https://frontend-pos-production.up.railway.app/)

**Repositorio GitHub:** https://github.com/alvaroSG34/frontend-pos

### Prototipos

Se han desarrollado prototipos de las principales interfaces del sistema:

- **Prototipo 1 – Interfaz de Inicio de Sesión:** Pantalla de acceso al sistema mediante credenciales de usuario.
- **Prototipo 2 – Interfaz de Gestión de Usuarios:** Vista para administrar usuarios registrados, con funciones de edición, registro y eliminación.
- **Prototipo 3 – Interfaz de Roles y Permisos:** Módulo de configuración de roles y asignación de permisos específicos por perfil.
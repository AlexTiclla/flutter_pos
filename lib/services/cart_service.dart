import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/cart.dart';
import '../models/cart_item.dart';

class CartService {
  // Determinar la URL base según el entorno
  late final String baseUrl;

  // Constructor que configura la URL base según la plataforma
  CartService() {
    if (Platform.isAndroid) {
      // 10.0.2.2 es la dirección IP que Android usa para acceder al localhost del host
      baseUrl = 'http://10.0.2.2:8000/api/v1';
    } else if (Platform.isIOS) {
      // En iOS, el simulador puede acceder a localhost
      baseUrl = 'http://localhost:8000/api/v1';
    } else {
      // Para web u otras plataformas
      baseUrl = 'http://localhost:8000/api/v1';
    }
    print('Cart Service - Base URL configurada: $baseUrl');
  }

  // Obtener el carrito activo del usuario
  Future<Cart> getUserCart(int userId) async {
    try {
      print('Obteniendo carrito para usuario $userId');
      final response = await http.get(
        Uri.parse('$baseUrl/carts/user/$userId/active'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Respuesta getUserCart: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return Cart.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al obtener el carrito: ${response.body}');
      }
    } catch (e) {
      print('Error en getUserCart: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener los items del carrito
  Future<List<CartItem>> getCartItems(int cartId) async {
    try {
      print('Obteniendo items para carrito $cartId');
      final response = await http.get(
        Uri.parse('$baseUrl/carts/$cartId/items'),
        headers: {'Content-Type': 'application/json'},
      );

      print(
        'Respuesta getCartItems: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> itemsJson = jsonDecode(response.body);
        return itemsJson.map((json) {
          // Asegurar que todos los campos esperados estén presentes
          return CartItem(
            id: json['id'] ?? 0,
            idCarrito: json['id_carrito'] ?? 0,
            idProducto: json['id_producto'] ?? 0,
            cantidad: json['cantidad'] ?? 0,
            precioUnitario: json['precio_unitario']?.toDouble() ?? 0.0,
            descuento: json['descuento']?.toDouble() ?? 0.0,
            subtotal: json['subtotal']?.toDouble() ?? 0.0,
            nombreProducto: json['nombre_producto'] ?? 'Producto sin nombre',
            imagenProducto: json['imagen_producto'],
          );
        }).toList();
      } else {
        throw Exception(
          'Error al obtener los items del carrito: ${response.body}',
        );
      }
    } catch (e) {
      print('Error en getCartItems: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Agregar un producto al carrito
  Future<CartItem> addToCart(int cartId, int productId, int quantity) async {
    try {
      print(
        'Agregando producto $productId al carrito $cartId, cantidad: $quantity',
      );
      final response = await http.post(
        Uri.parse('$baseUrl/carts/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_carrito': cartId,
          'id_producto': productId,
          'cantidad': quantity,
          'descuento': 0,
        }),
      );

      print('Respuesta addToCart: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return CartItem(
          id: json['id'] ?? 0,
          idCarrito: json['id_carrito'] ?? 0,
          idProducto: json['id_producto'] ?? 0,
          cantidad: json['cantidad'] ?? 0,
          precioUnitario: json['precio_unitario']?.toDouble() ?? 0.0,
          descuento: json['descuento']?.toDouble() ?? 0.0,
          subtotal: json['subtotal']?.toDouble() ?? 0.0,
          nombreProducto: json['nombre_producto'] ?? 'Producto sin nombre',
          imagenProducto: json['imagen_producto'],
        );
      } else {
        throw Exception('Error al agregar al carrito: ${response.body}');
      }
    } catch (e) {
      print('Error en addToCart: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar la cantidad de un item en el carrito
  Future<CartItem> updateCartItemQuantity(int itemId, int newQuantity) async {
    try {
      print('Actualizando cantidad del item $itemId a $newQuantity');
      final response = await http.patch(
        Uri.parse('$baseUrl/carts/cart-items/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cantidad': newQuantity}),
      );

      print(
        'Respuesta updateCartItemQuantity: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return CartItem(
          id: json['id'] ?? 0,
          idCarrito: json['id_carrito'] ?? 0,
          idProducto: json['id_producto'] ?? 0,
          cantidad: json['cantidad'] ?? 0,
          precioUnitario: json['precio_unitario']?.toDouble() ?? 0.0,
          descuento: json['descuento']?.toDouble() ?? 0.0,
          subtotal: json['subtotal']?.toDouble() ?? 0.0,
          nombreProducto: json['nombre_producto'] ?? 'Producto sin nombre',
          imagenProducto: json['imagen_producto'],
        );
      } else {
        throw Exception('Error al actualizar el item: ${response.body}');
      }
    } catch (e) {
      print('Error en updateCartItemQuantity: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar un item del carrito
  Future<void> removeCartItem(int itemId) async {
    try {
      print('Eliminando item $itemId del carrito');
      final response = await http.delete(
        Uri.parse('$baseUrl/carts/cart-items/$itemId'),
        headers: {'Content-Type': 'application/json'},
      );

      print(
        'Respuesta removeCartItem: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar el item: ${response.body}');
      }
    } catch (e) {
      print('Error en removeCartItem: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Procesar el carrito (enviarlo a pago)
  Future<String> checkoutCart(int cartId, String metodoPago) async {
    try {
      print('Procesando carrito $cartId con método de pago: $metodoPago');
      final response = await http.post(
        Uri.parse('$baseUrl/carts/$cartId/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'metodo_pago': metodoPago}),
      );

      print(
        'Respuesta checkoutCart: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['message'] ?? 'Checkout completado con éxito';
      } else {
        throw Exception('Error al procesar el carrito: ${response.body}');
      }
    } catch (e) {
      print('Error en checkoutCart: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> clearCartBackend(int userId) async {
    final url = Uri.parse(
      'http://10.0.2.2:8000/api/v1/carts/user/$userId/clear',
    );

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Error al limpiar el carrito del backend: ${response.body}',
      );
    }
  }
}

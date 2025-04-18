import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  // Determinar la URL base según el entorno
  late final String baseUrl;

  // Constructor que configura la URL base según la plataforma
  ProductService() {
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
    print('Product Service - Base URL configurada: $baseUrl');
  }

  // Método para obtener todos los productos
  Future<List<Product>> getProducts() async {
    try {
      print('Obteniendo productos desde: $baseUrl/products');
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Respuesta de getProducts: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = jsonDecode(response.body);
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener productos: ${response.body}');
      }
    } catch (e) {
      print('Error en getProducts: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Método para obtener un producto por ID
  Future<Product> getProductById(int id) async {
    try {
      print('Obteniendo producto con ID $id desde: $baseUrl/products/$id');
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Respuesta de getProductById: ${response.statusCode}');

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al obtener el producto: ${response.body}');
      }
    } catch (e) {
      print('Error en getProductById: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}

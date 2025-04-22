import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'product_service.dart';

class RecommendationService {
  final ProductService _productService = ProductService();

  // Determinar la URL base según el entorno
  late final String baseUrl;

  // Constructor que configura la URL base según la plataforma
  RecommendationService() {
    if (Platform.isAndroid) {
      // 10.0.2.2 es la dirección IP que Android usa para acceder al localhost del host
      baseUrl = 'https://flaskbackend-production-41b8.up.railway.app/api/v1';
    } else if (Platform.isIOS) {
      // En iOS, el simulador puede acceder a localhost
      baseUrl = 'http://localhost:8000/api/v1';
    } else {
      // Para web u otras plataformas
      baseUrl = 'http://localhost:8000/api/v1';
    }
    print('Recommendation Service - Base URL configurada: $baseUrl');
  }

  // Obtener recomendaciones para un producto específico
  Future<List<Product>> getRecommendationsForProduct(
    int productId, {
    int maxRecommendations = 4,
  }) async {
    try {
      print('Obteniendo recomendaciones para producto $productId');
      final response = await http.get(
        Uri.parse(
          '$baseUrl/recommendations/product/$productId?max_recommendations=$maxRecommendations',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      print(
        'Respuesta getRecommendationsForProduct: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = jsonDecode(response.body);
        return productsJson
            .map((json) => Product.fromRecommendationJson(json))
            .toList();
      } else {
        print('Error al obtener recomendaciones: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error en getRecommendationsForProduct: $e');
      return [];
    }
  }

  // Obtener recomendaciones basadas en el carrito
  Future<List<Product>> getRecommendationsForCart(
    List<int> productIds, {
    int maxRecommendations = 4,
  }) async {
    try {
      print(
        'Obteniendo recomendaciones para carrito con productos: $productIds',
      );
      final response = await http.post(
        Uri.parse(
          '$baseUrl/recommendations/cart?max_recommendations=$maxRecommendations',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(productIds),
      );

      print(
        'Respuesta getRecommendationsForCart: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = jsonDecode(response.body);
        return productsJson
            .map((json) => Product.fromRecommendationJson(json))
            .toList();
      } else {
        print(
          'Error al obtener recomendaciones para el carrito: ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error en getRecommendationsForCart: $e');
      return [];
    }
  }

  /// Obtiene recomendaciones de productos basadas en los productos del carrito
  Future<List<Product>> getCartRecommendations(List<int> cartProductIds) async {
    if (cartProductIds.isEmpty) {
      return [];
    }

    try {
      // Obtener todos los productos
      final List<Product> allProducts = await _productService.getProducts();

      // Filtrar productos que ya están en el carrito
      final List<Product> availableProducts =
          allProducts
              .where((product) => !cartProductIds.contains(product.id))
              .toList();

      if (availableProducts.isEmpty) {
        return [];
      }

      // En un sistema real, aquí iría la lógica para recomendar productos
      // basados en los productos del carrito, historial del usuario, etc.
      // Por ahora, implementaremos una selección aleatoria de productos

      // Mezclar la lista para obtener diferentes productos cada vez
      availableProducts.shuffle(Random());

      // Determinar cuántos productos devolver (mínimo 5 o lo que esté disponible)
      final int count = min(8, availableProducts.length);

      return availableProducts.take(count).toList();
    } catch (e) {
      print('Error al obtener recomendaciones: $e');
      return [];
    }
  }

  /// Obtiene recomendaciones basadas en un producto específico
  Future<List<Product>> getProductRecommendations(int productId) async {
    try {
      // Obtener todos los productos
      final List<Product> allProducts = await _productService.getProducts();

      // Filtrar el producto actual
      final List<Product> availableProducts =
          allProducts.where((product) => product.id != productId).toList();

      if (availableProducts.isEmpty) {
        return [];
      }

      // Aquí iría la lógica para recomendar productos similares o complementarios
      // Por ahora, implementaremos una selección aleatoria
      availableProducts.shuffle(Random());

      // Devolver hasta 5 productos recomendados
      return availableProducts.take(5).toList();
    } catch (e) {
      print('Error al obtener recomendaciones para producto $productId: $e');
      return [];
    }
  }
}

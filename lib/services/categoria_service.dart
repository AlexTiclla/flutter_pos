import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categories.dart';

class CategoriaService {
  final String baseUrl = "http://10.0.2.2:8000/api/v1"; // ⬅️ Ajusta tu IP local

  Future<List<Categoria>> getCategorias() async {
    final token = await _getToken(); // Si usas auth con JWT
    final response = await http.get(
      Uri.parse('$baseUrl/categories/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Categoria.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar categorías');
    }
  }

  Future<String> _getToken() async {
    // Ejemplo simple, puedes adaptarlo
    return Future.value(""); // reemplaza si usas SharedPreferences
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venta_request.dart'; // crea este modelo

class VentaService {
  static Future<void> registrarVenta(VentaRequest venta) async {
    final response = await http.post(
      Uri.parse('https://flaskbackend-production-41b8.up.railway.app/api/v1/sales/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(venta.toJson()),
    );

    if (response.statusCode == 201) {
      print("✅ Venta registrada con éxito");
    } else {
      print("❌ Error al registrar venta: ${response.body}");
      throw Exception("Error al registrar venta");
    }
  }
}

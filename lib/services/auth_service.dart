import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  // Determinar la URL base según el entorno
  late final String baseUrl;

  // Almacenamiento seguro para el token
  final storage = const FlutterSecureStorage();

  // Constructor que configura la URL base según la plataforma
  AuthService() {
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
    print('Base URL configurada: $baseUrl');
  }

  // Método para convertir errores técnicos en mensajes amigables
  String _getFriendlyErrorMessage(dynamic error, String context) {
    String errorStr = error.toString();
    
    // Para errores de conexión
    if (errorStr.contains('SocketException') || errorStr.contains('Connection refused')) {
      return 'No se pudo conectar al servidor. Por favor verifica tu conexión a internet.';
    }
    
    // Para errores de inicio de sesión
    if (context == 'login') {
      if (errorStr.contains('Credenciales incorrectas')) {
        return 'El correo electrónico o la contraseña son incorrectos. Por favor verifica tus datos.';
      }
      if (errorStr.contains('Token inválido') || errorStr.contains('no autenticado')) {
        return 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.';
      }
    }
    
    // Para errores de registro
    if (context == 'register') {
      if (errorStr.contains('already exists') || errorStr.contains('ya está registrado')) {
        return 'Este correo electrónico ya está registrado. Por favor utiliza otro o inicia sesión.';
      }
    }
    
    // Mensaje genérico para otros errores
    return 'Ocurrió un error inesperado. Por favor intenta nuevamente más tarde.';
  }

  // Método para iniciar sesión
  Future<AuthToken> login(String email, String password) async {
    try {
      print('Intentando login con: $email a $baseUrl/auth/login');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Respuesta de login: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final authToken = AuthToken.fromJson(jsonDecode(response.body));

        // Guardar el token en el almacenamiento seguro
        await storage.write(key: 'token', value: authToken.accessToken);

        return authToken;
      } else {
        // Intentar analizar el cuerpo para un mensaje de error más específico
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            throw Exception(_getFriendlyErrorMessage('Credenciales incorrectas: ${errorData['detail']}', 'login'));
          }
        } catch (_) {}
        
        // Si no podemos analizar el cuerpo o no tiene un campo 'detail'
        throw Exception(_getFriendlyErrorMessage('Credenciales incorrectas', 'login'));
      }
    } catch (e) {
      print('Error en login: $e');
      throw Exception(_getFriendlyErrorMessage(e, 'login'));
    }
  }

  // Método para registrar un nuevo usuario
  Future<User> register(
    String nombre,
    String apellido,
    String email,
    String telefono,
    String password,
  ) async {
    try {
      print('Intentando registrar usuario: $email a $baseUrl/auth/register');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          'telefono': telefono,
          'password': password,
        }),
      );

      print('Respuesta de registro: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        // Intentar analizar el cuerpo para un mensaje de error más específico
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['detail'] != null) {
            throw Exception(_getFriendlyErrorMessage(errorData['detail'], 'register'));
          }
        } catch (_) {}
        
        throw Exception(_getFriendlyErrorMessage('Error al registrar usuario', 'register'));
      }
    } catch (e) {
      print('Error en register: $e');
      throw Exception(_getFriendlyErrorMessage(e, 'register'));
    }
  }

  // Método para obtener el perfil del usuario actual
  Future<User> getCurrentUser() async {
    try {
      final token = await storage.read(key: 'token');

      if (token == null) {
        throw Exception(_getFriendlyErrorMessage('No hay sesión activa', 'profile'));
      }

      print(
        'Obteniendo perfil de usuario con token: ${token.substring(0, min(10, token.length))}...',
      );
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        'Respuesta de getCurrentUser: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(_getFriendlyErrorMessage('Error al obtener perfil de usuario: ${response.body}', 'profile'));
      }
    } catch (e) {
      print('Error en getCurrentUser: $e');
      throw Exception(_getFriendlyErrorMessage(e, 'profile'));
    }
  }

  // Método para verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await storage.read(key: 'token');
    return token != null;
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    await storage.delete(key: 'token');
  }

  // Función auxiliar para obtener el mínimo de dos números
  int min(int a, int b) {
    return a < b ? a : b;
  }
}

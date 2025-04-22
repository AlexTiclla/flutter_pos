import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../models/user.dart';
import '../utils/text_decoder.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No se ha iniciado sesión'),
        ),
      );
    }

    // Decodificar los textos del usuario
    final nombre = TextDecoder.decodeText(user.nombre);
    final apellido = TextDecoder.decodeText(user.apellido);
    final email = user.email;
    final telefono = user.telefono;
    final fechaRegistro = user.fechaRegistro;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado con foto de perfil
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar del usuario
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Nombre completo
                  Text(
                    '$nombre $apellido',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Correo electrónico
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sección de información personal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información Personal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Tarjetas con la información del usuario
                  _buildInfoCard(
                    context,
                    'Nombre',
                    nombre,
                    Icons.person_outline,
                  ),
                  _buildInfoCard(
                    context,
                    'Apellido',
                    apellido,
                    Icons.person_outline,
                  ),
                  _buildInfoCard(
                    context,
                    'Correo Electrónico',
                    email,
                    Icons.email_outlined,
                  ),
                  _buildInfoCard(
                    context,
                    'Teléfono',
                    telefono ?? 'No registrado',
                    Icons.phone_outlined,
                  ),
                  _buildInfoCard(
                    context,
                    'Fecha de Registro',
                    fechaRegistro?.split('T')[0] ?? 'No disponible',
                    Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar información del usuario
  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 
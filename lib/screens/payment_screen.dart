import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/cart_provider.dart';
import '../services/auth_provider.dart';
import '../models/cart_item.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  Future<void> _iniciarPago() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null || cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay usuario o carrito vacío")),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Crear PaymentIntent desde backend
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/v1/stripe/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (cartProvider.total * 100).toInt(),
          'currency': 'usd',
        }),
      );

      final jsonResponse = json.decode(response.body);
      final clientSecret = jsonResponse['clientSecret'];

      // 2. Inicializar PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'POS Flutter',
        ),
      );

      // 3. Mostrar hoja de pago
      await Stripe.instance.presentPaymentSheet();

      // 4. Si se completa el pago, registrar venta
      await _registrarVenta(user.id, cartProvider);

      // 5. Limpiar carrito
      await cartProvider.clearCart(user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Pago y venta registrados exitosamente"),
          ),
        );
        Navigator.pop(context); // Volver
      }
    } on StripeException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error con Stripe: ${e.error.localizedMessage}"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error inesperado: $e")));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _registrarVenta(int userId, CartProvider cartProvider) async {
    final ventaRequest = {
      "id_usuario": userId,
      "fecha_venta": DateTime.now().toIso8601String(),
      "subtotal": cartProvider.total,
      "descuento": 0,
      "total": cartProvider.total,
      "metodo_pago": "tarjeta",
      "detalles":
          cartProvider.items
              .map(
                (item) => {
                  "id_producto": item.idProducto,
                  "cantidad": item.cantidad,
                  "precio_unitario": item.precioUnitario,
                  "descuento": 0,
                  "subtotal": item.subtotal,
                },
              )
              .toList(),
    };

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/v1/sales/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(ventaRequest),
    );

    if (response.statusCode != 201) {
      throw Exception("Error al registrar venta: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmar Pago"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child:
            _isProcessing
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _iniciarPago,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text("Pagar con Stripe"),
                ),
      ),
    );
  }
}

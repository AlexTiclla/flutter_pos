import 'package:flutter/material.dart';
import 'package:flutter_pos/models/product.dart';
import '../models/categories.dart';
import '../screens/ProductsByCategoryScreen.dart';

class VoiceCommandService {
  final Future<List<Product>> Function() getAllProducts;
  final Future<void> Function(Product) addToCart;
  final BuildContext context;
  final List<Categoria> categoriasDisponibles;

  final void Function() onAbrirCarrito;
  final void Function() onVerTodos;

  VoiceCommandService({
    required this.context,
    required this.categoriasDisponibles,
    required this.onAbrirCarrito,
    required this.onVerTodos,
    required this.getAllProducts,
    required this.addToCart,
  });

  void procesar(String texto) {
    final comando = texto.toLowerCase().trim();

    // 1. Comando: Añadir producto al carrito
    if (comando.startsWith('añadir ') && comando.contains('al carrito')) {
      final nombre =
          comando.replaceAll('añadir', '').replaceAll('al carrito', '').trim();
      _buscarYAgregarProducto(nombre);
      return;
    }

    // 2. Comando: Ver todos los productos
    if (comando.contains('ver todos')) {
      onVerTodos();
      return;
    }

    // 3. Comando: Abrir carrito (solo si es exacto o directo)
    if (comando == 'carrito' ||
        comando == 'abrir carrito' ||
        comando == 'ver carrito') {
      onAbrirCarrito();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abriendo carrito de compras...')),
      );
      return;
    }

    // 4. Comando: Detectar categoría
    final categoriaDetectada = _extraerCategoria(comando);
    if (categoriaDetectada != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ProductsByCategoryScreen(
                categoryId: categoriaDetectada.id,
                categoryName: categoriaDetectada.name,
              ),
        ),
      );
      return;
    }

    // 5. Comando no reconocido
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Comando no reconocido: "$texto"')));
  }

  Categoria? _extraerCategoria(String comando) {
    final texto = comando.toLowerCase().trim();

    for (final categoria in categoriasDisponibles) {
      final nombre = categoria.name.toLowerCase().trim();

      // Normalizar palabras
      final singular =
          nombre.endsWith('s')
              ? nombre.substring(0, nombre.length - 1)
              : nombre;
      final plural = '$nombre' + 's';

      final posiblesCoincidencias = {nombre, singular, plural};

      for (final palabra in posiblesCoincidencias) {
        if (texto.contains(palabra)) {
          return categoria;
        }
      }
    }

    return null;
  }

  void _buscarYAgregarProducto(String nombreBuscado) async {
    final productos = await getAllProducts();
    Product? productoEncontrado;

    try {
      productoEncontrado = productos.firstWhere(
        (p) => p.nombre.toLowerCase().contains(nombreBuscado.toLowerCase()),
      );
    } catch (e) {
      productoEncontrado = null;
    }

    if (productoEncontrado != null) {
      await addToCart(productoEncontrado);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${productoEncontrado.nombre} añadido al carrito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto "$nombreBuscado" no encontrado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

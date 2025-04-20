import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'product_recommendations.dart';

class ProductAddedDialog extends StatelessWidget {
  final Product product;
  final CartItem cartItem;
  final VoidCallback onContinueShopping;
  final VoidCallback onViewCart;

  const ProductAddedDialog({
    Key? key,
    required this.product,
    required this.cartItem,
    required this.onContinueShopping,
    required this.onViewCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado del diálogo
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Producto agregado al carrito',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onContinueShopping,
                  ),
                ],
              ),
            ),

            // Resumen del producto agregado
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del producto
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Detalles del producto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cantidad: ${cartItem.cantidad}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${cartItem.subtotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.deepPurple.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Recomendaciones de productos
            ProductRecommendations(
              productId: product.id,
              title: 'Los usuarios también han comprado',
              maxRecommendations: 4,
              onProductTap: (recommendedProduct) {
                // Cerrar el diálogo actual
                Navigator.of(context).pop();

                // Navegar al detalle del producto recomendado
                // Esto se puede implementar según la navegación de la app
              },
            ),

            // Botones de acción
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón para continuar comprando
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onContinueShopping,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.deepPurple),
                      ),
                      child: const Text('Continuar comprando'),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Botón para ver el carrito
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onViewCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Ver carrito'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

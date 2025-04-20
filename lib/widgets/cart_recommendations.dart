import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/recommendation_service.dart';

class CartRecommendations extends StatefulWidget {
  final List<CartItem> cartItems;
  final String title;
  final Function(Product) onProductTap;
  final int maxRecommendations;

  const CartRecommendations({
    Key? key,
    required this.cartItems,
    this.title = 'Productos recomendados',
    required this.onProductTap,
    this.maxRecommendations = 6,
  }) : super(key: key);

  @override
  State<CartRecommendations> createState() => _CartRecommendationsState();
}

class _CartRecommendationsState extends State<CartRecommendations> {
  final RecommendationService _recommendationService = RecommendationService();
  List<Product> _recommendations = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void didUpdateWidget(CartRecommendations oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Verificar si el carrito ha cambiado
    bool cartChanged = widget.cartItems.length != oldWidget.cartItems.length;
    if (!cartChanged) {
      for (int i = 0; i < widget.cartItems.length; i++) {
        if (widget.cartItems[i].idProducto !=
            oldWidget.cartItems[i].idProducto) {
          cartChanged = true;
          break;
        }
      }
    }

    // Si el carrito cambió, recargar recomendaciones
    if (cartChanged) {
      _loadRecommendations();
    }
  }

  Future<void> _loadRecommendations() async {
    if (widget.cartItems.isEmpty) {
      setState(() {
        _recommendations = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Obtener los IDs de productos en el carrito
      final List<int> productIds =
          widget.cartItems.map((item) => item.idProducto).toList();

      // Obtener recomendaciones basadas en el carrito
      final recommendations = await _recommendationService
          .getCartRecommendations(productIds);

      setState(() {
        _recommendations =
            recommendations.take(widget.maxRecommendations).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error al cargar recomendaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_recommendations.isEmpty && !_isLoading) {
      return const SizedBox.shrink(); // No mostrar nada si no hay recomendaciones
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_hasError)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No se pudieron cargar las recomendaciones',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                final product = _recommendations[index];
                return _RecommendedProductCard(
                  product: product,
                  onTap: () => widget.onProductTap(product),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _RecommendedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _RecommendedProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                product.imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 40),
                  );
                },
              ),
            ),

            // Información del producto
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '\$${product.precioVenta.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

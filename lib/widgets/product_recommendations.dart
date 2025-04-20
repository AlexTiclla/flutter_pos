import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/recommendation_service.dart';
import '../services/cart_provider.dart';
import 'package:provider/provider.dart';

class ProductRecommendations extends StatefulWidget {
  final int productId;
  final int maxRecommendations;
  final String title;
  final Function(Product)? onProductTap;

  const ProductRecommendations({
    Key? key,
    required this.productId,
    this.maxRecommendations = 4,
    this.title = 'Los usuarios también han comprado',
    this.onProductTap,
  }) : super(key: key);

  @override
  State<ProductRecommendations> createState() => _ProductRecommendationsState();
}

class _ProductRecommendationsState extends State<ProductRecommendations> {
  final RecommendationService _recommendationService = RecommendationService();
  bool _isLoading = true;
  List<Product> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recommendations = await _recommendationService
          .getRecommendationsForProduct(
            widget.productId,
            maxRecommendations: widget.maxRecommendations,
          );

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando recomendaciones: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recommendations.isEmpty) {
      return const SizedBox.shrink(); // No mostrar nada si no hay recomendaciones
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            widget.title,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendations.length,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemBuilder: (context, index) {
              final product = _recommendations[index];
              return RecommendedProductCard(
                product: product,
                onTap: () {
                  if (widget.onProductTap != null) {
                    widget.onProductTap!(product);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class RecommendedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const RecommendedProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                child: Image.network(
                  product.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
                ),
              ),

              // Detalles del producto
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del producto (limitado a 2 líneas)
                    Text(
                      product.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Precio del producto
                    Text(
                      '\$${product.precioVenta.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.deepPurple.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Botón para agregar al carrito
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await cartProvider.addToCart(product.id, 1);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.nombre} agregado al carrito',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          minimumSize: const Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Agregar',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para recomendaciones en el carrito
class CartRecommendations extends StatefulWidget {
  final List<int> productIds;
  final int maxRecommendations;
  final String title;
  final Function(Product)? onProductTap;

  const CartRecommendations({
    Key? key,
    required this.productIds,
    this.maxRecommendations = 4,
    this.title = 'Completa tu compra con',
    this.onProductTap,
  }) : super(key: key);

  @override
  State<CartRecommendations> createState() => _CartRecommendationsState();
}

class _CartRecommendationsState extends State<CartRecommendations> {
  final RecommendationService _recommendationService = RecommendationService();
  bool _isLoading = true;
  List<Product> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void didUpdateWidget(CartRecommendations oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Verificar si los productos del carrito cambiaron
    if (widget.productIds.length != oldWidget.productIds.length ||
        !widget.productIds.every((id) => oldWidget.productIds.contains(id))) {
      _loadRecommendations();
    }
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recommendations = await _recommendationService
          .getRecommendationsForCart(
            widget.productIds,
            maxRecommendations: widget.maxRecommendations,
          );

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando recomendaciones para carrito: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recommendations.isEmpty) {
      return const SizedBox.shrink(); // No mostrar nada si no hay recomendaciones
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            widget.title,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendations.length,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemBuilder: (context, index) {
              final product = _recommendations[index];
              return RecommendedProductCard(
                product: product,
                onTap: () {
                  if (widget.onProductTap != null) {
                    widget.onProductTap!(product);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

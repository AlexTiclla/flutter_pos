import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/text_decoder.dart';

class ProductsByCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ProductsByCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductsByCategoryScreen> createState() =>
      _ProductsByCategoryScreenState();
}

class _ProductsByCategoryScreenState extends State<ProductsByCategoryScreen> {
  final ProductService _productService = ProductService();
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFilteredProducts();
  }

  Future<void> _loadFilteredProducts() async {
    try {
      final all = await _productService.getProducts();
      final filtered =
          all.where((p) => p.idCategoria == widget.categoryId).toList();

      setState(() {
        _filteredProducts = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar productos: \$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final decodedCategoryName = TextDecoder.decodeText(widget.categoryName);

    return Scaffold(
      appBar: AppBar(
        title: Text('Productos: $decodedCategoryName'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _filteredProducts.isEmpty
              ? const Center(child: Text('No hay productos en esta categoría'))
              : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            product.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => const Icon(Icons.broken_image),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                TextDecoder.decodeText(product.nombre),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${product.precioVenta.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}

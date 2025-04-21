import 'package:flutter/material.dart';
import 'package:flutter_pos/models/categories.dart';
import 'package:flutter_pos/services/categoria_service.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../services/product_service.dart';
import '../services/cart_provider.dart';
import '../models/product.dart';
import 'login_screen.dart';
import 'products_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'ProductsByCategoryScreen.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Categoria> _categorias = [];
  final CategoriaService _categoriaService = CategoriaService();

  String? _comandoPendiente;
  final TextEditingController _searchController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: 'es_BO',
        onResult: (val) {
          setState(() {
            final recognized = val.recognizedWords;
            setState(() {
              _searchController.text = recognized;
              _comandoPendiente = recognized; // ← Espera confirmación
            });
          });
          // Aquí puedes filtrar productos si deseas
        },
      );
    }
  }

  void _procesarComando(String texto) {
    final comando = texto.toLowerCase();

    if (comando.contains('carrito')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abriendo carrito de compras...')),
      );
      // Aquí puedes navegar al carrito real si tienes esa pantalla
    } else if (comando.contains('televisor')) {
      _searchController.text = 'televisor';
      // Aquí puedes ejecutar búsqueda automáticamente
    } else if (comando.contains('ver todos')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProductsScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comando no reconocido: \"$texto\"')),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  final ProductService _productService = ProductService();
  List<Product> _featuredProducts = [];
  List<Product> _allProducts = []; // Todos los productos para búsqueda
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
    _loadCategorias();
    _loadUserCart();

    // Agregar listener para realizar búsqueda cuando cambia el texto
    _searchController.addListener(_handleSearch);
  }

  @override
  void dispose() {
    // Limpiar controller al destruir el widget
    _searchController.removeListener(_handleSearch);
    _searchController.dispose();
    super.dispose();
  }

  // Lista de productos filtrados para búsqueda
  List<Product> _filteredProducts = [];
  bool _isSearching = false;

  Future<void> _loadFeaturedProducts() async {
    try {
      final allProducts = await _productService.getProducts();
      // Guardar todos los productos para búsqueda
      setState(() {
        _allProducts = allProducts;
        _featuredProducts = allProducts.take(6).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleSearch() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      // Buscar en todos los productos, no solo en los destacados
      _filteredProducts =
          _allProducts
              .where((product) => product.nombre.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> _loadCategorias() async {
    try {
      final cats = await _categoriaService.getCategorias();
      setState(() {
        _categorias = cats;
      });
    } catch (e) {
      print('Error al cargar categorías: $e');
    }
  }

  void _buscarPorCategoria(String categoria) {
    setState(() {
      _searchController.text = categoria;
      // Aquí puedes también filtrar la lista de productos si deseas
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Filtrando por $categoria')));
    _loadUserCart();
  }

  Future<void> _loadUserCart() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      await Provider.of<CartProvider>(
        context,
        listen: false,
      ).loadUserCart(authProvider.user!.id);
    }
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda Online'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _navigateToCart,
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                color: Colors.deepPurple,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${user?.nombre ?? ''} ${user?.apellido ?? ''}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user?.email ?? 'correo@ejemplo.com',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tel: ${user?.telefono ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.store),
                      title: const Text('Productos'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductsScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Categorías'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navegar a la pantalla de categorías
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Categorías')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: const Text('Carrito de Compras'),
                      trailing:
                          cartProvider.itemCount > 0
                              ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${cartProvider.itemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              : null,
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToCart();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: const Text('Mis Pedidos'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navegar a la pantalla de pedidos
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mis pedidos')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Mi Perfil'),
                      onTap: () {
                        Navigator.pop(context);
                        // Navegar a la pantalla de perfil
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mi perfil')),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text('Cerrar sesión'),
                      onTap: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar productos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(_error!, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeaturedProducts,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeaturedProducts,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bienvenida
              Text(
                '¡Bienvenido a nuestra tienda!',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explora nuestros productos y encuentra lo que necesitas.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Barra de búsqueda con micrófono
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar productos...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _isSearching = false;
                                    });
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0.0,
                        ),
                      ),
                      onSubmitted: (value) {
                        _handleSearch();
                        // Desplazar hasta la sección de resultados
                        if (_isSearching && _filteredProducts.isNotEmpty) {
                          // Actualizar la UI para mostrar resultados
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón de búsqueda
                  InkWell(
                    onTap: () {
                      _handleSearch();
                      FocusScope.of(context).unfocus(); // Ocultar teclado
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_comandoPendiente != null)
                    Card(
                      color: Colors.deepPurple[50],
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Confirmar comando detectado?',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '"$_comandoPendiente"',
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _procesarComando(_comandoPendiente!);
                                    setState(() => _comandoPendiente = null);
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text('Confirmar'),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed:
                                      () => setState(
                                        () => _comandoPendiente = null,
                                      ),
                                  icon: const Icon(Icons.close),
                                  label: const Text('Cancelar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: Colors.deepPurple,
                    ),
                    onPressed: _isListening ? _stopListening : _startListening,
                    tooltip: _isListening ? 'Detener' : 'Escuchar',
                  ),
                ],
              ),

              // Mostrar resultados de búsqueda cuando está buscando
              if (_isSearching && _searchController.text.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Resultados de búsqueda: ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '"${_searchController.text}"',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _filteredProducts.isEmpty
                        ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 30.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron productos',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_filteredProducts.length} productos encontrados',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return _buildProductCard(product);
                              },
                            ),
                          ],
                        ),
                    const SizedBox(height: 16),
                    const Divider(),
                  ],
                ),

              const SizedBox(height: 24),

              // Sección de categorías
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child:
                    _categorias.isEmpty
                        ? const Center(child: Text('Cargando categorías...'))
                        : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categorias.length,
                          itemBuilder: (context, index) {
                            final cat = _categorias[index];
                            return _buildCategoryCard(
                              cat.name,
                              Icons.category,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ProductsByCategoryScreen(
                                          categoryId: cat.id,
                                          categoryName: cat.name,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ),
              const SizedBox(height: 24),

              // Sección de productos destacados
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Productos Destacados',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductsScreen(),
                        ),
                      );
                    },
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _featuredProducts.isEmpty
                  ? const Center(
                    child: Text('No hay productos destacados disponibles'),
                  )
                  : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: _featuredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _featuredProducts[index];
                      return _buildProductCard(product);
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String name, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(right: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: SizedBox(
          width: 100,
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.deepPurple),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        // Navegar a la página de detalle del producto
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProductDetailScreen(
                  productId: product.id,
                  productName: product.nombre,
                ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                product.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print("Error cargando imagen: $error");
                  return Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 40),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.precioVenta.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.bold,
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

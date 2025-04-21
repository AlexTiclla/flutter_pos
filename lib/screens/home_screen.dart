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
import '../services/voice_command_service.dart';

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

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  final ProductService _productService = ProductService();
  List<Product> _featuredProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
    _loadCategorias();
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
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Filtrando por $categoria')));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserCart();
    });
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      final allProducts = await _productService.getProducts();
      // Mostrar solo 6 productos como destacados
      setState(() {
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
                                    setState(() {
                                      _searchController.clear();
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
                      onChanged: (text) {
                        setState(
                          () {},
                        ); // para que aparezca o desaparezca el botón
                      },
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
                                    final voiceService = VoiceCommandService(
                                      context: context,
                                      categoriasDisponibles: _categorias,
                                      onAbrirCarrito: _navigateToCart,
                                      onVerTodos: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => const ProductsScreen(),
                                          ),
                                        );
                                      },
                                      getAllProducts:
                                          _productService.getProducts,
                                      addToCart: (product) async {
                                        await Provider.of<CartProvider>(
                                          context,
                                          listen: false,
                                        ).addToCart(product.id, 1);
                                      },
                                    );

                                    voiceService.procesar(_comandoPendiente!);

                                    voiceService.procesar(_comandoPendiente!);
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

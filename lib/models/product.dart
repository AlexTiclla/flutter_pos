class Product {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precioCompra;
  final double precioVenta;
  final String? imagen;
  final bool estado;
  final int idCategoria;
  final double rating; // Añadido para las estrellas de calificación
  final String? categoria; // 👈 nombre de la categoría

  Product({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precioCompra,
    required this.precioVenta,
    this.imagen,
    required this.estado,
    required this.idCategoria,
    this.rating = 0.0, // Valor por defecto
    this.categoria, // 👈 nuevo
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precioCompra: json['precio_compra'].toDouble(),
      precioVenta: json['precio_venta'].toDouble(),
      imagen: json['imagen'],
      estado: json['estado'],
      idCategoria: json['id_categoria'],
      // Para propósitos de ejemplo, generamos una calificación aleatoria
      rating: json['rating'] ?? (json['id'] % 5 + 1).toDouble(),
      categoria: json['categoria'],
    );
  }

  // Función para obtener una URL de imagen de placeholder si no existe
  String get imageUrl {
    if (imagen != null && imagen!.isNotEmpty) {
      return imagen!;
    }
    // Usamos placeholders de productos reales según la categoría
    final placeholders = [
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
      'https://images.unsplash.com/photo-1572635196237-14b3f281503f',
      'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f',
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
    ];

    return placeholders[id % placeholders.length];
  }
}

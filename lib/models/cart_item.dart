class CartItem {
  final int id;
  final int idCarrito;
  final int idProducto;
  int cantidad;
  final double precioUnitario;
  final double descuento;
  final double subtotal;
  final String nombreProducto;
  final String? imagenProducto;

  CartItem({
    required this.id,
    required this.idCarrito,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuento,
    required this.subtotal,
    required this.nombreProducto,
    this.imagenProducto,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      idCarrito: json['id_carrito'],
      idProducto: json['id_producto'],
      cantidad: json['cantidad'],
      precioUnitario: json['precio_unitario'].toDouble(),
      descuento: json['descuento'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
      nombreProducto: json['nombre_producto'],
      imagenProducto: json['imagen_producto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_carrito': idCarrito,
      'id_producto': idProducto,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'descuento': descuento,
      'subtotal': subtotal,
    };
  }

  // Método para actualizar la cantidad y recalcular el subtotal
  CartItem copyWithNewQuantity(int newCantidad) {
    return CartItem(
      id: id,
      idCarrito: idCarrito,
      idProducto: idProducto,
      cantidad: newCantidad,
      precioUnitario: precioUnitario,
      descuento: descuento,
      subtotal: (newCantidad * precioUnitario) - descuento,
      nombreProducto: nombreProducto,
      imagenProducto: imagenProducto,
    );
  }
}

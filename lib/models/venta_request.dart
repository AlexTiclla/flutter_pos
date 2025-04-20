class DetalleVenta {
  final int idProducto;
  final int cantidad;
  final double precioUnitario;
  final double descuento;
  final double subtotal;

  DetalleVenta({
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    this.descuento = 0,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() => {
    "id_producto": idProducto,
    "cantidad": cantidad,
    "precio_unitario": precioUnitario,
    "descuento": descuento,
    "subtotal": subtotal,
  };
}

class VentaRequest {
  final int idUsuario;
  final DateTime fechaVenta;
  final double subtotal;
  final double descuento;
  final double total;
  final String metodoPago; // debe ser: efectivo, tarjeta, etc.
  final List<DetalleVenta> detalles;

  VentaRequest({
    required this.idUsuario,
    required this.fechaVenta,
    required this.subtotal,
    required this.descuento,
    required this.total,
    required this.metodoPago,
    required this.detalles,
  });

  Map<String, dynamic> toJson() => {
    "id_usuario": idUsuario,
    "fecha_venta": fechaVenta.toIso8601String(),
    "subtotal": subtotal,
    "descuento": descuento,
    "total": total,
    "metodo_pago": metodoPago,
    "detalles": detalles.map((e) => e.toJson()).toList(),
  };
}

class Cart {
  final int id;
  final int idUsuario;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final String estado;
  final double subtotal;

  Cart({
    required this.id,
    required this.idUsuario,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.estado,
    required this.subtotal,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id_carrito'],
      idUsuario: json['id_usuario'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion']),
      estado: json['estado'],
      subtotal: json['subtotal'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_carrito': id,
      'id_usuario': idUsuario,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
      'estado': estado,
      'subtotal': subtotal,
    };
  }
}

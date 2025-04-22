import '../utils/text_decoder.dart';

class Categoria {
  final int id;
  final String name;
  final String? description;

  Categoria({required this.id, required this.name, this.description});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      name: TextDecoder.decodeText(json['name'] ?? ''),
      description: json['description'] != null ? TextDecoder.decodeText(json['description']) : null,
    );
  }
}

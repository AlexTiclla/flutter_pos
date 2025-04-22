class Categoria {
  final int id;
  final String name;
  final String? description;

  Categoria({required this.id, required this.name, this.description});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

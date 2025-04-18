import 'package:flutter/material.dart';

class SimpleRatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final int maxRating;
  final Color color;

  const SimpleRatingBar({
    Key? key,
    required this.rating,
    this.size = 20,
    this.maxRating = 5,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        if (index < rating.floor()) {
          // Estrella completa
          return Icon(Icons.star, size: size, color: color);
        } else if (index == rating.floor() && (rating % 1) > 0) {
          // Media estrella
          return Icon(Icons.star_half, size: size, color: color);
        } else {
          // Estrella vacía
          return Icon(Icons.star_border, size: size, color: color);
        }
      }),
    );
  }
}

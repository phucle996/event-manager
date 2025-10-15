import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRate;

  const RatingStars({super.key, required this.rating, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (i) => IconButton(
          onPressed: () => onRate(i + 1.0),
          icon: Icon(
            i < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 28,
          ),
        ),
      ),
    );
  }
}

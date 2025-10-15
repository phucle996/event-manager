import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewItem extends StatelessWidget {
  final Map<String, dynamic> review;

  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: color.primaryContainer,
              child: const Icon(Icons.person),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                review["name"],
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < review["rating"].round() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(review["comment"], style: text.bodySmall),
        const SizedBox(height: 4),
        Text(
          DateFormat("dd/MM/yyyy").format(review["date"]),
          style: text.bodySmall?.copyWith(
            color: color.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

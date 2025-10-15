import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          ...children.map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: c,
            ),
          ),
        ],
      ),
    );
  }
}

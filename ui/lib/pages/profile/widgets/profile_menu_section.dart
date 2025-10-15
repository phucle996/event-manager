import 'package:flutter/material.dart';

class ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: text.titleSmall?.copyWith(
                color: color.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          ...items.map((item) {
            return ListTile(
              leading: Icon(item["icon"], color: color.primary),
              title: Text(item["title"]),
              onTap: item["onTap"],
              trailing: const Icon(Icons.chevron_right),
            );
          }),
        ],
      ),
    );
  }
}

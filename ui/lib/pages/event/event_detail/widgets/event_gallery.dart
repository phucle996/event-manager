import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class EventGallery extends StatelessWidget {
  final List<String> gallery;

  const EventGallery({super.key, required this.gallery});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.eventImages,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: gallery.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                gallery[i],
                width: 280,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 280,
                  height: 180,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

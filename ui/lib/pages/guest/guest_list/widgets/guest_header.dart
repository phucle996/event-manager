import 'package:appflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class GuestHeader extends StatelessWidget {
  final VoidCallback onAddGuest;

  const GuestHeader({super.key, required this.onAddGuest});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final appLocalizations = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "👥 ${appLocalizations.guests}",
          style: text.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color.onSurface,
          ),
        ),
        FilledButton.icon(
          onPressed: onAddGuest,
          icon: const Icon(Icons.person_add_alt_1, size: 18),
          label: Text(appLocalizations.addGuest),
        ),
      ],
    );
  }
}

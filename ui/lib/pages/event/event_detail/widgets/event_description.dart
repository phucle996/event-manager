import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class EventDescription extends StatelessWidget {
  final String? description;

  const EventDescription({super.key, this.description});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.eventDescription,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          description ?? l10n.defaultEventDescription,
          style: text.bodyMedium?.copyWith(
            color: color.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

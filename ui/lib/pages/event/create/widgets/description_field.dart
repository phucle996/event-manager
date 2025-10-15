import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class EventDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const EventDescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      maxLines: 6,
      decoration: InputDecoration(
        labelText: l10n.detailedDescription,
        prefixIcon: const Icon(Icons.description),
        border: const OutlineInputBorder(),
      ),
      validator: (v) =>
          v == null || v.isEmpty ? l10n.pleaseEnterDescription : null,
    );
  }
}

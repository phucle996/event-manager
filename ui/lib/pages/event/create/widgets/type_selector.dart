import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

class EventTypeSelector extends StatefulWidget {
  final Function(String) onTypeChanged;
  final TextEditingController maxGuestsController;

  const EventTypeSelector({
    super.key,
    required this.onTypeChanged,
    required this.maxGuestsController,
  });

  @override
  State<EventTypeSelector> createState() => _EventTypeSelectorState();
}

class _EventTypeSelectorState extends State<EventTypeSelector> {
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    _selectedType ??= l10n.eventTypeOpen;

    OutlineInputBorder fintechBorder(Color borderColor) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: borderColor,
            width: 1.2,
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.eventType,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedType,
          dropdownColor: color.surface,
          decoration: InputDecoration(
            filled: true,
            fillColor: color.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            prefixIcon: const Icon(Icons.category_outlined),
            enabledBorder: fintechBorder(
                isDark ? Colors.white24 : Colors.grey.shade300),
            focusedBorder: fintechBorder(color.primary),
            border: fintechBorder(
                isDark ? Colors.white24 : Colors.grey.shade300),
          ),
          items: [
            DropdownMenuItem(
              value: l10n.eventTypeOpen,
              child: Text(l10n.eventTypeOpen),
            ),
            DropdownMenuItem(
              value: l10n.eventTypeLimited,
              child: Text(l10n.eventTypeLimited),
            ),
            DropdownMenuItem(
              value: l10n.eventTypePrivate,
              child: Text(l10n.eventTypePrivate),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedType = value);
            widget.onTypeChanged(value);
          },
        ),
        const SizedBox(height: 12),
        if (_selectedType == l10n.eventTypeLimited)
          TextFormField(
            controller: widget.maxGuestsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.maxGuests,
              prefixIcon: const Icon(Icons.people_outline),
              filled: true,
              fillColor: color.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              enabledBorder: fintechBorder(
                  isDark ? Colors.white24 : Colors.grey.shade300),
              focusedBorder: fintechBorder(color.primary),
              border: fintechBorder(
                  isDark ? Colors.white24 : Colors.grey.shade300),
            ),
            validator: (value) {
              if (_selectedType == l10n.eventTypeLimited) {
                final number = int.tryParse(value ?? "");
                if (number == null || number < 2) {
                  return l10n.minGuestsWarning;
                }
              }
              return null;
            },
          ),
      ],
    );
  }
}

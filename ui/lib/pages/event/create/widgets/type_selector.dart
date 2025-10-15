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

    // Initialize _selectedType with a localized value if it's null
    _selectedType ??= l10n.eventTypeOpen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.eventType, style: text.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedType, // Use value instead of initialValue
          decoration: InputDecoration(
            filled: true,
            fillColor: color.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.category_outlined),
          ),
          items: [
            DropdownMenuItem(
                value: l10n.eventTypeOpen,
                child: Text(l10n.eventTypeOpen)),
            DropdownMenuItem(
                value: l10n.eventTypeLimited,
                child: Text(l10n.eventTypeLimited)),
            DropdownMenuItem(
                value: l10n.eventTypePrivate,
                child: Text(l10n.eventTypePrivate)),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
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

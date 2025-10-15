import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'time_filter_sheet.dart';

class EventFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedTime, selectedStatus, selectedSort;
  final ValueChanged<String> onTimeChanged, onStatusChanged, onSortChanged;

  const EventFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedTime,
    required this.selectedStatus,
    required this.selectedSort,
    required this.onTimeChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Search
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: l10n.searchGuests,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: color.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 12),

        // Filter row
        Row(
          children: [
            // Time filter
            IconButton.filledTonal(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final range = await showTimeFilterSheet(context);
                if (range != null) onTimeChanged(range);
              },
            ),
            const SizedBox(width: 10),

            // Status filter
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedStatus,
                decoration: _dropdownDecoration(color, Icons.event_available),
                items: [
                  DropdownMenuItem(
                    value: "allStatuses",
                    child: Text(l10n.allStatuses),
                  ),
                  DropdownMenuItem(
                    value: "upcoming",
                    child: Text(l10n.upcomingEvents),
                  ),
                  DropdownMenuItem(
                    value: "ongoing",
                    child: Text(l10n.attended),
                  ),
                  DropdownMenuItem(
                    value: "completed",
                    child: Text(l10n.completed),
                  ),
                ],
                onChanged: (v) => onStatusChanged(v ?? "allStatuses"),
              ),
            ),
            const SizedBox(width: 10),

            // Sort filter
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedSort,
                decoration: _dropdownDecoration(color, Icons.sort),
                items: [
                  DropdownMenuItem(value: "newest", child: Text(l10n.newest)),
                  DropdownMenuItem(value: "oldest", child: Text(l10n.oldest)),
                  DropdownMenuItem(
                    value: "nameAZ",
                    child: Text(l10n.nameAZ),
                  ),
                  DropdownMenuItem(
                    value: "nameZA",
                    child: Text(l10n.nameZA),
                  ),
                ],
                onChanged: (v) => onSortChanged(v ?? "newest"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(ColorScheme color, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: color.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

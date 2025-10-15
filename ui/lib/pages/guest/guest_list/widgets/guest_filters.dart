import 'package:flutter/material.dart';

class GuestFilters extends StatelessWidget {
  final String selectedStatus;
  final String selectedSort;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onSortChanged;
  final Map<String, String> statusOptions;
  final Map<String, String> sortOptions;

  const GuestFilters({
    super.key,
    required this.selectedStatus,
    required this.selectedSort,
    required this.onStatusChanged,
    required this.onSortChanged,
    required this.statusOptions,
    required this.sortOptions,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Row(
      children: [
        Flexible(
          flex: 1,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            alignment: Alignment.centerLeft,
            menuMaxHeight: 260,
            value: selectedStatus,
            decoration: _dropdownDecoration(color, icon: Icons.people_alt),
            items: statusOptions.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: onStatusChanged,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 1,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            alignment: Alignment.centerLeft,
            menuMaxHeight: 260,
            value: selectedSort,
            decoration: _dropdownDecoration(color, icon: Icons.sort),
            items: sortOptions.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: onSortChanged,
          ),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(
    ColorScheme color, {
    required IconData icon,
  }) {
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

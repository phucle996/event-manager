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
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // 🔹 Filter dropdown (Status)
        Expanded(
          child: _GradientDropdown(
            icon: Icons.people_alt_outlined,
            label: "Trạng thái",
            value: selectedStatus,
            items: statusOptions,
            onChanged: onStatusChanged,
            color: color,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 14),

        // 🔹 Sort dropdown
        Expanded(
          child: _GradientDropdown(
            icon: Icons.sort_rounded,
            label: "Sắp xếp",
            value: selectedSort,
            items: sortOptions,
            onChanged: onSortChanged,
            color: color,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _GradientDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;
  final ColorScheme color;
  final bool isDark;

  const _GradientDropdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: isDark
          ? [color.surfaceContainerHigh, color.surfaceContainerHighest]
          : [Colors.white, color.surfaceContainerHighest.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        dropdownColor: color.surface,
        borderRadius: BorderRadius.circular(14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: color.onSurfaceVariant.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: color.primary),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
        items: items.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(
              entry.value,
              overflow: TextOverflow.ellipsis, // 🔹 Nếu chữ dài thì rút gọn
              maxLines: 1,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

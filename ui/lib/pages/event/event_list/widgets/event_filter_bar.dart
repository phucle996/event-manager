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
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔍 Search bar
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: l10n.searchGuests,
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: color.surfaceContainerHighest,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 🎛 Filter Row
        Row(
          children: [
            // 📅 Time filter button
            _FilterButton(
              icon: Icons.calendar_month_rounded,
              label: _getTimeLabel(selectedTime, l10n),
              color: color,
              isDark: isDark,
              onTap: () async {
                final result = await showTimeFilterSheet(context);
                if (result != null) onTimeChanged(result);
              },
            ),

            const SizedBox(width: 10),

            // 🧭 Status dropdown
            Expanded(
              child: _GradientDropdown(
                value: selectedStatus,
                icon: Icons.event_available_rounded,
                color: color,
                isDark: isDark,
                items: {
                  "allStatuses": l10n.allStatuses,
                  "upcoming": l10n.upcomingEvents,
                  "ongoing": l10n.attended,
                  "completed": l10n.completed,
                },
                onChanged: onStatusChanged,
              ),
            ),

            const SizedBox(width: 10),

            // 🔄 Sort dropdown
            Expanded(
              child: _GradientDropdown(
                value: selectedSort,
                icon: Icons.sort_rounded,
                color: color,
                isDark: isDark,
                items: {
                  "newest": l10n.newest,
                  "oldest": l10n.oldest,
                  "nameAZ": l10n.nameAZ,
                  "nameZA": l10n.nameZA,
                },
                onChanged: onSortChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getTimeLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case "thisWeek":
        return l10n.thisWeek;
      case "thisMonth":
        return l10n.thisMonth;
      case "thisYear":
        return l10n.thisYear;
      default:
        return l10n.allTime;
    }
  }
}

/// 🔘 Nút bộ lọc thời gian (hiệu ứng bóng mềm)
class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme color;
  final bool isDark;

  const _FilterButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark
              ? color.surfaceContainerHigh
              : color.surfaceContainerHighest.withOpacity(0.8),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🌈 Dropdown bo tròn, đẹp và ngắn gọn
class _GradientDropdown extends StatelessWidget {
  final String value;
  final IconData icon;
  final Map<String, String> items;
  final ValueChanged<String> onChanged;
  final ColorScheme color;
  final bool isDark;

  const _GradientDropdown({
    required this.value,
    required this.icon,
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
          : [Colors.white, color.surfaceContainerHighest.withOpacity(0.9)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.outlineVariant.withOpacity(0.2),
          width: 0.8,
        ),
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: value,
        dropdownColor: color.surface,
        borderRadius: BorderRadius.circular(12),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: color.primary),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        items: items.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (v) => onChanged(v ?? items.keys.first),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import 'status_badge.dart';

class EventBasicInfo extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventBasicInfo({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final String name = event["name"] ?? l10n.noEventName;
    final String status = event["status"] ?? l10n.unknownStatus;
    final Color statusColor = event["color"] as Color? ?? Colors.blueGrey;

    DateTime? parseUtcToLocal(dynamic value) {
      if (value == null) return null;
      return DateTime.parse(value.toString()).toLocal();
    }

    final startDate = parseUtcToLocal(event["start_date"]);
    final endDate = parseUtcToLocal(event["end_date"]);

    String dateText;
    if (startDate != null && endDate != null) {
      final dateFmt = DateFormat('dd/MM/yyyy');
      final timeFmt = DateFormat('HH:mm');

      if (startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day) {
        final timeRange = l10n.sameDayTimeFormat(
          timeFmt.format(startDate),
          timeFmt.format(endDate),
        );
        dateText = '${dateFmt.format(startDate)} ($timeRange)';
      } else {
        dateText = l10n.differentDayFormat(
          dateFmt.format(startDate),
          dateFmt.format(endDate),
        );
      }
    } else if (startDate != null) {
      dateText = DateFormat(l10n.fullDayFormat, locale).format(startDate);
    } else {
      dateText = l10n.unknownTime;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.15),
            radius: 30,
            child: Icon(Icons.event, color: statusColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                StatusBadge(label: status, color: statusColor),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        dateText,
                        style: text.bodyMedium?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

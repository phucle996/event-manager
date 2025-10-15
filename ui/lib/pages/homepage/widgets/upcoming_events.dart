import 'package:appflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/event_model.dart';
import '../../event/event_detail/event_detail_page.dart';

class UpcomingEvents extends StatelessWidget {
  final List<EventModel> events;
  const UpcomingEvents({super.key, required this.events});

  String _formatUpcomingDate(BuildContext context, DateTime date) {
    final appLocalizations = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);
    final difference = eventDate.difference(today).inDays;

    if (difference == 0) {
      return appLocalizations.today;
    } else if (difference == 1) {
      return appLocalizations.tomorrow;
    } else if (difference > 1 && difference < 7) {
      return DateFormat('EEEE', locale).format(date);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));

    final upcomingIn7Days = events.where((e) {
      return e.startDate.isAfter(now) && e.startDate.isBefore(sevenDaysFromNow);
    }).toList();

    if (upcomingIn7Days.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(appLocalizations.noUpcomingEventsIn7Days,
            style: const TextStyle(fontStyle: FontStyle.italic)
          ),
        ),
      );
    }

    return Column(
      children: upcomingIn7Days.map((event) {
        final dateString = _formatUpcomingDate(context, event.startDate);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailPage(event: event),
                  ),
                );
              },
              child: Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                 ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blueAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(event.location, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(dateString, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

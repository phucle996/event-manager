import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/event_model.dart';
import '../../../widgets/modern_section_card.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({
    super.key,
    required this.events,
    this.onEventTap,
  });

  final List<EventModel> events;
  final void Function(EventModel event)? onEventTap;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return ModernSectionCard(
        title: 'Sự kiện sắp diễn ra',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Hiện chưa có sự kiện nào sắp diễn ra.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ModernSectionCard(
      title: 'Sự kiện sắp diễn ra',
      child: Column(
        children: [
          for (final event in events)
            _EventTile(
              key: ValueKey(event.id),
              event: event,
              onTap: () => onEventTap?.call(event),
            ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({super.key, required this.event, this.onTap});

  final EventModel event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy • HH:mm');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: const Icon(Icons.event_note_rounded, color: Colors.indigo),
      title: Text(
        event.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${event.location} • ${formatter.format(event.startDate)}',
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}

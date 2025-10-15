import 'package:flutter/material.dart';
import '../../../models/event_model.dart';
import 'package:intl/intl.dart';

class HighlightEvents extends StatelessWidget {
  final List<EventModel> events;

  const HighlightEvents({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (events.isEmpty) {
      return const Text("Không có sự kiện nổi bật.");
    }

    return Column(
      children: events.map((e) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.withValues(alpha: 0.15),
              child: const Icon(Icons.event, color: Colors.indigo),
            ),
            title: Text(e.name,
                style:
                text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text(
              "${e.location} • ${DateFormat('dd/MM/yyyy').format(e.startDate)}",
            ),
          ),
        );
      }).toList(),
    );
  }
}

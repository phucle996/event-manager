import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../services/event_api_service.dart';

class EventStatsSection extends StatefulWidget {
  final String eventId;
  final bool isOffline;
  final Map<String, int>? initialStats;

  const EventStatsSection({
    super.key,
    required this.eventId,
    this.isOffline = false,
    this.initialStats,
  });

  @override
  State<EventStatsSection> createState() => _EventStatsSectionState();
}

class _EventStatsSectionState extends State<EventStatsSection> {
  Future<Map<String, int>>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    if (widget.isOffline) {
      setState(() {
        _statsFuture = Future.value(widget.initialStats ?? const {});
      });
    } else {
      setState(() {
        _statsFuture = EventApiService().getGuestStats(widget.eventId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.attendanceStats,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        FutureBuilder<Map<String, int>>(
          future: _statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  l10n.loadingError(snapshot.error.toString()),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }
            final stats = snapshot.data ?? {};
            final registered = stats['registered'] ?? 0;
            final checkedIn = stats['checked_in'] ?? 0;
            final absent = registered - checkedIn;

            if (widget.isOffline && stats.isEmpty) {
              return Center(
                child: Text(
                  l10n.noGuestsFound,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  l10n.registeredUsers,
                  registered.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                _StatCard(
                  l10n.checkedIn,
                  checkedIn.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _StatCard(
                  l10n.absentees,
                  absent.toString(),
                  Icons.cancel,
                  Colors.redAccent,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

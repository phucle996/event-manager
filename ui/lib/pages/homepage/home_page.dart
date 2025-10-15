import 'package:appflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/event_api_service.dart';

import 'widgets/header_section.dart';
import 'widgets/highlight_events.dart';
import 'widgets/overview_section.dart';
import 'widgets/performance_chart.dart';
import 'widgets/upcoming_events.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _api = EventApiService();
  late Future<List<EventModel>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = _api.getEvents();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final nowText = DateFormat("dd/MM/yyyy").format(DateTime.now());
    final appLocalizations = AppLocalizations.of(context)!;

    return FutureBuilder<List<EventModel>>(
      future: _futureEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "❌ ${appLocalizations.errorLoadingData}: ${snapshot.error}",
              style: text.bodyMedium?.copyWith(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          );
        }

        final events = snapshot.data ?? [];
        final highlight = events.take(3).toList();
        final upcoming = events
            .where((e) => e.startDate.isAfter(DateTime.now()))
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderSection(userName: "Phúc", date: nowText),
              const SizedBox(height: 24),

              Text(appLocalizations.overview, style: text.titleMedium),
              const SizedBox(height: 12),
              const OverviewSection(),
              const SizedBox(height: 28),

              Text(appLocalizations.participationPerformance, style: text.titleMedium),
              const SizedBox(height: 12),
              const PerformanceChart(),
              const SizedBox(height: 28),

              Text(appLocalizations.highlightEvents, style: text.titleMedium),
              const SizedBox(height: 8),
              HighlightEvents(events: highlight),
              const SizedBox(height: 28),

              Text(appLocalizations.upcomingEvents, style: text.titleMedium),
              const SizedBox(height: 8),
              UpcomingEvents(events: upcoming),

            ],
          ),
        );
      },
    );
  }

}

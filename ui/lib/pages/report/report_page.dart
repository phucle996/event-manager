import 'dart:collection';

import 'package:appflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/analytics_model.dart';
import '../../models/event_model.dart';
import '../../models/event_type_guest_stat_model.dart';
import '../../services/analytics_api_service.dart';
import '../../services/event_api_service.dart';
import 'widgets/event_status_chart.dart';
import 'widgets/event_type_guest_chart.dart';
import 'widgets/monthly_event_chart.dart';
import 'widgets/summary_card.dart';

enum ReportFilter { all, attendees, participation }

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final EventApiService _eventApi = EventApiService();
  final AnalyticsApiService _analyticsApi = AnalyticsApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<EventModel> _events = const [];
  List<EventGuestStatModel> _guestStats = const [];
  List<EventTypeGuestStatModel> _eventTypeStats = const [];
  ReportFilter _activeFilter = ReportFilter.all;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _eventApi.getEvents(),
        _analyticsApi.getGuestStatsByEvent(),
        _analyticsApi.getGuestStatsByEventType(),
      ]);

      if (!mounted) return;

      setState(() {
        _events = results[0] as List<EventModel>;
        _guestStats = results[1] as List<EventGuestStatModel>;
        _eventTypeStats = results[2] as List<EventTypeGuestStatModel>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  int get _totalEvents => _events.length;

  int get _totalAttendees =>
      _guestStats.fold<int>(0, (sum, stat) => sum + stat.totalGuests);

  int get _totalCheckedIn =>
      _guestStats.fold<int>(0, (sum, stat) => sum + stat.checkedIn);

  double get _participationRate =>
      _totalAttendees == 0 ? 0 : (_totalCheckedIn / _totalAttendees) * 100;

  List<EventModel> get _filteredEvents {
    switch (_activeFilter) {
      case ReportFilter.attendees:
        final eventIds = _guestStats
            .where((stat) => stat.totalGuests > 0)
            .map((stat) => stat.eventId)
            .toSet();
        return _events.where((event) => eventIds.contains(event.id)).toList();
      case ReportFilter.participation:
        final eventIds = _guestStats
            .where((stat) => stat.checkedIn > 0)
            .map((stat) => stat.eventId)
            .toSet();
        return _events.where((event) => eventIds.contains(event.id)).toList();
      case ReportFilter.all:
        return _events;
    }
  }

  Map<String, int> _buildStatusCounts(Iterable<EventModel> events) {
    final counts = <String, int>{
      'upcoming': 0,
      'ongoing': 0,
      'completed': 0,
      'other': 0,
    };

    for (final event in events) {
      final key = _statusKey(event.status);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  LinkedHashMap<String, int> _buildMonthlyCounts(Iterable<EventModel> events) {
    final counts = <DateTime, int>{};
    for (final event in events) {
      final key = DateTime(event.startDate.year, event.startDate.month);
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final formatter = DateFormat('MM/yy');
    final entries = counts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return LinkedHashMap<String, int>.fromEntries(
      entries.map(
        (entry) => MapEntry(formatter.format(entry.key), entry.value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final filteredEvents = _filteredEvents;
    final statusCounts = _buildStatusCounts(filteredEvents);
    final monthlyCounts = _buildMonthlyCounts(filteredEvents);
    final localizedStatusCounts = _localizeStatusCounts(statusCounts, l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsAndStatistics), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildErrorState(l10n, textTheme)
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        l10n.eventOverview,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(l10n),
                    const SizedBox(height: 28),
                    if (_activeFilter == ReportFilter.attendees)
                      _buildEventTypeGuestChart(l10n, textTheme)
                    else
                      _buildEventStatusChart(
                        l10n,
                        textTheme,
                        localizedStatusCounts,
                      ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        l10n.monthlyEventCount,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 260,
                      child: MonthlyEventChart(
                        labels: monthlyCounts.keys.toList(),
                        values: monthlyCounts.values.toList(),
                        emptyLabel: l10n.noEvents,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryRow(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SummaryCard(
            icon: Icons.event,
            label: l10n.totalEvents,
            value: _totalEvents.toString(),
            color: Colors.indigo,
            isSelected: _activeFilter == ReportFilter.all,
            onTap: () => _setFilter(ReportFilter.all),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryCard(
            icon: Icons.people,
            label: l10n.attendees,
            value: _totalAttendees.toString(),
            color: Colors.green,
            isSelected: _activeFilter == ReportFilter.attendees,
            onTap: () => _setFilter(ReportFilter.attendees),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryCard(
            icon: Icons.percent,
            label: l10n.participationPerformance,
            value: '${_participationRate.toStringAsFixed(0)}%',
            color: Colors.orange,
            isSelected: _activeFilter == ReportFilter.participation,
            onTap: () => _setFilter(ReportFilter.participation),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTypeGuestChart(AppLocalizations l10n, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            l10n.guestDistributionByEventType,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: EventTypeGuestChart(
            stats: _eventTypeStats,
            emptyLabel: l10n.noEvents,
          ),
        ),
      ],
    );
  }

  Widget _buildEventStatusChart(
    AppLocalizations l10n,
    TextTheme textTheme,
    Map<String, int> localizedStatusCounts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            l10n.eventStatusDistribution,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: EventStatusChart(
            statusCounts: localizedStatusCounts,
            emptyLabel: l10n.noEvents,
          ),
        ),
      ],
    );
  }

  void _setFilter(ReportFilter filter) {
    if (_activeFilter == filter) return;
    setState(() {
      _activeFilter = filter;
    });
  }

  Widget _buildErrorState(AppLocalizations l10n, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.loadingError(_errorMessage ?? ''),
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _loadData, child: Text(l10n.retry)),
        ],
      ),
    );
  }

  Map<String, int> _localizeStatusCounts(
    Map<String, int> counts,
    AppLocalizations l10n,
  ) {
    final localized = <String, int>{};
    if ((counts['upcoming'] ?? 0) > 0) {
      localized[l10n.upcomingEvents] = counts['upcoming']!;
    }
    if ((counts['ongoing'] ?? 0) > 0) {
      localized[l10n.ongoing] = counts['ongoing']!;
    }
    if ((counts['completed'] ?? 0) > 0) {
      localized[l10n.completed] = counts['completed']!;
    }
    final other = counts['other'] ?? 0;
    if (other > 0) {
      localized[l10n.unknownStatus] = other;
    }
    return localized;
  }

  String _statusKey(String status) {
    final normalized = _normalize(status);
    if (normalized.contains('sap dien ra') || normalized.contains('upcoming')) {
      return 'upcoming';
    }
    if (normalized.contains('dang dien ra') || normalized.contains('ongoing')) {
      return 'ongoing';
    }
    if (normalized.contains('da ket thuc') ||
        normalized.contains('completed')) {
      return 'completed';
    }
    return 'other';
  }

  String _normalize(String value) {
    var result = value.toLowerCase();
    const replacements = {
      '\u0111': 'd',
      '\u00e1': 'a',
      '\u00e0': 'a',
      '\u1ea3': 'a',
      '\u00e3': 'a',
      '\u1ea1': 'a',
      '\u0103': 'a',
      '\u1eaf': 'a',
      '\u1eb1': 'a',
      '\u1eb3': 'a',
      '\u1eb5': 'a',
      '\u1eb7': 'a',
      '\u00e2': 'a',
      '\u1ea5': 'a',
      '\u1ea7': 'a',
      '\u1ea9': 'a',
      '\u1eab': 'a',
      '\u1ead': 'a',
      '\u00e9': 'e',
      '\u00e8': 'e',
      '\u1ebb': 'e',
      '\u1ebd': 'e',
      '\u1eb9': 'e',
      '\u00ea': 'e',
      '\u1ebf': 'e',
      '\u1ec1': 'e',
      '\u1ec3': 'e',
      '\u1ec5': 'e',
      '\u1ec7': 'e',
      '\u00ed': 'i',
      '\u00ec': 'i',
      '\u1ec9': 'i',
      '\u0129': 'i',
      '\u1ecb': 'i',
      '\u00f3': 'o',
      '\u00f2': 'o',
      '\u1ecf': 'o',
      '\u00f5': 'o',
      '\u1ecd': 'o',
      '\u00f4': 'o',
      '\u1ed1': 'o',
      '\u1ed3': 'o',
      '\u1ed5': 'o',
      '\u1ed7': 'o',
      '\u1ed9': 'o',
      '\u01a1': 'o',
      '\u1edb': 'o',
      '\u1edd': 'o',
      '\u1edf': 'o',
      '\u1ee1': 'o',
      '\u1ee3': 'o',
      '\u00fa': 'u',
      '\u00f9': 'u',
      '\u1ee7': 'u',
      '\u0169': 'u',
      '\u1ee5': 'u',
      '\u01b0': 'u',
      '\u1ee9': 'u',
      '\u1eeb': 'u',
      '\u1eed': 'u',
      '\u1eef': 'u',
      '\u1ef1': 'u',
      '\u00fd': 'y',
      '\u1ef3': 'y',
      '\u1ef7': 'y',
      '\u1ef9': 'y',
      '\u1ef5': 'y',
    };

    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }
}

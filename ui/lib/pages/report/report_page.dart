import 'dart:collection';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/analytics_model.dart';
import '../../models/event_model.dart';
import '../../models/event_type_guest_stat_model.dart';
import '../../providers/connectivity_provider.dart';
import '../../repositories/dashboard_repository.dart';
import '../../widgets/app_page_background.dart';
import '../../widgets/modern_section_card.dart';
import 'widgets/event_status_chart.dart';
import 'widgets/event_type_guest_chart.dart';
import './widgets/monthly_event_chart.dart';
import 'widgets/summary_card.dart';
import './widgets/report_header_widget.dart';

enum ReportFilter { all, attendees, participation }

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final DashboardRepository _repository = DashboardRepository();

  bool _isLoading = true;
  String? _error;
  List<EventModel> _events = [];
  List<EventGuestStatModel> _guestStats = [];
  List<EventTypeGuestStatModel> _eventTypeStats = [];
  List<ParticipationTrendPoint> _participationTrend = [];
  ReportFilter _activeFilter = ReportFilter.all;
  bool _isOfflineData = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _repository.loadDashboard();
      if (!mounted) return;
      setState(() {
        _events = result.events;
        _guestStats = result.guestStats;
        _eventTypeStats = result.eventTypeStats;
        _participationTrend = result.participationTrend;
        _isOfflineData = result.fromCache;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  int get _totalEvents => _events.length;
  int get _totalGuests => _guestStats.fold(0, (sum, s) => sum + s.totalGuests);
  int get _checkedIn => _guestStats.fold(0, (sum, s) => sum + s.checkedIn);
  double get _participation =>
      _totalGuests == 0 ? 0 : (_checkedIn / _totalGuests) * 100;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const AppPageBackground(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return AppPageBackground(
        child: Center(
          child: Text(
            l10n.loadingError(_error!),
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final filtered = _filterEvents();
    final statusCounts = _statusCount(filtered);
    final monthlyCounts = _monthlyTrend(filtered);
    final localizedStatus = _localizedStatus(statusCounts, l10n);

    final connectivity = context.watch<ConnectivityProvider>();
    final isOffline = _isOfflineData || !connectivity.isOnline;

    return AppPageBackground(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🌟 Header
            ReportHeaderWidget(onRefresh: _loadData),
            if (isOffline)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  l10n.offlineBanner,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),

            // 🧭 Overview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.eventOverview,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.reportOverviewSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          icon: Icons.event,
                          label: l10n.totalEvents,
                          value: _totalEvents.toString(),
                          color: Colors.indigo,
                          isSelected: _activeFilter == ReportFilter.all,
                          onTap: () =>
                              setState(() => _activeFilter = ReportFilter.all),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          icon: Icons.people,
                          label: l10n.attendees,
                          value: _totalGuests.toString(),
                          color: Colors.green,
                          isSelected: _activeFilter == ReportFilter.attendees,
                          onTap: () => setState(
                            () => _activeFilter = ReportFilter.attendees,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          icon: Icons.percent_rounded,
                          label: l10n.participationPerformance,
                          value: '${_participation.toStringAsFixed(0)}%',
                          color: Colors.orange,
                          isSelected:
                              _activeFilter == ReportFilter.participation,
                          onTap: () => setState(
                            () => _activeFilter = ReportFilter.participation,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 📊 Chart Section
            ModernSectionCard(
              title: _activeFilter == ReportFilter.participation
                  ? l10n.participationPerformance
                  : _activeFilter == ReportFilter.attendees
                  ? l10n.guestDistributionByEventType
                  : l10n.eventStatusDistribution,
              subtitle: _activeFilter == ReportFilter.participation
                  ? l10n.performanceTrendSubtitle
                  : null,
              child: SizedBox(
                height: _activeFilter == ReportFilter.participation ? 280 : 260,
                child: Builder(
                  builder: (context) {
                    if (_activeFilter == ReportFilter.participation) {
                      if (_participationTrend.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.noEvents,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        );
                      }

                      final color = Theme.of(context).colorScheme.primary;
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 12,
                          right: 4,
                        ),
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 20,
                                  getTitlesWidget: (value, _) => Text(
                                    '${value.toInt()}%',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[500]),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 24,
                                  getTitlesWidget: (value, _) {
                                    final index = value.toInt();
                                    if (index < 0 ||
                                        index >= _participationTrend.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final m = _participationTrend[index].period;
                                    return Text(
                                      DateFormat('MM/yy').format(m),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[400],
                                            fontSize: 11,
                                          ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                color: color,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      color.withOpacity(0.25),
                                      color.withOpacity(0.05),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                spots: _participationTrend
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => FlSpot(
                                        e.key.toDouble(),
                                        e.value.participationRate
                                            .clamp(0, 100)
                                            .toDouble(),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (_activeFilter == ReportFilter.attendees) {
                      return EventTypeGuestChart(
                        stats: _eventTypeStats,
                        emptyLabel: l10n.noEvents,
                      );
                    }

                    return EventStatusChart(
                      statusCounts: localizedStatus,
                      emptyLabel: l10n.noEvents,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📈 Monthly Trend
            ModernSectionCard(
              title: l10n.monthlyEventCount,
              subtitle: l10n.monthlyEventSubtitle,
              child: SizedBox(
                height: 250,
                child: MonthlyEventChart(
                  labels: monthlyCounts.keys.toList(),
                  values: monthlyCounts.values.toList(),
                  emptyLabel: l10n.noEvents,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers
  List<EventModel> _filterEvents() {
    switch (_activeFilter) {
      case ReportFilter.attendees:
        final ids = _guestStats
            .where((s) => s.totalGuests > 0)
            .map((s) => s.eventId)
            .toSet();
        return _events.where((e) => ids.contains(e.id)).toList();
      case ReportFilter.participation:
        final ids = _guestStats
            .where((s) => s.checkedIn > 0)
            .map((s) => s.eventId)
            .toSet();
        return _events.where((e) => ids.contains(e.id)).toList();
      default:
        return _events;
    }
  }

  Map<String, int> _statusCount(List<EventModel> events) {
    final map = {'upcoming': 0, 'ongoing': 0, 'completed': 0};
    for (final e in events) {
      final s = e.status.toLowerCase();
      if (s.contains('sắp')) {
        map['upcoming'] = (map['upcoming'] ?? 0) + 1;
      } else if (s.contains('đang')) {
        map['ongoing'] = (map['ongoing'] ?? 0) + 1;
      } else if (s.contains('kết')) {
        map['completed'] = (map['completed'] ?? 0) + 1;
      }
    }
    return map;
  }

  LinkedHashMap<String, int> _monthlyTrend(List<EventModel> fallbackEvents) {
    if (_participationTrend.isNotEmpty) {
      final sorted = List.of(_participationTrend)
        ..sort((a, b) => a.period.compareTo(b.period));
      final fmt = DateFormat('MM/yy');
      final entries = sorted.map(
        (point) =>
            MapEntry(fmt.format(point.period.toLocal()), point.totalGuests),
      );
      final map = LinkedHashMap<String, int>.fromEntries(entries);
      final hasNonZero = map.values.any((value) => value > 0);
      if (hasNonZero) return map;
    }
    return _monthlyCount(fallbackEvents);
  }

  LinkedHashMap<String, int> _monthlyCount(List<EventModel> events) {
    final counts = <DateTime, int>{};
    for (final e in events) {
      final key = DateTime(e.startDate.year, e.startDate.month);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final fmt = DateFormat('MM/yy');
    return LinkedHashMap.fromEntries(
      sorted.map((e) => MapEntry(fmt.format(e.key), e.value)),
    );
  }

  Map<String, int> _localizedStatus(
    Map<String, int> counts,
    AppLocalizations l10n,
  ) {
    return {
      l10n.upcomingEvents: counts['upcoming'] ?? 0,
      l10n.ongoing: counts['ongoing'] ?? 0,
      l10n.completed: counts['completed'] ?? 0,
    };
  }
}

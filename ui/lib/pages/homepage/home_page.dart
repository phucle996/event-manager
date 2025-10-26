import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/analytics_model.dart';
import '../../models/event_model.dart';
import '../../providers/connectivity_provider.dart';
import '../../repositories/dashboard_repository.dart';
import '../../widgets/app_page_background.dart';
import '../event/event_detail/event_detail_page.dart';
import 'widgets/featured_event_banner.dart';
import 'widgets/hero_header.dart';
import 'widgets/quick_actions.dart';
import 'widgets/stats_overview.dart';
import 'widgets/tips_news_section.dart';
import 'widgets/upcoming_events_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DashboardRepository _repository = DashboardRepository();

  bool _isLoading = true;
  String? _errorMessage;
  List<EventModel> _events = const [];
  List<EventGuestStatModel> _guestStats = const [];
  bool _isOfflineData = false;

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
      final result = await _repository.loadDashboard();
      if (!mounted) return;
      setState(() {
        _events = result.events;
        _guestStats = result.guestStats;
        _isOfflineData = result.fromCache;
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

  int get _totalGuests => _guestStats.fold<int>(
    0,
    (previousValue, element) => previousValue + element.totalGuests,
  );

  int get _totalCheckedIn => _guestStats.fold<int>(
    0,
    (previousValue, element) => previousValue + element.checkedIn,
  );

  List<EventModel> get _upcomingEvents {
    final now = DateTime.now();
    final filtered =
        _events.where((event) => event.startDate.isAfter(now)).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
    if (filtered.isNotEmpty) {
      return filtered;
    }
    final fallback = List<EventModel>.from(_events)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return fallback;
  }

  EventModel? get _featuredEvent =>
      _upcomingEvents.isNotEmpty ? _upcomingEvents.first : null;

  void _openEventDetail(EventModel event) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EventDetailPage(event: event)));
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();

    return AppPageBackground(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final featuredEvent = _featuredEvent;
    final upcomingEvents = _upcomingEvents.take(5).toList();
    final connectivity = context.watch<ConnectivityProvider>();
    final isOffline = _isOfflineData || !connectivity.isOnline;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const HeroHeader(),
        QuickActions(isOffline: isOffline),
        if (isOffline)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.offlineBanner,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.orange.shade700),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 20),
        StatsOverview(
          totalEvents: _totalEvents,
          totalGuests: _totalGuests,
          totalCheckedIn: _totalCheckedIn,
        ),
        FeaturedEventBanner(
          event: featuredEvent,
          onTap: featuredEvent != null
              ? () => _openEventDetail(featuredEvent)
              : null,
        ),
        UpcomingEventsSection(
          events: upcomingEvents,
          onEventTap: _openEventDetail,
          isOffline: isOffline,
        ),
        const TipsNewsSection(),
      ],
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            'Không thể tải dữ liệu dashboard',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

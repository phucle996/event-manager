import 'package:flutter/material.dart';
import '../../models/analytics_model.dart';
import '../../models/event_model.dart';
import '../../services/analytics_api_service.dart';
import '../../services/event_api_service.dart';
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
  final EventApiService _eventApi = EventApiService();
  final AnalyticsApiService _analyticsApi = AnalyticsApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<EventModel> _events = const [];
  List<EventGuestStatModel> _guestStats = const [];

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
      ]);

      if (!mounted) return;
      setState(() {
        _events = results[0] as List<EventModel>;
        _guestStats = results[1] as List<EventGuestStatModel>;
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

    return Column(
      children: [
        const HeroHeader(),
        const QuickActions(),
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

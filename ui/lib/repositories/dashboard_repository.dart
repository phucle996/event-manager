import '../data/local/cache_database.dart';
import '../models/analytics_model.dart';
import '../models/event_model.dart';
import '../models/event_type_guest_stat_model.dart';
import '../services/analytics_api_service.dart';
import '../services/event_api_service.dart';

class DashboardRepository {
  DashboardRepository({
    EventApiService? eventApi,
    AnalyticsApiService? analyticsApi,
    CacheDatabase? cacheDatabase,
  }) : _eventApi = eventApi ?? EventApiService(),
       _analyticsApi = analyticsApi ?? AnalyticsApiService(),
       _cache = cacheDatabase ?? CacheDatabase.instance;

  final EventApiService _eventApi;
  final AnalyticsApiService _analyticsApi;
  final CacheDatabase _cache;

  Future<DashboardResult> loadDashboard() async {
    List<EventModel> events = const [];
    List<EventGuestStatModel> guestStats = const [];
    List<EventTypeGuestStatModel> typeStats = const [];
    List<ParticipationTrendPoint> trend = const [];
    Object? firstError;

    Future<T?> attempt<T>(Future<T> Function() action) async {
      try {
        return await action();
      } catch (err) {
        firstError ??= err;
        return null;
      }
    }

    final fetchedEvents = await attempt(() => _eventApi.getEvents());
    if (fetchedEvents != null) {
      events = fetchedEvents;
      if (events.isNotEmpty) {
        await _cache.cacheEvents(events);
      }
    }

    final fetchedGuestStats = await attempt(
      () => _analyticsApi.getGuestStatsByEvent(),
    );
    if (fetchedGuestStats != null) {
      guestStats = fetchedGuestStats;
      if (guestStats.isNotEmpty) {
        await _cache.cacheGuestStats(guestStats);
      }
    }

    final fetchedTypeStats = await attempt(
      () => _analyticsApi.getGuestStatsByEventType(),
    );
    if (fetchedTypeStats != null) {
      typeStats = fetchedTypeStats;
      if (typeStats.isNotEmpty) {
        await _cache.cacheEventTypeStats(typeStats);
      }
    }

    final fetchedTrend = await attempt(
      () => _analyticsApi.getParticipationTrend(
        from: DateTime.now().subtract(const Duration(days: 365)),
        to: DateTime.now(),
        granularity: 'month',
      ),
    );
    if (fetchedTrend != null) {
      trend = fetchedTrend;
      if (trend.isNotEmpty) {
        await _cache.cacheParticipationTrend(trend);
      }
    }

    final hasRemoteData =
        events.isNotEmpty || guestStats.isNotEmpty || typeStats.isNotEmpty;

    if (hasRemoteData) {
      return DashboardResult(
        events: events,
        guestStats: guestStats,
        eventTypeStats: typeStats,
        participationTrend: trend,
        fromCache: firstError != null,
        error: firstError,
      );
    }

    final cachedEvents = await _cache.getCachedEvents();
    final cachedGuestStats = await _cache.getCachedGuestStats();
    final cachedTypeStats = await _cache.getCachedEventTypeStats();
    final cachedTrend = await _cache.getCachedParticipationTrend();

    final hasCache =
        cachedEvents.isNotEmpty ||
        cachedGuestStats.isNotEmpty ||
        cachedTypeStats.isNotEmpty;

    if (hasCache) {
      return DashboardResult(
        events: cachedEvents,
        guestStats: cachedGuestStats,
        eventTypeStats: cachedTypeStats,
        participationTrend: cachedTrend,
        fromCache: true,
        error: firstError,
      );
    }

    if (firstError != null) {
      return DashboardResult(
        events: const [],
        guestStats: const [],
        eventTypeStats: const [],
        participationTrend: const [],
        fromCache: true,
        error: firstError,
      );
    }

    return const DashboardResult.empty();
  }
}

class DashboardResult {
  DashboardResult({
    required this.events,
    required this.guestStats,
    required this.eventTypeStats,
    required this.participationTrend,
    required this.fromCache,
    this.error,
  });

  const DashboardResult.empty()
    : events = const [],
      guestStats = const [],
      eventTypeStats = const [],
      participationTrend = const [],
      fromCache = true,
      error = null;

  final List<EventModel> events;
  final List<EventGuestStatModel> guestStats;
  final List<EventTypeGuestStatModel> eventTypeStats;
  final List<ParticipationTrendPoint> participationTrend;
  final bool fromCache;
  final Object? error;
}

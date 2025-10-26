import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../data/local/cache_database.dart';
import '../../../models/analytics_model.dart';
import '../../../models/event_model.dart';
import '../../../providers/connectivity_provider.dart';
import '../../../services/event_api_service.dart';
import '../edit/main_page.dart';

import 'widgets/event_basic_info.dart';
import 'widgets/event_description.dart';
import 'widgets/event_gallery.dart';
import 'widgets/event_location_card.dart';
import 'widgets/event_reviews.dart';
import 'widgets/event_stats_section.dart';
import 'widgets/share_event_sheet.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final _api = EventApiService();

  bool _isLoading = true;
  EventModel? _event;
  String? _error;
  bool _isOffline = false;
  Map<String, int>? _cachedStats;

  @override
  void initState() {
    super.initState();
    _fetchEventDetail();
  }

  Future<void> _fetchEventDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _api.getEventById(widget.event.id);
      await CacheDatabase.instance.cacheEvent(res);
      if (!mounted) return;
      setState(() {
        _event = res;
        _isLoading = false;
        _isOffline = false;
        _cachedStats = null;
      });
    } catch (e) {
      final cachedEvent = await CacheDatabase.instance.getCachedEventById(
        widget.event.id,
      );
      final cachedStat = await CacheDatabase.instance
          .getCachedGuestStatsByEvent(widget.event.id);
      if (!mounted) return;
      if (cachedEvent != null) {
        setState(() {
          _event = cachedEvent;
          _isLoading = false;
          _isOffline = true;
          _error = null;
          if (cachedStat != null) {
            _cachedStats = {
              'registered': cachedStat.totalGuests,
              'checked_in': cachedStat.checkedIn,
            };
          } else {
            _cachedStats = null;
          }
        });
      } else {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToEditPage(EventModel eventData) {
    Navigator.of(context)
        .push<EventModel>(
          MaterialPageRoute(
            builder: (context) => EventEditPage(event: eventData),
          ),
        )
        .then((updatedEvent) {
          if (updatedEvent != null && mounted) {
            setState(() {
              _event = updatedEvent;
            });
            _fetchEventDetail();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final connectivity = context.watch<ConnectivityProvider>();
    final isOffline = _isOffline || !connectivity.isOnline;

    final e = _event ?? widget.event;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(e.name.isNotEmpty ? e.name : l10n.eventDetails),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(e.name.isNotEmpty ? e.name : l10n.eventDetails),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.couldNotLoadEventDetails,
                  style: text.titleMedium?.copyWith(color: colorScheme.error),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _fetchEventDetail,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final now = DateTime.now();
    String status;
    Color statusColor;

    // Determine status based on dates first, providing a default
    if (now.isBefore(e.startDate)) {
      status = l10n.upcomingEvents;
      statusColor = Colors.indigo;
    } else if (now.isAfter(e.endDate)) {
      status = l10n.completed;
      statusColor = Colors.grey;
    } else {
      status = l10n.ongoing;
      statusColor = Colors.green;
    }

    // Then, you can also handle the raw status from API if needed for specific logic,
    // but the displayed status should be the localized one.

    final eventForBasicInfo = {
      "name": e.name,
      "status": status, // Use the localized status
      "color": statusColor,
      "start_date": e.startDate,
      "end_date": e.endDate,
    };

    final List<String> gallery = (e.imageUrls.isNotEmpty)
        ? e.imageUrls
        : [
            "https://picsum.photos/seed/${e.id}/600/300",
            "https://picsum.photos/seed/${e.id}b/600/300",
            "https://picsum.photos/seed/${e.id}c/600/300",
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(e.name, overflow: TextOverflow.ellipsis),
        actions: [
          if (!_isReadOnly(status) && !isOffline)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n.editEvent,
              onPressed: () => _navigateToEditPage(e),
            ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n.share,
            onPressed: () => shareEvent(context, e.toJson()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEventDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isOffline)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.offlineBanner,
                    style: text.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              EventBasicInfo(event: eventForBasicInfo),
              const SizedBox(height: 24),
              EventStatsSection(
                eventId: e.id,
                isOffline: isOffline,
                initialStats: _cachedStats,
              ),
              const SizedBox(height: 28),
              EventLocationCard(location: e.location),
              const SizedBox(height: 28),
              EventDescription(
                description: e.description?.isNotEmpty == true
                    ? e.description
                    : l10n.noDescription,
              ),
              const SizedBox(height: 28),
              EventGallery(gallery: gallery),
              const SizedBox(height: 28),
              EventReviews(status: status, eventColor: Colors.blueAccent),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  bool _isReadOnly(String? status) {
    final l10n = AppLocalizations.of(context)!;
    final s = status?.toLowerCase() ?? "";
    // Compare with the localized strings
    return s == l10n.ongoing.toLowerCase() || s == l10n.completed.toLowerCase();
  }
}

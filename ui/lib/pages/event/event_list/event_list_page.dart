import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/local/cache_database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/event_model.dart';
import '../../../providers/connectivity_provider.dart';
import '../../../services/event_api_service.dart';
import '../../../utils/app_toast.dart';
import '../../../widgets/app_page_background.dart';
import '../create/main_page.dart';
import './widgets/event_filter_bar.dart';
import './widgets/event_header.dart';
import './widgets/event_item.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final _api = EventApiService();

  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  String _selectedTime = "allTime";
  String _selectedStatus = "allStatuses";
  String _selectedSort = "newest";
  int _visibleCount = 6;

  List<EventModel> _events = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _deletingEventId;
  bool _isOfflineData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEvents();
    });
  }

  String _getBackendStatusValue(String key) {
    switch (key) {
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'completed':
        return 'Đã kết thúc';
      default:
        return 'Tất cả trạng thái';
    }
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      DateTime? from;
      DateTime? to;
      final now = DateTime.now();

      if (_selectedTime == "thisMonth") {
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 0);
      } else if (_selectedTime == "thisYear") {
        from = DateTime(now.year, 1, 1);
        to = DateTime(now.year, 12, 31);
      }

      final statusForApi = _selectedStatus == 'allStatuses'
          ? null
          : _getBackendStatusValue(_selectedStatus);

      final data = await _api.getEvents(
        status: statusForApi,
        from: from,
        to: to,
      );
      if (!mounted) return;
      setState(() {
        _events = data;
        _isLoading = false;
        _isOfflineData = false;
      });
      await CacheDatabase.instance.cacheEvents(data);
    } catch (e) {
      final cached = await CacheDatabase.instance.getCachedEvents();
      if (!mounted) return;
      if (cached.isNotEmpty) {
        setState(() {
          _events = cached;
          _isLoading = false;
          _isOfflineData = true;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToCreatePage() async {
    if (_isOfflineMode()) {
      _showOfflineMessage();
      return;
    }

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) => const EventCreatePage(),
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );

    if (result != null && mounted) {
      final l10n = AppLocalizations.of(context)!;
      final msg = result['message'] as String? ?? l10n.createEventSuccess;
      showAppToast(context, "🎉 $msg", type: ToastType.success);
      _fetchEvents();
    }
  }

  Future<void> _confirmDelete(EventModel event) async {
    if (_isOfflineMode()) {
      _showOfflineMessage();
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final materialL10n = MaterialLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.delete),
          content: Text('${l10n.delete} "${event.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(materialL10n.cancelButtonLabel),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) await _deleteEvent(event.id);
  }

  Future<void> _deleteEvent(String eventId) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _deletingEventId = eventId);

    try {
      await _api.deleteEvent(eventId);
      if (!mounted) return;
      setState(() {
        _events.removeWhere((event) => event.id == eventId);
        _deletingEventId = null;
      });
      showAppToast(context, l10n.eventDeleted, type: ToastType.info);
    } catch (e) {
      if (!mounted) return;
      setState(() => _deletingEventId = null);
      showAppToast(
        context,
        l10n.deleteError(e.toString()),
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final filtered = _events.where((e) {
      final search = _searchText.toLowerCase();
      final nameMatch = e.name.toLowerCase().contains(search);

      final backendStatusValue = _getBackendStatusValue(_selectedStatus);
      final statusMatch =
          _selectedStatus == "allStatuses" || e.status == backendStatusValue;

      final now = DateTime.now();
      bool timeMatch = true;
      if (_selectedTime == "thisMonth") {
        timeMatch =
            e.startDate.month == now.month && e.startDate.year == now.year;
      } else if (_selectedTime == "thisWeek") {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        timeMatch =
            e.startDate.isAfter(startOfWeek) && e.startDate.isBefore(endOfWeek);
      } else if (_selectedTime == "thisYear") {
        timeMatch = e.startDate.year == now.year;
      }
      return nameMatch && statusMatch && timeMatch;
    }).toList();

    filtered.sort((a, b) {
      switch (_selectedSort) {
        case "nameAZ":
          return a.name.compareTo(b.name);
        case "nameZA":
          return b.name.compareTo(a.name);
        case "oldest":
          return a.startDate.compareTo(b.startDate);
        default:
          return b.startDate.compareTo(a.startDate);
      }
    });

    final visibleEvents = filtered.take(_visibleCount).toList();
    final hasMore = _visibleCount < filtered.length;
    final connectivity = context.watch<ConnectivityProvider>();
    final isOffline = _isOfflineData || !connectivity.isOnline;

    if (_isLoading) {
      return const AppPageBackground(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return AppPageBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.loadingError(_errorMessage!),
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _fetchEvents, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }

    // ✅ Main layout
    return AppPageBackground(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                EventHeader(
                  onCreateEvent: _navigateToCreatePage,
                  isOffline: isOffline,
                ),
                if (isOffline)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      l10n.eventListOfflineSubtitle,
                      style: text.bodySmall?.copyWith(
                        color: Colors.orange.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                EventFilterBar(
                  searchController: _searchController,
                  onSearchChanged: (v) => setState(() => _searchText = v),
                  selectedStatus: _selectedStatus,
                  selectedSort: _selectedSort,
                  selectedTime: _selectedTime,
                  onStatusChanged: (v) {
                    setState(() => _selectedStatus = v);
                    _fetchEvents();
                  },
                  onSortChanged: (v) => setState(() => _selectedSort = v),
                  onTimeChanged: (v) {
                    setState(() => _selectedTime = v);
                    _fetchEvents();
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.showingEvents365,
                  style: text.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                if (visibleEvents.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      l10n.noEvents,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ...visibleEvents.map((event) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventItem(
                        key: ValueKey(event.id),
                        event: event,
                        index: visibleEvents.indexOf(event),
                        isDeleting: event.id == _deletingEventId,
                        onDelete: () => _confirmDelete(event),
                        canDelete: !isOffline,
                      ),
                    );
                  }),
                if (hasMore)
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _visibleCount += 4),
                      icon: const Icon(Icons.expand_more_rounded),
                      label: Text(l10n.loadMore),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  bool _isOfflineMode() {
    final connectivity = context.read<ConnectivityProvider>();
    return _isOfflineData || !connectivity.isOnline;
  }

  void _showOfflineMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚫 Không thể thực hiện khi đang ngoại tuyến.'),
      ),
    );
  }
}

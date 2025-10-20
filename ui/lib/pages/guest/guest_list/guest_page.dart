import 'package:flutter/material.dart';
import 'package:appflutter/l10n/app_localizations.dart';

import '../guest_new/guest_add_page.dart';
import '../../../models/guest_model.dart';
import '../../../services/guest_api_service.dart';
import '../../../utils/app_toast.dart';
import '../../../widgets/app_page_background.dart';

import './widgets/guest_header_stats.dart';
import './widgets/guest_filters.dart';
import './widgets/guest_list_section.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  final _api = GuestApiService();
  final _searchController = TextEditingController();

  String _searchText = '';
  String _selectedStatus = 'all';
  String _selectedSort = 'nameAZ';
  int _visibleCount = 8;

  List<GuestModel> _guests = [];
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, String> _statusOptions = {};
  Map<String, String> _sortOptions = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        _visibleCount = 8;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchGuests());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _statusOptions = {
      'all': l10n.allStatuses,
      'attended': l10n.attended,
      'registered': l10n.registered,
      'preRegistered': l10n.preRegistered,
      'absent': l10n.absent,
    };
    _sortOptions = {
      'nameAZ': l10n.nameAZ,
      'nameZA': l10n.nameZA,
      'newest': l10n.newest,
      'oldest': l10n.oldest,
    };
  }

  Future<void> _fetchGuests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _api.getGuests();
      if (!mounted) return;
      setState(() {
        _guests = data;
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

  String _statusKeyForGuest(GuestModel g) {
    if (g.hasEmail && g.hasPhone) return 'attended';
    if (g.hasEmail) return 'registered';
    if (g.hasPhone) return 'preRegistered';
    return 'absent';
  }

  List<GuestModel> _applyFilters() {
    final keyword = _searchText.trim().toLowerCase();
    final filtered = _guests.where((g) {
      final matchesKeyword = keyword.isEmpty ||
          g.fullName.toLowerCase().contains(keyword) ||
          (g.email ?? '').toLowerCase().contains(keyword) ||
          (g.phone ?? '').toLowerCase().contains(keyword);

      final matchesStatus =
          _selectedStatus == 'all' || _statusKeyForGuest(g) == _selectedStatus;

      return matchesKeyword && matchesStatus;
    }).toList();

    switch (_selectedSort) {
      case 'nameZA':
        filtered.sort((a, b) =>
            b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()));
        break;
      case 'newest':
        filtered.sort((a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
        break;
      case 'oldest':
        filtered.sort((a, b) =>
            (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
        break;
      default:
        filtered.sort((a, b) =>
            a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
    }

    return filtered;
  }

  Future<void> _openAddGuest() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const GuestAddPage()),
    );

    if (result == null || result['success'] != true) return;
    final guest = result['guest'] as GuestModel?;
    if (guest == null) return;

    setState(() {
      _guests.insert(0, guest);
      if (_visibleCount < _guests.length) _visibleCount++;
    });

    showAppToast(context, l10n.guestCreateSuccess, type: ToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final filteredGuests = _applyFilters();

    // 🌀 Loading state
    if (_isLoading) {
      return const AppPageBackground(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ❌ Error state
    if (_errorMessage != null) {
      return AppPageBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text(
                l10n.loadingError(_errorMessage!),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _fetchGuests,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Main layout
    return AppPageBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🧭 Header Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GuestHeaderStats(
                total: _guests.length,
                attended: _guests
                    .where((g) => _statusKeyForGuest(g) == 'attended')
                    .length,
                pending: _guests
                    .where((g) => _statusKeyForGuest(g) == 'preRegistered')
                    .length,
                onAddGuest: _openAddGuest,
              ),
            ),

            const SizedBox(height: 12),

            // 🧾 Nội dung có thể cuộn
            // 🧾 Nội dung có thể cuộn
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: ListView(
                  key: ValueKey(_guests.length + _selectedStatus.hashCode),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    // 🎛️ Bộ lọc (đã bỏ box ngoài)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.filterGuests,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.refineGuestList,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GuestFilters(
                            selectedStatus: _selectedStatus,
                            selectedSort: _selectedSort,
                            onStatusChanged: (v) =>
                                setState(() => _selectedStatus = v ?? 'all'),
                            onSortChanged: (v) =>
                                setState(() => _selectedSort = v ?? 'nameAZ'),
                            statusOptions: _statusOptions,
                            sortOptions: _sortOptions,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔍 Thanh tìm kiếm
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.searchGuests,
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 📋 Danh sách khách
                    GuestList(
                      guests: filteredGuests,
                      visibleCount: _visibleCount,
                      statusResolver: _statusKeyForGuest,
                      statusLabels: _statusOptions,
                      onLoadMore: () => setState(() => _visibleCount += 4),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

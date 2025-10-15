import 'package:flutter/material.dart';
import 'package:appflutter/l10n/app_localizations.dart';

import '../guest_new/guest_add_page.dart';
import '../../../models/guest_model.dart';
import '../../../services/guest_api_service.dart';
import '../../../utils/app_toast.dart';

import './widgets/guest_filters.dart';
import './widgets/guest_header.dart';
import './widgets/guest_list.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  final GuestApiService _api = GuestApiService();
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';
  String _selectedStatus = 'all';
  String _selectedSort = 'nameAZ';
  int _visibleCount = 8;

  List<GuestModel> _guests = [];
  Map<String, String> _statusOptions = const {};
  Map<String, String> _sortOptions = const {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
        _visibleCount = 8;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGuests();
    });
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

  // 🧩 Gọi API lấy danh sách khách
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

  // 🟡 Phân loại trạng thái khách
  String _statusKeyForGuest(GuestModel guest) {
    final hasEmail = guest.hasEmail;
    final hasPhone = guest.hasPhone;

    if (hasEmail && hasPhone) return 'attended';
    if (hasEmail) return 'registered';
    if (hasPhone) return 'preRegistered';
    return 'absent';
  }

  // 🧮 Lọc và sắp xếp danh sách
  List<GuestModel> _applyFilters() {
    final keyword = _searchText.trim().toLowerCase();

    final filtered = _guests.where((guest) {
      final matchesKeyword =
          keyword.isEmpty ||
              guest.fullName.toLowerCase().contains(keyword) ||
              (guest.email ?? '').toLowerCase().contains(keyword) ||
              (guest.phone ?? '').toLowerCase().contains(keyword);

      final guestStatusKey = _statusKeyForGuest(guest);
      final matchesStatus =
          _selectedStatus == 'all' || guestStatusKey == _selectedStatus;

      return matchesKeyword && matchesStatus;
    }).toList();

    switch (_selectedSort) {
      case 'nameZA':
        filtered.sort(
              (a, b) =>
              b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()),
        );
        break;
      case 'newest':
        filtered.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        break;
      case 'oldest':
        filtered.sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });
        break;
      default:
        filtered.sort(
              (a, b) =>
              a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
        );
    }

    return filtered;
  }

  // ➕ Mở trang thêm khách mời
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
      if (_visibleCount < _guests.length) {
        _visibleCount++;
      }
    });

    // ✅ Hiển thị toast an toàn sau khi quay lại
    showAppToast(
      context,
      l10n.guestCreateSuccess,
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final filteredGuests = _applyFilters();

    // 🌀 Loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ❌ Lỗi
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.loadingError(_errorMessage!),
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _fetchGuests, child: Text(l10n.retry)),
          ],
        ),
      );
    }

    // ✅ Hiển thị danh sách khách
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GuestHeader(onAddGuest: _openAddGuest),
          const SizedBox(height: 20),

          // 🔍 Ô tìm kiếm
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchGuests,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: color.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ⚙️ Bộ lọc
          GuestFilters(
            selectedStatus: _selectedStatus,
            selectedSort: _selectedSort,
            onStatusChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedStatus = value;
                _visibleCount = 8;
              });
            },
            onSortChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedSort = value;
              });
            },
            statusOptions: _statusOptions,
            sortOptions: _sortOptions,
          ),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.showingGuestsInLast365Days,
              style: text.bodySmall?.copyWith(
                color: color.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 📋 Danh sách khách
          Expanded(
            child: GuestList(
              guests: filteredGuests,
              visibleCount: _visibleCount,
              statusResolver: _statusKeyForGuest,
              statusLabels: _statusOptions,
              onLoadMore: () => setState(() => _visibleCount += 4),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:appflutter/l10n/app_localizations.dart';
import '../../../../models/guest_model.dart';
import 'guest_item.dart';

class GuestList extends StatelessWidget {
  final List<GuestModel> guests;
  final int visibleCount;
  final String Function(GuestModel) statusResolver;
  final Map<String, String> statusLabels;
  final VoidCallback onLoadMore;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const GuestList({
    super.key,
    required this.guests,
    required this.visibleCount,
    required this.statusResolver,
    required this.statusLabels,
    required this.onLoadMore,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasMore = guests.length > visibleCount;
    final displayCount = hasMore ? visibleCount + 1 : guests.length;

    // 🧩 Nếu danh sách trống — hiển thị trạng thái rỗng tinh tế
    if (guests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_off_rounded,
                  size: 64, color: color.onSurfaceVariant.withOpacity(0.45)),
              const SizedBox(height: 16),
              Text(
                l10n.noGuestsFound,
                style: text.bodyMedium?.copyWith(
                  color: color.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.tryAdjustingFilters,
                style: text.bodySmall?.copyWith(
                  color: color.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 🧱 Danh sách khách mời với animation và “Tải thêm”
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: displayCount,
      shrinkWrap: shrinkWrap,
      physics:
      physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        // 🔽 Load more button cuối danh sách
        if (index == visibleCount && hasMore) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: color.primary,
                  side: BorderSide(color: color.primary, width: 1.2),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onLoadMore,
                icon: const Icon(Icons.expand_more_rounded, size: 22),
                label: Text(
                  l10n.loadMore,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        }

        // 🎨 Hiệu ứng fade + slide nhẹ cho mỗi item
        final guest = guests[index];
        final statusKey = statusResolver(guest);
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 12),
              child: child,
            ),
          ),
          child: GuestItem(
            guest: guest,
            statusKey: statusKey,
            statusLabel: statusLabels[statusKey] ?? '',
            delayMs: (index % visibleCount) * 80,
          ),
        );
      },
    );
  }
}

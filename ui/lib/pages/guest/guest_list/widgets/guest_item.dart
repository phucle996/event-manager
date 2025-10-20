import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:appflutter/l10n/app_localizations.dart';
import '../../../../models/guest_model.dart';

class GuestItem extends StatelessWidget {
  final GuestModel guest;
  final String statusKey;
  final String statusLabel;
  final int delayMs;

  const GuestItem({
    super.key,
    required this.guest,
    required this.statusKey,
    required this.statusLabel,
    required this.delayMs,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _statusColor(statusKey, color);

    // 🧾 Thông tin liên hệ
    final contacts = <String>[
      if (guest.email != null && guest.email!.trim().isNotEmpty)
        guest.email!.trim(),
      if (guest.phone != null &&
          guest.phone!.trim().isNotEmpty &&
          guest.phone!.trim() != guest.email?.trim())
        guest.phone!.trim(),
    ];
    final contactText =
    contacts.isEmpty ? l10n.noGuestContact : contacts.join(' • ');

    // 🗓️ Ngày tạo
    final dateText = guest.createdAt != null
        ? DateFormat('dd/MM').format(guest.createdAt!)
        : '--';

    // ✨ Hiệu ứng xuất hiện mượt
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 16),
          child: child,
        ),
      ),
      child: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: delayMs)),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: color.surface,
              gradient: LinearGradient(
                colors: [
                  color.surfaceContainerHighest.withOpacity(0.95),
                  color.surface.withOpacity(0.98),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: color.shadow.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // 🧍 Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.2),
                        statusColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: statusColor,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 14),

                // 💬 Thông tin chính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest.fullName.isEmpty
                            ? l10n.unknownStatus
                            : guest.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contactText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          color: color.onSurfaceVariant.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 🏷️ Cột phải (badge + ngày)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(statusLabel, statusColor),
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      style: text.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // ⋮ menu icon
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  color: color.onSurfaceVariant.withOpacity(0.8),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String key, ColorScheme scheme) {
    switch (key) {
      case 'attended':
        return const Color(0xFF10B981); // xanh ngọc (success)
      case 'registered':
        return const Color(0xFF3B82F6); // xanh dương (primary)
      case 'preRegistered':
        return const Color(0xFFF59E0B); // cam vàng (warning)
      case 'absent':
        return const Color(0xFFEF4444); // đỏ (error)
      default:
        return scheme.secondary;
    }
  }
}

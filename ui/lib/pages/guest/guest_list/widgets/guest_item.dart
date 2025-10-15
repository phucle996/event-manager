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

    final contacts = <String>[
      if (guest.email != null && guest.email!.trim().isNotEmpty)
        guest.email!.trim(),
      if (guest.phone != null &&
          guest.phone!.trim().isNotEmpty &&
          guest.phone!.trim() != guest.email?.trim())
        guest.phone!.trim(),
    ];
    final contactText = contacts.isEmpty
        ? l10n.noGuestContact
        : contacts.join(' • ');

    final createdAt = guest.createdAt;
    final dateText = createdAt != null
        ? DateFormat('dd/MM').format(createdAt)
        : '--';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 20),
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
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  child: Icon(Icons.person, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest.fullName.isEmpty
                            ? l10n.unknownStatus
                            : guest.fullName,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contactText,
                        style: text.bodySmall?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(statusLabel, statusColor),
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      style: text.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, size: 20),
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
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String key, ColorScheme scheme) {
    switch (key) {
      case 'attended':
        return Colors.green;
      case 'registered':
        return scheme.primary;
      case 'preRegistered':
        return Colors.amber;
      case 'absent':
        return Colors.redAccent;
      default:
        return scheme.secondary;
    }
  }
}

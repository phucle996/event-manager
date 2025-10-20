import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ReportHeaderWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const ReportHeaderWidget({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.outline.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 📊 Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.bar_chart_rounded, color: color.primary, size: 28),
            ),

            const SizedBox(width: 14),

            // 🧭 Title & subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.eventOverview,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.reportOverviewSubtitle,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.onSurfaceVariant.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // 🔄 Refresh button
            IconButton.filledTonal(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRefresh,
              style: IconButton.styleFrom(
                backgroundColor: color.primary.withOpacity(0.15),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

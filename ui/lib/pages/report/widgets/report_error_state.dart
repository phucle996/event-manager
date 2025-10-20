import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/modern_section_card.dart';

class ReportErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ReportErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;

    return ModernSectionCard(
      title: l10n.reportsAndStatistics,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          Text(
            l10n.loadingError(message),
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: Colors.redAccent),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/modern_section_card.dart';
import './event_status_chart.dart';

class ReportStatusChart extends StatelessWidget {
  final Map<String, int> statusCounts;

  const ReportStatusChart({super.key, required this.statusCounts});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ModernSectionCard(
      title: l10n.eventStatusDistribution,
      child: SizedBox(
        height: 240,
        child: EventStatusChart(
          statusCounts: statusCounts,
          emptyLabel: l10n.noEvents,
        ),
      ),
    );
  }
}

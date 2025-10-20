import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/event_type_guest_stat_model.dart';
import '../../../../widgets/modern_section_card.dart';
import './event_type_guest_chart.dart';

class ReportTypeGuestChart extends StatelessWidget {
  final List<EventTypeGuestStatModel> stats;

  const ReportTypeGuestChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ModernSectionCard(
      title: l10n.guestDistributionByEventType,
      child: SizedBox(
        height: 240,
        child: EventTypeGuestChart(
          stats: stats,
          emptyLabel: l10n.noEvents,
        ),
      ),
    );
  }
}

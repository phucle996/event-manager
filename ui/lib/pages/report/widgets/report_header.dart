import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/modern_section_card.dart';
import 'summary_card.dart'; // bạn đã có sẵn SummaryCard
import '../report_page.dart'; // để lấy enum ReportFilter

class ReportHeader extends StatelessWidget {
  final int totalEvents;
  final int totalAttendees;
  final double participationRate;
  final ReportFilter activeFilter;
  final ValueChanged<ReportFilter> onFilterChanged;

  const ReportHeader({
    super.key,
    required this.totalEvents,
    required this.totalAttendees,
    required this.participationRate,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ModernSectionCard(
      title: l10n.eventOverview,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SummaryCard(
              icon: Icons.event,
              label: l10n.totalEvents,
              value: totalEvents.toString(),
              color: Colors.indigo,
              isSelected: activeFilter == ReportFilter.all,
              onTap: () => onFilterChanged(ReportFilter.all),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              icon: Icons.people,
              label: l10n.attendees,
              value: totalAttendees.toString(),
              color: Colors.green,
              isSelected: activeFilter == ReportFilter.attendees,
              onTap: () => onFilterChanged(ReportFilter.attendees),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              icon: Icons.percent_rounded,
              label: l10n.participationPerformance,
              value: '${participationRate.toStringAsFixed(0)}%',
              color: Colors.orange,
              isSelected: activeFilter == ReportFilter.participation,
              onTap: () => onFilterChanged(ReportFilter.participation),
            ),
          ),
        ],
      ),
    );
  }
}

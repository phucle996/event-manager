import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/event_type_guest_stat_model.dart';

class EventTypeGuestChart extends StatelessWidget {
  final List<EventTypeGuestStatModel> stats;
  final String emptyLabel;

  const EventTypeGuestChart({
    super.key,
    required this.stats,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    if (stats.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            emptyLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final totalGuests = stats.fold<int>(0, (sum, s) => sum + s.totalGuests);
    final sections = _buildChartSections(theme, totalGuests);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🟣 Donut chart
          SizedBox(
            height: 200, // smaller to prevent overflow
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 45,
                sectionsSpace: 2,
                startDegreeOffset: -90,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 🏷️ Legend section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: stats.map((stat) {
                final c = _colorForType(stat.eventType);
                final percent = totalGuests > 0
                    ? ((stat.totalGuests / totalGuests) * 100).toStringAsFixed(0)
                    : "0";
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      stat.eventType,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      "  $percent%",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color.primary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 🧮 Build PieChart sections
  List<PieChartSectionData> _buildChartSections(
      ThemeData theme,
      int totalGuests,
      ) {
    return stats.map((stat) {
      final percent =
      totalGuests > 0 ? (stat.totalGuests / totalGuests) * 100 : 0.0;
      return PieChartSectionData(
        color: _colorForType(stat.eventType),
        value: stat.totalGuests.toDouble(),
        title: percent >= 8 ? "${percent.toStringAsFixed(0)}%" : "",
        titleStyle: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        radius: 50,
      );
    }).toList();
  }

  // 🎨 Generate consistent color per event type
  Color _colorForType(String typeName) {
    final random = Random(typeName.hashCode);
    return HSLColor.fromAHSL(
      1.0,
      random.nextDouble() * 360,
      0.55 + random.nextDouble() * 0.15,
      0.60 + random.nextDouble() * 0.10,
    ).toColor();
  }
}

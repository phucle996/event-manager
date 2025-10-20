import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EventStatusChart extends StatelessWidget {
  final Map<String, int> statusCounts;
  final String emptyLabel;

  const EventStatusChart({
    super.key,
    required this.statusCounts,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    if (statusCounts.isEmpty ||
        statusCounts.values.every((count) => count == 0)) {
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

    final total = statusCounts.values.fold<int>(0, (sum, v) => sum + v);
    final sections = _buildChartSections(theme, total);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🥧 Biểu đồ
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 48,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
              startDegreeOffset: -90,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 🏷️ Chú thích (Legend)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: statusCounts.entries.map((entry) {
            final colorFor = _colorForStatus(entry.key);
            final percent = total > 0
                ? ((entry.value / total) * 100).toStringAsFixed(0)
                : "0";
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: colorFor,
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  "${entry.key} (${entry.value})",
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
      ],
    );
  }

  List<PieChartSectionData> _buildChartSections(ThemeData theme, int total) {
    final entries = statusCounts.entries.toList();
    return entries.map((entry) {
      final value = entry.value;
      final percent = total > 0 ? (value / total) * 100 : 0;
      final color = _colorForStatus(entry.key);

      return PieChartSectionData(
        color: color,
        value: value.toDouble(),
        title: percent >= 10 ? "${percent.toStringAsFixed(0)}%" : "",
        titleStyle: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        radius: 55,
      );
    }).toList();
  }

  Color _colorForStatus(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('upcoming') || lower.contains('sắp')) {
      return const Color(0xFF3B82F6); // Xanh lam
    } else if (lower.contains('ongoing') || lower.contains('đang')) {
      return const Color(0xFF10B981); // Xanh lá
    } else if (lower.contains('completed') || lower.contains('kết')) {
      return const Color(0xFF9CA3AF); // Xám
    } else {
      return const Color(0xFFF59E0B); // Cam fallback
    }
  }
}

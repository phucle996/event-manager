import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyEventChart extends StatelessWidget {
  final List<String> labels;
  final List<int> values;
  final String emptyLabel;
  final Color? barColor;

  const MonthlyEventChart({
    super.key,
    required this.labels,
    required this.values,
    this.emptyLabel = 'No data',
    this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty || labels.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final color = barColor ?? Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final maxY = (values.reduce((a, b) => a > b ? a : b).toDouble() + 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.grey, width: 1),
              left: BorderSide(color: Colors.grey, width: 1),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 30,
                getTitlesWidget: (value, _) {
                  if (value % 1 == 0) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: 11, color: textColor),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    return Text(
                      labels[index],
                      style: TextStyle(fontSize: 11, color: textColor),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barGroups: List.generate(
            values.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index].toDouble(),
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  width: 14,
                ),
              ],
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black.withOpacity(0.75),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = groupIndex >= 0 && groupIndex < labels.length
                    ? labels[groupIndex]
                    : 'N/A';
                return BarTooltipItem(
                  '$label\n${rod.toY.toInt()} ${rod.toY.toInt() == 1 ? 'event' : 'events'}',
                  const TextStyle(color: Colors.white, fontSize: 11),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

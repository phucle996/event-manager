import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MonthlyEventChart extends StatelessWidget {
  final List<String> labels; // ['01/25', '02/25', ...] hoặc ['2025-01', ...]
  final List<int> values;
  final String emptyLabel;

  const MonthlyEventChart({
    super.key,
    required this.labels,
    required this.values,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    // 🧩 Chuẩn hoá nhãn chỉ lấy tháng (MM)
    List<String> normalizedLabels = labels.map((l) {
      try {
        if (l.contains('/')) {
          return DateFormat('MM').format(DateFormat('MM/yy').parse(l));
        } else if (l.contains('-')) {
          return DateFormat('MM').format(DateFormat('yyyy-MM').parse(l));
        } else {
          return l.padLeft(2, '0').substring(0, 2);
        }
      } catch (_) {
        return l.length >= 2 ? l.substring(0, 2) : l;
      }
    }).toList();

    // 🗓️ Tạo danh sách 12 tháng gần nhất (chỉ hiển thị MM)
    final now = DateTime.now();
    final recentMonths = List.generate(12, (i) {
      final d = DateTime(now.year, now.month - (11 - i));
      return DateFormat('MM').format(d);
    });

    // Gắn giá trị đúng tháng
    final filledLabels = recentMonths;
    final filledValues = List<int>.generate(12, (i) {
      final label = filledLabels[i];
      final index = normalizedLabels.indexOf(label);
      return (index != -1 && index < values.length) ? values[index] : 0;
    });

    // Không có dữ liệu
    if (filledValues.every((v) => v == 0)) {
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

    final maxValue = filledValues.reduce((a, b) => a > b ? a : b).toDouble();
    final double maxY = maxValue == 0 ? 1.0 : maxValue * 1.3;

    // 📊 Biểu đồ cột 12 tháng gần nhất
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= filledLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      filledLabels[index],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(filledValues.length, (index) {
            final value = filledValues[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value.toDouble(),
                  borderRadius: BorderRadius.circular(6),
                  width: 14,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      color.primary.withOpacity(0.3),
                      color.primary.withOpacity(0.8),
                    ],
                  ),
                ),
              ],
            );
          }),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final month = filledLabels[group.x.toInt()];
                final displayMonth = int.parse(month);
                return BarTooltipItem(
                  'Tháng $displayMonth\n',
                  theme.textTheme.labelLarge!.copyWith(
                    color: color.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toInt()} sự kiện',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

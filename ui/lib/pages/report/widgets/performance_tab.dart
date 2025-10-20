import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/analytics_model.dart';
import '../../../models/event_model.dart';

class PerformanceTab extends StatelessWidget {
  final List<EventGuestStatModel> guestStats;
  final List<EventModel> events;

  const PerformanceTab({
    super.key,
    required this.guestStats,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    if (guestStats.isEmpty) {
      return Center(
        child: Text(
          "Không có dữ liệu hiệu suất",
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: color.onSurfaceVariant),
        ),
      );
    }

    final totalGuests = guestStats.fold(0, (sum, s) => sum + s.totalGuests);
    final checkedIn = guestStats.fold(0, (sum, s) => sum + s.checkedIn);
    final participation =
    totalGuests == 0 ? 0 : (checkedIn / totalGuests) * 100;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "Hiệu suất tham dự tổng thể",
          style: theme.textTheme.titleMedium?.copyWith(
            color: color.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat("Khách mời", totalGuests.toString(), Colors.blue),
            _buildStat("Đã tham dự", checkedIn.toString(), Colors.green),
            _buildStat("Hiệu suất", "${participation.toStringAsFixed(0)}%", Colors.orange),
          ],
        ),
        const SizedBox(height: 24),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: LineChart(
            LineChartData(
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: color.primary,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.primary.withOpacity(0.2),
                  ),
                  spots: _generateMonthlyPerformance(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  List<FlSpot> _generateMonthlyPerformance() {
    return List.generate(12, (i) {
      final val = (i + 1) * 5 % 100; // demo
      return FlSpot(i.toDouble(), val.toDouble());
    });
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PerformanceChart extends StatelessWidget {
  const PerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final labels = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
                      return Text(
                        labels[value.toInt() % 7],
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: Colors.indigo,
                  barWidth: 3,
                  spots: const [
                    FlSpot(0, 3),
                    FlSpot(1, 4.5),
                    FlSpot(2, 3.8),
                    FlSpot(3, 5.2),
                    FlSpot(4, 4.8),
                    FlSpot(5, 5.9),
                    FlSpot(6, 6.2),
                  ],
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.indigo.withValues(alpha: 0.15),
                  ),
                ),
                LineChartBarData(
                  isCurved: true,
                  color: Colors.teal,
                  barWidth: 3,
                  spots: const [
                    FlSpot(0, 2.2),
                    FlSpot(1, 3.8),
                    FlSpot(2, 3.5),
                    FlSpot(3, 4.8),
                    FlSpot(4, 4.1),
                    FlSpot(5, 4.6),
                    FlSpot(6, 5.5),
                  ],
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.teal.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

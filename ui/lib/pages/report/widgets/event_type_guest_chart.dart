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

  Color _getColor(String eventType) {
    final normalized = _normalize(eventType);
    if (_containsAny(normalized, const ['su kien mo', 'open event'])) {
      return Colors.blue; // Changed from indigo to blue
    }
    if (_containsAny(normalized, const ['su kien gioi han', 'limited event'])) {
      return Colors.orange;
    }
    if (_containsAny(normalized, const ['su kien rieng tu', 'private event'])) {
      return Colors.purple;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Center(child: Text(emptyLabel));
    }

    final total = stats.fold<int>(0, (sum, e) => sum + e.totalGuests);
    if (total == 0) {
      return Center(child: Text(emptyLabel));
    }

    final sections = stats.map((stat) {
      final percent = stat.totalGuests / total * 100;
      return PieChartSectionData(
        value: stat.totalGuests.toDouble(),
        color: _getColor(stat.eventType),
        title: '${percent.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        radius: 60,
      );
    }).toList();

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16, // Increased spacing for better layout
          runSpacing: 8,
          children: stats.map((stat) {
            final color = _getColor(stat.eventType);
            return _legend(stat.eventType, color, stat.totalGuests);
          }).toList(),
        ),
      ],
    );
  }

  // Custom legend widget to match EventStatusChart
  Widget _legend(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4), // Use rounded square
          ),
        ),
        const SizedBox(width: 6),
        Text('$label ($count)', style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  bool _containsAny(String source, List<String> targets) {
    for (final target in targets) {
      if (source.contains(target)) {
        return true;
      }
    }
    return false;
  }

  String _normalize(String value) {
    var result = value.toLowerCase();
    const replacements = {
      '\u0111': 'd',
      '\u00e1': 'a',
      '\u00e0': 'a',
      '\u1ea3': 'a',
      '\u00e3': 'a',
      '\u1ea1': 'a',
      '\u0103': 'a',
      '\u1eaf': 'a',
      '\u1eb1': 'a',
      '\u1eb3': 'a',
      '\u1eb5': 'a',
      '\u1eb7': 'a',
      '\u00e2': 'a',
      '\u1ea5': 'a',
      '\u1ea7': 'a',
      '\u1ea9': 'a',
      '\u1eab': 'a',
      '\u1ead': 'a',
      '\u00e9': 'e',
      '\u00e8': 'e',
      '\u1ebb': 'e',
      '\u1ebd': 'e',
      '\u1eb9': 'e',
      '\u00ea': 'e',
      '\u1ebf': 'e',
      '\u1ec1': 'e',
      '\u1ec3': 'e',
      '\u1ec5': 'e',
      '\u1ec7': 'e',
      '\u00ed': 'i',
      '\u00ec': 'i',
      '\u1ec9': 'i',
      '\u0129': 'i',
      '\u1ecb': 'i',
      '\u00f3': 'o',
      '\u00f2': 'o',
      '\u1ecf': 'o',
      '\u00f5': 'o',
      '\u1ecd': 'o',
      '\u00f4': 'o',
      '\u1ed1': 'o',
      '\u1ed3': 'o',
      '\u1ed5': 'o',
      '\u1ed7': 'o',
      '\u1ed9': 'o',
      '\u01a1': 'o',
      '\u1edb': 'o',
      '\u1edd': 'o',
      '\u1edf': 'o',
      '\u1ee1': 'o',
      '\u1ee3': 'o',
      '\u00fa': 'u',
      '\u00f9': 'u',
      '\u1ee7': 'u',
      '\u0169': 'u',
      '\u1ee5': 'u',
      '\u01b0': 'u',
      '\u1ee9': 'u',
      '\u1eeb': 'u',
      '\u1eed': 'u',
      '\u1eef': 'u',
      '\u1ef1': 'u',
      '\u00fd': 'y',
      '\u1ef3': 'y',
      '\u1ef7': 'y',
      '\u1ef9': 'y',
      '\u1ef5': 'y',
    };

    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }
}

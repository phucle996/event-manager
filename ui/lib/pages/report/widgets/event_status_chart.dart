import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EventStatusChart extends StatelessWidget {
  final Map<String, int> statusCounts;
  final String emptyLabel;
  final ValueChanged<(String, Color)>? onStatusSelected;

  const EventStatusChart({
    super.key,
    required this.statusCounts,
    this.emptyLabel = 'No data',
    this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = statusCounts.values.fold<int>(0, (sum, value) => sum + value);

    if (total == 0) {
      return Center(
        child: Text(
          emptyLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final entries = statusCounts.entries
        .where((entry) => entry.value > 0)
        .toList(growable: false);

    final sections = entries.map((entry) {
      final percent = entry.value / total * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: _colorForStatus(entry.key, theme),
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
          spacing: 12,
          runSpacing: 8,
          children: entries.map((entry) {
            final color = _colorForStatus(entry.key, theme);
            return _legend(entry.key, color, entry.value);
          }).toList(),
        ),
      ],
    );
  }

  Color _colorForStatus(String label, ThemeData theme) {
    final normalized = _normalize(label);
    if (_containsAny(normalized, const ['sap dien ra', 'upcoming'])) {
      return Colors.indigo;
    }
    if (_containsAny(normalized, const ['dang dien ra', 'ongoing'])) {
      return Colors.green;
    }
    if (_containsAny(normalized, const ['da ket thuc', 'completed'])) {
      return Colors.grey;
    }
    // For non-status labels (e.g., event types), pick a distinct color
    final palette = <Color>[
      Colors.blue,
      Colors.teal,
      Colors.deepOrange,
      Colors.purple,
      Colors.amber.shade700,
      Colors.cyan,
      Colors.pinkAccent,
      Colors.brown,
      Colors.lightGreen,
      Colors.indigoAccent,
    ];
    final index = label.hashCode.abs() % palette.length;
    return palette[index];
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

  Widget _legend(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text('$label ($count)', style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

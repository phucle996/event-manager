import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widgets/modern_section_card.dart';

class StatsOverview extends StatelessWidget {
  const StatsOverview({
    super.key,
    required this.totalEvents,
    required this.totalGuests,
    required this.totalCheckedIn,
  });

  final int totalEvents;
  final int totalGuests;
  final int totalCheckedIn;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final formatter = NumberFormat.decimalPattern();

    return ModernSectionCard(
      title: 'Thống kê tổng quan',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatBox(
            label: 'Sự kiện',
            value: formatter.format(totalEvents),
            icon: Icons.event,
            color: color.primary,
          ),
          _StatBox(
            label: 'Khách mời',
            value: formatter.format(totalGuests),
            icon: Icons.people,
            color: color.secondary,
          ),
          _StatBox(
            label: 'Đã check-in',
            value: formatter.format(totalCheckedIn),
            icon: Icons.emoji_people,
            color: color.tertiary,
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

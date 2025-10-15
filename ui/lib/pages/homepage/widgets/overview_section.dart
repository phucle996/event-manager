import 'package:appflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final appLocalizations = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(appLocalizations.events, "12", Icons.event_available, color),
        _buildStatCard(appLocalizations.guests, "230", Icons.people, color),
        _buildStatCard(appLocalizations.registered, "180", Icons.check_circle, color),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    ColorScheme color,
  ) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: color.primary, size: 22),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color.onSurface,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: color.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

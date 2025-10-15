import 'package:appflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final String userName;
  final String date;

  const HeaderSection({super.key, required this.userName, required this.date});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final appLocalizations = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.helloUser(userName),
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              appLocalizations.todayIs(date),
              style: text.bodySmall?.copyWith(color: color.onSurfaceVariant),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage('assets/profile.png'),
        ),
      ],
    );
  }
}

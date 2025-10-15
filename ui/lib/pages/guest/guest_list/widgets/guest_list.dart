import 'package:flutter/material.dart';
import 'package:appflutter/l10n/app_localizations.dart';
import '../../../../models/guest_model.dart';
import 'guest_item.dart';

class GuestList extends StatelessWidget {
  final List<GuestModel> guests;
  final int visibleCount;
  final String Function(GuestModel) statusResolver;
  final Map<String, String> statusLabels;
  final VoidCallback onLoadMore;

  const GuestList({
    super.key,
    required this.guests,
    required this.visibleCount,
    required this.statusResolver,
    required this.statusLabels,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasMore = guests.length > visibleCount;
    final displayCount = hasMore ? visibleCount + 1 : guests.length;

    if (guests.isEmpty) {
      return Center(
        child: Text(
          l10n.noGuestsFound,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        if (index == visibleCount && hasMore) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: onLoadMore,
                child: Text(l10n.loadMore),
              ),
            ),
          );
        }
        final guest = guests[index];
        final statusKey = statusResolver(guest);
        return GuestItem(
          guest: guest,
          statusKey: statusKey,
          statusLabel: statusLabels[statusKey] ?? '',
          delayMs: (index % visibleCount) * 100, 
        );
      },
    );
  }
}

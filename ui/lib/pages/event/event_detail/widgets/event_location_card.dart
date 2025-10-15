import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../utils/app_toast.dart';

class EventLocationCard extends StatelessWidget {
  final String? location;

  const EventLocationCard({super.key, this.location});

  void _showLocationActions(BuildContext context) {
    if (location == null || location!.trim().isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.copy_all_rounded),
                title: Text(l10n.copyAddress),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: location!));
                  Navigator.pop(ctx);
                  showAppToast(context, l10n.addressCopied);
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_rounded),
                title: Text(l10n.openInGoogleMaps),
                onTap: () async {
                  final query = Uri.encodeComponent(location!);
                  final url =
                      Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

                  Navigator.pop(ctx);

                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    showAppToast(context, l10n.couldNotOpenMaps,
                        type: ToastType.error);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.venue,
          style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLocationActions(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.place, color: color.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      location ?? l10n.noSpecificLocation,
                      style: text.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

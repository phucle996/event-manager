import 'package:appflutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // TODO: Lấy và lưu các giá trị này vào SharedPreferences hoặc state manager
  bool _newEventNotifications = true;
  bool _eventReminders = true;
  bool _systemUpdates = false;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.notificationSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text(appLocalizations.newEventNotifications),
            subtitle: Text(appLocalizations.newEventNotificationsSubtitle),
            value: _newEventNotifications,
            onChanged: (bool value) {
              setState(() {
                _newEventNotifications = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text(appLocalizations.eventReminders),
            subtitle: Text(appLocalizations.eventRemindersSubtitle),
            value: _eventReminders,
            onChanged: (bool value) {
              setState(() {
                _eventReminders = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text(appLocalizations.systemUpdates),
            subtitle: Text(appLocalizations.systemUpdatesSubtitle),
            value: _systemUpdates,
            onChanged: (bool value) {
              setState(() {
                _systemUpdates = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

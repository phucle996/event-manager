import 'package:appflutter/l10n/app_localizations.dart';
import 'package:appflutter/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/login_page.dart';
import '../../utils/app_toast.dart';
import './change_password_page.dart';
import './notification_settings_page.dart';
import './language_theme_page.dart';

import 'widgets/profile_header.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_menu_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _navigateToChangePassword(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
  }

  void _navigateToNotificationSettings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationSettingsPage()));
  }

  void _navigateToLanguageTheme(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LanguageThemePage()));
  }

  void _showAppInfo(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: appLocalizations.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.event_available_rounded, size: 48),
      children: [Text(appLocalizations.internalEventManager)],
    );
  }

  void _openSupportPage(BuildContext context) async {
    final appLocalizations = AppLocalizations.of(context)!;
    final url = Uri.parse('https://github.com/your-repo/support');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      showAppToast(context, appLocalizations.couldNotOpenSupportPage, type: ToastType.error);
    }
  }

  void _logout(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    context.read<AuthProvider>().logout();
    showAppToast(context, appLocalizations.loggedOutSuccessfully, type: ToastType.info);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      body: authProvider.isLoggedIn
          ? SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildLoggedInView(context))
          : Center(child: Padding(padding: const EdgeInsets.all(24.0), child: _buildGuestView(context))),
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final appLocalizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        ProfileHeader(
          name: "Phúc Lê", // This should probably be from a user object
          email: "phuc.le@example.com",
          avatarUrl: null,
          role: appLocalizations.systemAdministrator,
        ),
        const SizedBox(height: 20),
        ProfileInfoCard(
          title: appLocalizations.basicInformation,
          children: [
            _infoRow(appLocalizations.employeeId, "EMP-001"),
            _infoRow(appLocalizations.department, "Quản lý sự kiện"), // This seems to be dynamic data
            _infoRow(appLocalizations.joinDate, "15/08/2023"),
          ],
        ),
        const SizedBox(height: 20),
        ProfileMenuSection(
          title: appLocalizations.account,
          items: [
            _menuItem(Icons.lock_outline, appLocalizations.changePassword, () => _navigateToChangePassword(context)),
            _menuItem(Icons.notifications_outlined, appLocalizations.notificationSettings, () => _navigateToNotificationSettings(context)),
            _menuItem(Icons.language_outlined, appLocalizations.languageAndTheme, () => _navigateToLanguageTheme(context)),
          ],
        ),
        const SizedBox(height: 20),
        ProfileMenuSection(
          title: appLocalizations.other,
          items: [
            _menuItem(Icons.help_outline, appLocalizations.helpAndSupport, () => _openSupportPage(context)),
            _menuItem(Icons.info_outline, appLocalizations.aboutApp, () => _showAppInfo(context)),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _logout(context),
          style: FilledButton.styleFrom(backgroundColor: color.errorContainer, foregroundColor: color.onErrorContainer),
          icon: const Icon(Icons.logout),
          label: Text(appLocalizations.logout),
        ),
      ],
    );
  }

  Widget _buildGuestView(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(radius: 50, child: Icon(Icons.person_outline, size: 50)),
        const SizedBox(height: 16),
        Text(appLocalizations.guest, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(appLocalizations.pleaseLoginToUseFeatures, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginPage()));
          },
          child: Text(appLocalizations.loginOrRegister),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Map<String, dynamic> _menuItem(IconData icon, String title, VoidCallback onTap) {
    return {"icon": icon, "title": title, "onTap": onTap};
  }
}

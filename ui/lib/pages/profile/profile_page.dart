import 'package:appflutter/l10n/app_localizations.dart';
import 'package:appflutter/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/login_page.dart';
import '../../utils/app_toast.dart';
import '../../widgets/app_page_background.dart';
import '../../widgets/modern_section_card.dart';
import './change_password_page.dart';
import './notification_settings_page.dart';
import './language_theme_page.dart';

import 'widgets/profile_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _navigateToChangePassword(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
  }

  void _navigateToNotificationSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NotificationSettingsPage()));
  }

  void _navigateToLanguageTheme(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LanguageThemePage()));
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
      showAppToast(
        context,
        appLocalizations.couldNotOpenSupportPage,
        type: ToastType.error,
      );
    }
  }

  void _logout(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    context.read<AuthProvider>().logout();
    showAppToast(
      context,
      appLocalizations.loggedOutSuccessfully,
      type: ToastType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    return AppPageBackground(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: isLoggedIn
            ? _buildLoggedInView(context)
            : _buildGuestView(context),
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final appLocalizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModernSectionCard(
            title: appLocalizations.profile,
            child: ProfileHeader(
              name: "Phúc Lê",
              email: "phuc.le@example.com",
              avatarUrl: null,
              role: appLocalizations.systemAdministrator,
            ),
          ),
          ModernSectionCard(
            title: appLocalizations.basicInformation,
            child: Column(
              children: [
                _infoRow(appLocalizations.employeeId, "EMP-001"),
                const Divider(height: 24),
                _infoRow(appLocalizations.department, "Quản lý sự kiện"),
                const Divider(height: 24),
                _infoRow(appLocalizations.joinDate, "15/08/2023"),
              ],
            ),
          ),
          ModernSectionCard(
            title: appLocalizations.account,
            child: Column(
              children: [
                _menuTile(
                  context,
                  icon: Icons.lock_outline,
                  label: appLocalizations.changePassword,
                  onTap: () => _navigateToChangePassword(context),
                ),
                _menuTile(
                  context,
                  icon: Icons.notifications_outlined,
                  label: appLocalizations.notificationSettings,
                  onTap: () => _navigateToNotificationSettings(context),
                ),
                _menuTile(
                  context,
                  icon: Icons.language_outlined,
                  label: appLocalizations.languageAndTheme,
                  onTap: () => _navigateToLanguageTheme(context),
                ),
              ],
            ),
          ),
          ModernSectionCard(
            title: appLocalizations.other,
            child: Column(
              children: [
                _menuTile(
                  context,
                  icon: Icons.help_outline,
                  label: appLocalizations.helpAndSupport,
                  onTap: () => _openSupportPage(context),
                ),
                _menuTile(
                  context,
                  icon: Icons.info_outline,
                  label: appLocalizations.aboutApp,
                  onTap: () => _showAppInfo(context),
                ),
              ],
            ),
          ),
          ModernSectionCard(
            child: FilledButton.icon(
              onPressed: () => _logout(context),
              style: FilledButton.styleFrom(
                backgroundColor: color.errorContainer,
                foregroundColor: color.onErrorContainer,
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: const Icon(Icons.logout),
              label: Text(appLocalizations.logout),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    final theme = Theme.of(context);
    final appLocalizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 420,
          child: ModernSectionCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person_outline, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  appLocalizations.guest,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  appLocalizations.pleaseLoginToUseFeatures,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: Text(appLocalizations.loginOrRegister),
                ),
              ],
            ),
          ),
        ),
      ),
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

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final color = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: color.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

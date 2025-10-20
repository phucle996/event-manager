// ignore_for_file: deprecated_member_use

import 'package:appflutter/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appflutter/l10n/app_localizations.dart';

enum AppTheme { light, dark, system }

class LanguageThemePage extends StatefulWidget {
  const LanguageThemePage({super.key});

  @override
  State<LanguageThemePage> createState() => _LanguageThemePageState();
}

class _LanguageThemePageState extends State<LanguageThemePage> {
  AppTheme _selectedTheme = AppTheme.system;

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.languageAndTheme),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            AppLocalizations.of(context)!.theme,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          RadioListTile<AppTheme>(
            title: Text(AppLocalizations.of(context)!.light),
            value: AppTheme.light,
            groupValue: _selectedTheme,
            onChanged: (AppTheme? value) {
              setState(() => _selectedTheme = value!);
            },
          ),
          RadioListTile<AppTheme>(
            title: Text(AppLocalizations.of(context)!.dark),
            value: AppTheme.dark,
            groupValue: _selectedTheme,
            onChanged: (AppTheme? value) {
              setState(() => _selectedTheme = value!);
            },
          ),
          RadioListTile<AppTheme>(
            title: Text(AppLocalizations.of(context)!.system),
            value: AppTheme.system,
            groupValue: _selectedTheme,
            onChanged: (AppTheme? value) {
              setState(() => _selectedTheme = value!);
            },
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.language,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          RadioListTile<Locale>(
            title: const Text('Tiếng Việt'),
            value: const Locale('vi'),
            groupValue: localeProvider.locale,
            onChanged: (Locale? value) {
              context.read<LocaleProvider>().setLocale(value!);
            },
          ),
          RadioListTile<Locale>(
            title: const Text('English'),
            value: const Locale('en'),
            groupValue: localeProvider.locale,
            onChanged: (Locale? value) {
              context.read<LocaleProvider>().setLocale(value!);
            },
          ),
        ],
      ),
    );
  }
}

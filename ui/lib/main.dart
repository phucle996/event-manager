import 'package:appflutter/pages/app.dart';
import 'package:appflutter/providers/auth_provider.dart';
import 'package:appflutter/providers/locale_provider.dart';
import 'package:appflutter/providers/connectivity_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);

  final prefs = await SharedPreferences.getInstance();
  final localeProvider = LocaleProvider(prefs);
  final authProvider = AuthProvider(prefs);
  final connectivityProvider = ConnectivityProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: connectivityProvider),
      ],
      child: EventApp(),
    ),
  );
}

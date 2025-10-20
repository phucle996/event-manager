import 'package:appflutter/l10n/app_localizations.dart';
import 'package:appflutter/pages/auth/login_page.dart';
import 'package:appflutter/pages/event/event_list/event_list_page.dart';
import 'package:appflutter/pages/guest/guest_list/guest_page.dart';
import 'package:appflutter/pages/homepage/home_page.dart';
import 'package:appflutter/pages/profile/profile_page.dart';
import 'package:appflutter/pages/report/report_page.dart';
import 'package:appflutter/providers/auth_provider.dart';
import 'package:appflutter/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/bottom_nav_bar.dart';

class EventApp extends StatefulWidget {
  const EventApp({super.key});

  @override
  State<EventApp> createState() => _EventAppState();
}

class _EventAppState extends State<EventApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // 🌞 Light Theme
    final lightColorScheme = const ColorScheme.light(
      primary: Color(0xFF32B768),
      secondary: Color(0xFF4ADE80),
      background: Color(0xFFF3F6FB),
      surface: Colors.white,
      surfaceVariant: Color(0xFFE9ECF2),
      onBackground: Color(0xFF0D1B35),
      onSurface: Color(0xFF0D1B35),
      onSurfaceVariant: Color(0xFF6F7A8A),
      error: Color(0xFFD32F2F),
    );

    // 🌙 Dark Theme
    final darkColorScheme = const ColorScheme.dark(
      primary: Color(0xFF32B768),
      secondary: Color(0xFF82C91E),
      background: Color(0xFF0D1117),
      surface: Color(0xFF161B22),
      surfaceVariant: Color(0xFF21262D),
      onBackground: Colors.white,
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFF9BA3AF),
      error: Color(0xFFEF5350),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: context.watch<LocaleProvider>().locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: _themeMode,

      // ✅ LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: lightColorScheme.background,
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.surface,
          elevation: 0,
          iconTheme: IconThemeData(color: lightColorScheme.onSurface),
          titleTextStyle: TextStyle(
            color: lightColorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardColor: lightColorScheme.surface,
      ),

      // ✅ DARK THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: darkColorScheme.background,
        appBarTheme: AppBarTheme(
          backgroundColor: darkColorScheme.surface,
          elevation: 0,
          iconTheme: IconThemeData(color: darkColorScheme.onSurface),
          titleTextStyle: TextStyle(
            color: darkColorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardColor: darkColorScheme.surface,
      ),

      // ✅ HOME LOGIC
      home: authProvider.isLoggedIn
          ? MainApp(themeMode: _themeMode, setThemeMode: _setThemeMode)
          : const LoginPage(),
    );
  }
}

class MainApp extends StatefulWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) setThemeMode;

  const MainApp({
    super.key,
    required this.themeMode,
    required this.setThemeMode,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 2;

  final List<Widget> _pages = const [
    HomePage(),
    GuestPage(),
    EventListPage(),
    ReportPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        widget.themeMode == ThemeMode.dark ||
            (widget.themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

    return BottomNavBar(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      child: _pages[_selectedIndex],
      appBarBuilder: (context) => AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              widget.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
    );
  }
}

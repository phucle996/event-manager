import 'package:appflutter/pages/auth/login_page.dart';
import 'package:appflutter/pages/event/event_list/event_list_page.dart';
import 'package:appflutter/pages/guest/guest_list/guest_page.dart';
import 'package:appflutter/pages/homepage/home_page.dart';
import 'package:appflutter/pages/profile/profile_page.dart';
import 'package:appflutter/pages/report/report_page.dart';
import 'package:appflutter/providers/auth_provider.dart';
import 'package:appflutter/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:appflutter/l10n/app_localizations.dart';
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
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: context.watch<LocaleProvider>().locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Subtle off-white
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      home: authProvider.isLoggedIn
          ? MainApp(
              themeMode: _themeMode,
              setThemeMode: _setThemeMode,
            )
          : LoginPage(),
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
    final isDark = widget.themeMode == ThemeMode.dark ||
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
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
    );
  }
}

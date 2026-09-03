import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app/theme.dart';
import '/app/route.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; 

void main() {
  usePathUrlStrategy();
  runApp(const RallyRedApp());
}

class RallyRedApp extends StatefulWidget {
  const RallyRedApp({super.key});

  static _RallyRedAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_RallyRedAppState>()!;

  @override
  State<RallyRedApp> createState() => _RallyRedAppState();
}

class _RallyRedAppState extends State<RallyRedApp> {
  ThemeMode themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      themeMode =
          themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  late final GoRouter _router = AppRouter.createRouter(onThemeToggle: toggleTheme);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'RallyRed',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
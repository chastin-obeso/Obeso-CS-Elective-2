import 'package:flutter/material.dart';
import 'appbar.dart';
import 'app/theme.dart';
void main() {
  // Disable debug banner
  runApp(
    
    const RallyRedApp()
    );
}

class RallyRedApp extends StatefulWidget {
  const RallyRedApp({super.key});

  @override
  State<RallyRedApp> createState() => _RallyRedAppState();
}

class _RallyRedAppState extends State<RallyRedApp> {
  // 1. Theme state variable
  ThemeMode _themeMode = ThemeMode.light;

  // 2. Toggle function
  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RallyRed',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode, // Controlled by state
      home: Scaffold(
        appBar: CustomAppBar(
          title: 'RallyRed',
          onThemeToggle: _toggleTheme, // <--- Pass function here directly
        ),
        body: const Center(
          child: Text('Welcome to RallyRed!'),
        ),
      ),
    );
  }
}

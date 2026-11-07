import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app/theme.dart';
import 'app/route.dart';
import 'providers/cart_provider.dart';
import 'package:go_router/go_router.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const ProviderScope(child: RallyRedApp()));
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

  final CartModel _cartModel = CartModel();
  late final GoRouter _router = AppRouter.createRouter(
    onThemeToggle: toggleTheme,
    cartModel: _cartModel,
  );

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
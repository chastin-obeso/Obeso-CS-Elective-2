import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/route.dart';
import 'theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? 'https://jeinztdovrfudthtajgo.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: RallyRedApp(),
    ),
  );
}

class RallyRedApp extends ConsumerStatefulWidget {
  const RallyRedApp({super.key});

  static RallyRedAppState of(BuildContext context) {
    final state = context.findAncestorStateOfType<RallyRedAppState>();
    assert(state != null, 'No RallyRedAppState found in context');
    return state!;
  }

  @override
  ConsumerState<RallyRedApp> createState() => RallyRedAppState();
}

class RallyRedAppState extends ConsumerState<RallyRedApp> {
  ThemeMode _themeMode = ThemeMode.system;
  GoRouter? _router;

  void toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _router ??= AppRouter.createRouter(
      onThemeToggle: toggleTheme,
    );

    return MaterialApp.router(
      title: 'RallyRed',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
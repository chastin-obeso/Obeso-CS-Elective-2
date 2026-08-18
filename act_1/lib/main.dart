import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 1. DEFINE YOUR ROUTES
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DialingScreen(),
    ),
    // Dynamic route that handles any fruit name passed in the URL path
    GoRoute(
      path: '/fruit/:name',
      builder: (context, state) {
        final fruitName = state.pathParameters['name'] ?? 'Unknown';
        return FruitDetailScreen(fruitName: fruitName);
      },
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. INITIALIZE GO_ROUTER IN YOUR MATERIALAPP
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class DialingScreen extends StatelessWidget {
  const DialingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Fruits",
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              
              // Apple Button -> navigates to /fruit/Apple
              ElevatedButton(
                onPressed: () => context.go('/fruit/Apple'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Apple", style: TextStyle(fontSize: 30, color: Colors.white)),
              ),
              const SizedBox(height: 15),
              
              // Banana Button -> navigates to /fruit/Banana
              ElevatedButton(
                onPressed: () => context.go('/fruit/Banana'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                child: const Text("Banana", style: TextStyle(fontSize: 30, color: Colors.black)),
              ),
              const SizedBox(height: 15),
              
              // Cherry Button -> navigates to /fruit/Cherry
              ElevatedButton(
                onPressed: () => context.go('/fruit/Cherry'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                child: const Text("Cherry", style: TextStyle(fontSize: 30, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3. TARGET FRUIT DETAIL DISPLAY PAGE
class FruitDetailScreen extends StatelessWidget {
  final String fruitName;
  const FruitDetailScreen({super.key, required this.fruitName});

  // Helper method to retrieve the correct visual asset based on route parameter
  String _getFruitImage(String name) {
    switch (name.toLowerCase()) {
      case 'apple': return '🍎';
      case 'banana': return '🍌';
      case 'cherry': return '🍒';
      default: return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fruitName),
        // go_router natively integrates back buttons, but you can explicitly use context.pop()
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getFruitImage(fruitName),
              style: const TextStyle(fontSize: 120), // Large high-fidelity visual graphic
            ),
            const SizedBox(height: 20),
            Text(
              "This is a fresh $fruitName!",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

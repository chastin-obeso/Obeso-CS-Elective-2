import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/herobanner.dart';
import '/productlist.dart';
import '/appbar.dart';

class AppRouter {
  // 1. Pass the callback into a method that returns the configured GoRouter instance
  static GoRouter createRouter({required VoidCallback onThemeToggle}) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => HomeScreen(onThemeToggle: onThemeToggle),
        ),
        GoRoute(
          path: '/product/:id',
          name: 'productDetail',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '0';
            return ProductDetailScreen(productId: productId, onThemeToggle: onThemeToggle);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      ),
    );
  }
}

// 2. Accept VoidCallback in HomeScreen
class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;

  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'RallyRed', // Passed directly to CustomAppBar
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            HeroBannerWidget(),
            ProductList(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId, required this.onThemeToggle});
  final VoidCallback onThemeToggle;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product Details',
        showBackButton: true, 
      ),
      body: Center(
        child: Text(
          'Details for Product ID: $productId',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
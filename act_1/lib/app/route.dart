import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/herobanner.dart';
import '/productlist.dart';
import '/appbar.dart';
import '/productdetail.dart';
import '/cartstate.dart';
import '/cart.dart';
import '/checkout.dart';

class AppRouter {
    static GoRouter createRouter({required VoidCallback onThemeToggle, required CartModel cartModel}) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => HomeScreen(onThemeToggle: onThemeToggle, cartModel: cartModel),
        ),
        GoRoute(
          path: '/product/:id',
          name: 'productDetail',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '0';
            return ProductDetailScreen(productId: productId, cartModel: cartModel);
          },
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => Scaffold(
            appBar: CustomAppBar(
              title: 'Cart',
              showBackButton: true,
              cartModel: cartModel,
            ),
            body: CartView(
              cartModel: cartModel,
              onRemove: (productId) => cartModel.removeProduct(productId, quantity: cartModel.getQuantity(productId)),
            ),
          ),
        ),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          builder: (context, state) => Scaffold(
            appBar: CustomAppBar(
              title: 'Checkout',
              showBackButton: true,
              cartModel: cartModel,
            ),
            body: CheckoutPage(cartModel: cartModel),
          ),
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

class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final CartModel cartModel;

  const HomeScreen({super.key, required this.onThemeToggle, required this.cartModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'RallyRed',
        cartModel: cartModel,  
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            HeroBannerWidget(),
            SizedBox(height: 24),
            Text(
              'Product List',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ProductList(),
            SizedBox(height: 60),
            Text(
              '© 2026 RallyRed. All rights reserved.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 44),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../views/home_view.dart';
import '../views/product_detail_view.dart';
import '../views/cart_view.dart';
import '../views/checkout_view.dart';
import '../widgets/appbar.dart';

class AppRouter {
  static GoRouter createRouter({
    required VoidCallback onThemeToggle,
    required CartModel cartModel,
  }) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => Scaffold(
            appBar: CustomAppBar(title: 'RallyRed', cartModel: cartModel),
            body: const HomeView(),
          ),
        ),
        GoRoute(
          path: '/product/:id',
          name: 'productDetail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '1';
            return ProductDetailView(productId: id, cartModel: cartModel);
          },
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => Scaffold(
            appBar: CustomAppBar(title: 'Your Cart', showBackButton: true, cartModel: cartModel),
            body: CartView(cartModel: cartModel),
          ),
        ),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          builder: (context, state) => CheckoutView(cartModel: cartModel),
        ),
      ],
    );
  }
}
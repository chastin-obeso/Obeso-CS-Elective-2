import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/home_view.dart';
import '../views/product_detail_view.dart';
import '../views/cart_view.dart';
import '../views/checkout_view.dart';
import '../views/login_view.dart';
import '../views/signup_view.dart';
import '../views/order_history_view.dart';
import '../views/admin_orders_view.dart';
import '../widgets/appbar.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static GoRouter createRouter({
    required VoidCallback onThemeToggle,
  }) {
    final supabase = Supabase.instance.client;

    return GoRouter(
      initialLocation: '/login',
      refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
      redirect: (context, state) {
        final isLoggedIn = supabase.auth.currentSession != null;
        final loc = state.matchedLocation;
        final isAuthRoute = loc == '/login' || loc == '/signup';

        if (!isLoggedIn && !isAuthRoute) {
          return '/login';
        }
        if (isLoggedIn && isAuthRoute) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignUpView(),
        ),
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const Scaffold(
            appBar: CustomAppBar(title: 'RallyRed'),
            body: HomeView(),
          ),
        ),
        GoRoute(
          path: '/product/:id',
          name: 'productDetail',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '1';
            return ProductDetailView(productId: id);
          },
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => const Scaffold(
            appBar: CustomAppBar(
              title: 'Your Cart',
              showBackButton: true,
            ),
            body: CartView(),
          ),
        ),
        GoRoute(
          path: '/checkout',
          name: 'checkout',
          builder: (context, state) => const CheckoutView(),
        ),
        GoRoute(
          path: '/orders',
          name: 'orderHistory',
          builder: (context, state) => const Scaffold(
            appBar: CustomAppBar(
              title: 'My Orders',
              showBackButton: true,
            ),
            body: OrderHistoryView(),
          ),
        ),
        GoRoute(
          path: '/admin/orders',
          name: 'adminOrders',
          builder: (context, state) => const Scaffold(
            appBar: CustomAppBar(
              title: 'All Orders (Admin)',
              showBackButton: true,
            ),
            body: AdminOrdersView(),
          ),
        ),
      ],
    );
  }
}
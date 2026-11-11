import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/cart_provider.dart';
import '../views/home_view.dart';
import '../views/product_detail_view.dart';
import '../views/cart_view.dart';
import '../views/checkout_view.dart';
import '../views/login_view.dart';
import '../views/signup_view.dart';
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
    required CartModel cartModel,
  }) {
    final supabase = Supabase.instance.client;

    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
      redirect: (context, state) {
        final isLoggedIn = supabase.auth.currentSession != null;
        final isAuthRoute =
            state.matchedLocation == '/login' || state.matchedLocation == '/signup';

        if (isLoggedIn && isAuthRoute) {
          return '/';
        }

        if (!isLoggedIn && state.matchedLocation == '/checkout') {
          return '/login';
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
            appBar: CustomAppBar(
              title: 'Your Cart',
              showBackButton: true,
              cartModel: cartModel,
            ),
            body: CartView(cartModel: cartModel),
          ),
          redirect: (context, state) {
            final isLoggedIn = supabase.auth.currentSession != null;
            final isAuthRoute =
                state.matchedLocation == '/login' || state.matchedLocation == '/signup';
            final isProtectedRoute =
                state.matchedLocation == '/cart' || state.matchedLocation == '/checkout';

            if (isLoggedIn && isAuthRoute) {
              return '/';
            }

            if (!isLoggedIn && isProtectedRoute) {
              return '/login';
            }

            return null;
          },

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

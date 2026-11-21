import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return AppBar(
      centerTitle: false,
      titleSpacing: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.only(left: showBackButton ? 0.0 : 16.0),
        child: InkWell(
          onTap: () => context.goNamed('home'),
          child: Image.asset(
            isDarkMode ? 'assets/logo_dark.png' : 'assets/logo_light.png',
            fit: BoxFit.contain,
            height: 36,
            errorBuilder: (_, __, ___) => Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      ),
      leading: leading ?? _buildDefaultLeading(context, isIOS),
      actions: actions ?? _buildDefaultActions(context, ref, isDarkMode, isIOS),
      bottom: bottom,
    );
  }

  Widget? _buildDefaultLeading(BuildContext context, bool isIOS) {
    if (!showBackButton) return null;

    return IconButton(
      icon: Icon(isIOS ? CupertinoIcons.back : Icons.arrow_back),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed('home');
        }
      },
    );
  }

  List<Widget> _buildDefaultActions(
    BuildContext context,
    WidgetRef ref,
    bool isDarkMode,
    bool isIOS,
  ) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final cart = ref.watch(cartProvider);

    return [
      if (user != null)
        IconButton(
          tooltip: isAdmin ? 'Manage Orders' : 'Order History',
          icon: Icon(
            isIOS ? CupertinoIcons.doc_plaintext : Icons.receipt_long_outlined,
          ),
          onPressed: () =>
              context.goNamed(isAdmin ? 'adminOrders' : 'orderHistory'),
        ),
      if (user != null && !isAdmin)
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Cart',
              icon: Icon(
                isIOS
                    ? CupertinoIcons.shopping_cart
                    : Icons.shopping_cart_outlined,
              ),
              onPressed: () => context.goNamed('cart'),
            ),
            if (cart.totalCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart.totalCount}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      IconButton(
        tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
        icon: Icon(
          isDarkMode
              ? (isIOS ? CupertinoIcons.sun_max : Icons.light_mode_outlined)
              : (isIOS ? CupertinoIcons.moon : Icons.dark_mode_outlined),
        ),
        onPressed: () => RallyRedApp.of(context).toggleTheme(),
      ),
      if (user != null)
        IconButton(
          tooltip: 'Logout (${user.email ?? 'User'})',
          icon: Icon(
            isIOS ? CupertinoIcons.square_arrow_right : Icons.logout,
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: () async {
            ref.read(cartProvider).clearCart();
            await ref.read(authServiceProvider).signOut();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
              context.goNamed('login');
            }
          },
        )
      else
        IconButton(
          tooltip: 'Login',
          icon: Icon(isIOS ? CupertinoIcons.person : Icons.login),
          onPressed: () => context.goNamed('login'),
        ),
      const SizedBox(width: 12),
    ];
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
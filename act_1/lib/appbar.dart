import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'main.dart';
import 'cartstate.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final CartModel? cartModel;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.bottom,
    this.cartModel,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Image.asset(
          isDarkMode ? 'assets/logo_dark.png' : 'assets/logo_light.png',
          fit: BoxFit.contain,
          height: 36, 
        ),
      ),
      leading: leading ?? _buildDefaultLeading(context, isIOS),
      actions: actions ?? _buildDefaultActions(context, isDarkMode, isIOS),
      bottom: bottom,
    );
  }

  Widget? _buildDefaultLeading(BuildContext context, bool isIOS) {
    if (!showBackButton) return null;

    return IconButton(
      icon: Icon(
        isIOS ? CupertinoIcons.back : Icons.arrow_back,
      ),
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
    bool isDarkMode,
    bool isIOS,
  ) {
    return [
      IconButton(
        icon: Icon(
          isIOS ? CupertinoIcons.search : Icons.search,
        ),
        onPressed: () {
          // Search logic
        },
      ),
      Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(
              isIOS ? CupertinoIcons.shopping_cart : Icons.shopping_cart_outlined,
            ),
            onPressed: () => context.goNamed('cart'),
          ),
          if (cartModel != null)
            ListenableBuilder(
              listenable: cartModel!,
              builder: (context, child) {
                final totalItems = cartModel!.totalCount;
                if (totalItems <= 0) return const SizedBox.shrink();

                return Positioned(
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
                        '$totalItems',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      IconButton(
        icon: Icon(
          isDarkMode
              ? (isIOS ? CupertinoIcons.sun_max : Icons.light_mode_outlined)
              : (isIOS ? CupertinoIcons.moon : Icons.dark_mode_outlined),
        ),
        onPressed: () => RallyRedApp.of(context).toggleTheme(),
      ),
      const SizedBox(width: 16),
    ];
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
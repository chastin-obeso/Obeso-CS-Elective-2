import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return AppBar(
      // Set to false so the title slot (holding the logo) stays left-aligned next to leading slot
      centerTitle: false,
      titleSpacing: 0, 
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      automaticallyImplyLeading: false,

      // 1. Unconstrained Logo inside title slot
      title: Padding(
        padding: EdgeInsets.only(left: showBackButton ? 0.0 : 16.0),
        child: Image.asset(
          isDarkMode ? 'assets/logo_dark.png' : 'assets/logo_light.png',
          fit: BoxFit.contain,
          height: 36, // Fixed height allows native aspect ratio/width without constraints
        ),
      ),

      // 2. Navigation only in leading slot
      leading: leading ?? _buildDefaultLeading(context, isIOS),

      // 3. Adaptive Actions Slot
      actions: actions ?? _buildDefaultActions(context, isDarkMode, isIOS),

      bottom: bottom,
    );
  }

  // --- Adaptive Leading Widget ---
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

  // --- Adaptive Actions List ---
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
          // Open search screen/modal
        },
      ),
      IconButton(
        icon: Icon(
          isIOS ? CupertinoIcons.shopping_cart : Icons.shopping_cart_outlined,
        ),
        onPressed: () {
          // Open cart feature
        },
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
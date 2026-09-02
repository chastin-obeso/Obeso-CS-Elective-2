import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onThemeToggle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
    this.bottom,
    this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return AppBar(
      centerTitle: true,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      automaticallyImplyLeading: showBackButton,

      // 1. Adaptive Leading Width & Widget
      leadingWidth: showBackButton ? null : 190,
      leading: leading ?? _buildDefaultLeading(context, isDarkMode, isIOS),


      // 2. Adaptive Actions Slot
      actions: actions ?? _buildDefaultActions(context, isDarkMode, isIOS),

      bottom: bottom,
    );
  }

  // --- Adaptive Leading Widget ---
  Widget _buildDefaultLeading(BuildContext context, bool isDarkMode, bool isIOS) {
    if (showBackButton) {
      // Custom adaptive back button if preferred over automatic imply leading
      return IconButton(
        icon: Icon(
          isIOS ? CupertinoIcons.back : Icons.arrow_back,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 50.0, top: 8.0, bottom: 8.0),
      child: Image.asset(
        isDarkMode ? 'assets/logo_dark.png' : 'assets/logo_light.png',
        fit: BoxFit.contain,
      ),
    );
  }

  // --- Adaptive Actions List ---
  List<Widget> _buildDefaultActions(BuildContext context, bool isDarkMode, bool isIOS) {
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
        onPressed: onThemeToggle,
      ),
      const SizedBox(width: 50),
    ];
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
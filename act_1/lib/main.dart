import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

void main() {
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && Platform.isIOS;

    if (isIOS) {
      return const CupertinoApp(
        title: 'Dashboard',
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: CupertinoColors.activeBlue,
        ),
        home: ResponsiveDashboard(),
      );
    } else {
      return MaterialApp(
        title: 'Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const ResponsiveDashboard(),
      );
    }
  }
}

class ResponsiveDashboard extends StatefulWidget {
  const ResponsiveDashboard({super.key});

  @override
  State<ResponsiveDashboard> createState() => _ResponsiveDashboardState();
}

class _ResponsiveDashboardState extends State<ResponsiveDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        final isDesktop = constraints.maxWidth >= 1200;

        if (isDesktop) {
          return _buildDesktopLayout(context);
        } else if (isTablet) {
          return _buildTabletLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  // --- HEADER NAVBAR WIDGET ---
  PreferredSizeWidget _buildHeaderNavBar(bool isPlatformIOS, {bool showSearch = true}) {
    if (isPlatformIOS) {
      return CupertinoNavigationBar(
        middle: const Text('Dashboard'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: const Icon(CupertinoIcons.bell, size: 22),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: const Icon(CupertinoIcons.profile_circled, size: 24),
            ),
          ],
        ),
      );
    }

    return AppBar(
      elevation: 1,
      titleSpacing: 16,
      title: Row(
        children: [
          const Icon(Icons.insights, color: Colors.blue),
          const SizedBox(width: 10),
          const Text('Analytics Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          if (showSearch) ...[
            const SizedBox(width: 32),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 40),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search analytics...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue[100],
            radius: 18,
            child: const Text('JD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
        ),
      ],
    );
  }

  // DESKTOP LAYOUT: Header + Sidebar + 4-Column Grid
  Widget _buildDesktopLayout(BuildContext context) {
    final isPlatformIOS = !kIsWeb && Platform.isIOS;

    final bodyContent = Row(
      children: [
        Container(
          width: 240,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: isPlatformIOS ? CupertinoColors.systemGrey5 : Colors.grey[200]!)),
            color: isPlatformIOS ? CupertinoColors.systemGrey6 : Colors.grey[50],
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _buildNavItem(0, 'Dashboard', isPlatformIOS, isPlatformIOS ? CupertinoIcons.home : Icons.dashboard),
              _buildNavItem(1, 'Analytics', isPlatformIOS, isPlatformIOS ? CupertinoIcons.chart_bar : Icons.analytics),
              _buildNavItem(2, 'Reports', isPlatformIOS, isPlatformIOS ? CupertinoIcons.doc : Icons.description),
              _buildNavItem(3, 'Settings', isPlatformIOS, isPlatformIOS ? CupertinoIcons.gear : Icons.settings),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _buildDashboardContent(4, isPlatformIOS),
          ),
        ),
      ],
    );

    return isPlatformIOS
        ? CupertinoPageScaffold(
            navigationBar: _buildHeaderNavBar(true) as ObstructingPreferredSizeWidget,
            child: SafeArea(child: bodyContent),
          )
        : Scaffold(
            appBar: _buildHeaderNavBar(false),
            body: bodyContent,
          );
  }

  // TABLET LAYOUT: Header + 2-Column Grid
  Widget _buildTabletLayout(BuildContext context) {
    final isPlatformIOS = !kIsWeb && Platform.isIOS;

    final bodyContent = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _buildDashboardContent(2, isPlatformIOS),
    );

    return isPlatformIOS
        ? CupertinoPageScaffold(
            navigationBar: _buildHeaderNavBar(true) as ObstructingPreferredSizeWidget,
            child: SafeArea(child: bodyContent),
          )
        : Scaffold(
            appBar: _buildHeaderNavBar(false),
            body: bodyContent,
          );
  }

  // MOBILE LAYOUT: Compact Header + Single-Column Grid + Bottom Tabs
  Widget _buildMobileLayout(BuildContext context) {
    final isPlatformIOS = !kIsWeb && Platform.isIOS;

    if (isPlatformIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.doc), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.gear), label: 'Settings'),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoPageScaffold(
            navigationBar: _buildHeaderNavBar(true, showSearch: false) as ObstructingPreferredSizeWidget,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: _buildDashboardContent(1, isPlatformIOS),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: _buildHeaderNavBar(false, showSearch: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: _buildDashboardContent(1, isPlatformIOS),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  // DASHBOARD GRID
  Widget _buildDashboardContent(int columns, bool isCupertino) {
    final cards = [
      {'title': 'Users', 'value': '1,234', 'icon': isCupertino ? CupertinoIcons.group : Icons.people, 'color': Colors.blue},
      {'title': 'Revenue', 'value': '\$45.2K', 'icon': isCupertino ? CupertinoIcons.graph_square : Icons.trending_up, 'color': Colors.green},
      {'title': 'Orders', 'value': '892', 'icon': isCupertino ? CupertinoIcons.cart : Icons.shopping_cart, 'color': Colors.orange},
      {'title': 'Growth', 'value': '+12.5%', 'icon': isCupertino ? CupertinoIcons.chart_bar : Icons.show_chart, 'color': Colors.purple},
      {'title': 'Sessions', 'value': '3.5K', 'icon': isCupertino ? CupertinoIcons.time : Icons.schedule, 'color': Colors.red},
      {'title': 'Conversion', 'value': '3.2%', 'icon': isCupertino ? CupertinoIcons.percent : Icons.percent, 'color': Colors.teal},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return _buildDashboardCard(
              title: card['title'] as String,
              value: card['value'] as String,
              icon: card['icon'] as IconData,
              color: card['color'] as Color,
              isCupertino: isCupertino,
            );
          },
        ),
      ],
    );
  }

  // DASHBOARD CARD
  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isCupertino,
  }) {
    final cardChild = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 22),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );

    if (isCupertino) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey4),
          borderRadius: BorderRadius.circular(12),
          color: CupertinoColors.white,
        ),
        child: cardChild,
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: cardChild,
    );
  }

  // NAVIGATION ITEM
  Widget _buildNavItem(int index, String label, bool isCupertino, IconData icon) {
    final isSelected = _selectedIndex == index;

    if (isCupertino) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => setState(() => _selectedIndex = index),
        child: Container(
          color: isSelected ? CupertinoColors.systemBlue.withOpacity(0.1) : CupertinoColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.black),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey[600]),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.blue : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }
}
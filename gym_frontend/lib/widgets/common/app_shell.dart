import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../utils/responsive.dart';
import 'theme_settings.dart';

class AppNavItem {
  const AppNavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.items,
    required this.index,
    required this.onSelect,
    required this.body,
    this.showLogout = false,
    this.trailing,
  });

  final String title;
  final List<AppNavItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  final Widget body;
  final bool showLogout;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Theme',
            onPressed: () => showThemeSettings(context),
            icon: const Icon(Icons.palette_outlined),
          ),
          ?trailing,
          if (showLogout)
            IconButton(
              tooltip: 'Logout',
              onPressed: () async {
                await context.read<AuthController>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                }
              },
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      drawer: mobile
          ? Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  for (var i = 0; i < items.length; i++)
                    ListTile(
                      leading: Icon(items[i].icon),
                      title: Text(items[i].label),
                      selected: i == index,
                      onTap: () {
                        Navigator.pop(context);
                        onSelect(i);
                      },
                    ),
                ],
              ),
            )
          : null,
      body: mobile
          ? body
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: onSelect,
                  extended: MediaQuery.sizeOf(context).width >= 1100,
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
      bottomNavigationBar: mobile && items.length <= 5
          ? NavigationBar(
              selectedIndex: index.clamp(0, items.length - 1),
              onDestinationSelected: onSelect,
              destinations: [
                for (final item in items.take(5))
                  NavigationDestination(icon: Icon(item.icon), label: item.label),
              ],
            )
          : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth/auth_controller.dart';
import '../../theme/peakforge_colors.dart';
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
    final theme = Theme.of(context);
    final pf = context.pf;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: pf.heroGradient),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.fitness_center, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(title, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
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
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: pf.heroGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.fitness_center, color: Colors.white, size: 28),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final selected = i == index;
                          return ListTile(
                            leading: Icon(items[i].icon),
                            title: Text(
                              items[i].label,
                              style: TextStyle(
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            selected: selected,
                            onTap: () {
                              Navigator.pop(context);
                              onSelect(i);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: mobile
          ? body
          : Row(
              children: [
                _DesktopSidebar(
                  title: title,
                  items: items,
                  index: index,
                  onSelect: onSelect,
                  extended: MediaQuery.sizeOf(context).width >= 1100,
                ),
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

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.title,
    required this.items,
    required this.index,
    required this.onSelect,
    required this.extended,
  });

  final String title;
  final List<AppNavItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final pf = context.pf;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: extended ? 248 : 88,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: pf.heroGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(extended ? 18 : 12, 20, extended ? 18 : 12, 12),
              child: extended
                  ? Row(
                      children: [
                        const Icon(Icons.fitness_center, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Icon(Icons.fitness_center, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final selected = i == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.16)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onSelect(i),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: extended ? 12 : 0,
                            vertical: 11,
                          ),
                          child: extended
                              ? Row(
                                  children: [
                                    Icon(
                                      items[i].icon,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        items[i].label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Icon(
                                    items[i].icon,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

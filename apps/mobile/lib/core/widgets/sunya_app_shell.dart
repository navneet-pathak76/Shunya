import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/sunya_theme.dart';
import 'sunya_glass.dart';

class SunyaAppShell extends StatelessWidget {
  const SunyaAppShell({super.key, required this.child});

  final Widget child;

  static const destinations = <_SunyaDestination>[
    _SunyaDestination('Home', '/dashboard', Icons.home_outlined, Icons.home_rounded),
    _SunyaDestination('Body', '/body', Icons.accessibility_new_outlined, Icons.accessibility_new),
    _SunyaDestination('Hydration', '/hydration', Icons.water_drop_outlined, Icons.water_drop),
    _SunyaDestination('Nutrition', '/nutrition', Icons.restaurant_outlined, Icons.restaurant),
    _SunyaDestination('Workout', '/workout', Icons.fitness_center_outlined, Icons.fitness_center),
  ];

  int _index(String location) {
    for (var i = 0; i < destinations.length; i++) {
      if (location.startsWith(destinations[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selected = _index(location);

    return Scaffold(
      backgroundColor: SunyaTheme.background,
      body: child,
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) return const SizedBox.shrink();
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: SunyaGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                borderRadius: SunyaTheme.radiusLarge,
                opacity: 0.82,
                child: NavigationBar(
                  selectedIndex: selected,
                  onDestinationSelected: (index) => context.go(destinations[index].path),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  height: 68,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: destinations
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SunyaDestination {
  const _SunyaDestination(this.label, this.path, this.icon, this.selectedIcon);
  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
}

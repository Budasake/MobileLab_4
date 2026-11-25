// lib/widgets/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Үндсэн цэс: өргөн дэлгэцэд NavigationRail, утсанд NavigationBar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _items = [
    (Icons.landscape_outlined, Icons.landscape, 'Газрууд'),
    (Icons.map_outlined, Icons.map, 'Газрын зураг'),
    (Icons.favorite_border, Icons.favorite, 'Дуртай'),
    (Icons.settings_outlined, Icons.settings, 'Тохиргоо'),
  ];

  void _go(int i) => shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: shell.currentIndex,
                  onDestinationSelected: _go,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final it in _items)
                      NavigationRailDestination(
                        icon: Icon(it.$1),
                        selectedIcon: Icon(it.$2),
                        label: Text(it.$3),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: shell),
              ],
            ),
          );
        }
        return Scaffold(
          body: shell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _go,
            destinations: [
              for (final it in _items)
                NavigationDestination(
                  icon: Icon(it.$1),
                  selectedIcon: Icon(it.$2),
                  label: it.$3,
                ),
            ],
          ),
        );
      },
    );
  }
}

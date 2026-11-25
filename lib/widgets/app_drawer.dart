// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Лаб 3: Drawer → ListView → DrawerHeader + 3 ListTile.
/// Өнгийг colorScheme-ээс авна.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primaryContainer),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Аяллын газрууд',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: scheme.onPrimaryContainer),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Бүх газар'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/places');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Дуртай'),
            onTap: () {
              Navigator.of(context).pop();
              context.go('/favorites');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Тухай'),
            onTap: () {
              Navigator.of(context).pop();
              showAboutDialog(
                context: context,
                applicationName: 'TRAVEL APP',
                applicationVersion: '1.0.0',
                children: const [
                  Text('Монголын үзэсгэлэнт газруудыг танилцуулах апп.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

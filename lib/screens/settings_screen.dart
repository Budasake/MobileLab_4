// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Системээс гарах'),
        content: const Text('Та системээс гарахдаа итгэлтэй байна уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Болих'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Гарах'),
          ),
        ],
      ),
    );
    if (ok == true) auth.logout(); // router redirect → /login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Тохиргоо')),
      body: ListenableBuilder(
        listenable: auth,
        builder: (context, _) => ListView(
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(auth.email ?? ''),
              subtitle: const Text('Нэвтэрсэн'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Нууц үг солих'),
              subtitle: const Text('Одоогийн нууц үгээ шинэчлэх'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/password'),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Тухай'),
              subtitle: const Text('TRAVEL APP 1.0.0'),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'TRAVEL APP',
                applicationVersion: '1.0.0',
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Гарах'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

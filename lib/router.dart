import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'data/places.dart';
import 'screens/add_place_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/map_picker_screen.dart';
import 'screens/places_map_screen.dart';
import 'screens/settings_screen.dart';
import 'state/auth_service.dart';
import 'widgets/app_shell.dart';

final router = GoRouter(
  initialLocation: '/places',
  refreshListenable: auth,
  redirect: (context, state) {
    final onLogin = state.matchedLocation == '/login';
    if (!auth.loggedIn) return onLogin ? null : '/login';
    if (onLogin) return '/places';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/places', builder: (_, __) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/explore',
            builder: (_, __) => const PlacesMapScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/favorites',
            builder: (_, __) => const FavoritesScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/place/:id',
      builder: (_, state) {
        final id = state.pathParameters['id'];
        final matches = places.where((p) => p.id == id);
        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Газар олдсонгүй')),
          );
        }
        return DetailScreen(place: matches.first);
      },
    ),
    GoRoute(path: '/add', builder: (_, __) => const AddPlaceScreen()),
    GoRoute(
      path: '/map',
      builder: (_, state) => MapPickerScreen(
        args: state.extra as MapPickerArgs? ?? const MapPickerArgs(),
      ),
    ),
    GoRoute(
      path: '/password',
      builder: (_, __) => const ChangePasswordScreen(),
    ),
  ],
);

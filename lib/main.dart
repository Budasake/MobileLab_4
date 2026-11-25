import 'package:flutter/material.dart';
import 'router.dart';
import 'state/favorites.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadFavorites();
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Colors.teal;
    return MaterialApp.router(
      title: 'TRAVEL APP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        fontFamily: 'RobotoSlab',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        fontFamily: 'RobotoSlab',
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

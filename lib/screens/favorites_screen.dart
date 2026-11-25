import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/places.dart';
import '../state/favorites.dart';
import '../widgets/place_image.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Дуртай газрууд')),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: favorites,
        builder: (context, ids, _) {
          final list = places.where((p) => ids.contains(p.id)).toList();
          if (list.isEmpty) {
            return const Center(
              child: Text('Дуртай газар алга. Дэлгэрэнгүй дэлгэц дээрх ♡-г дарна уу.'),
            );
          }
          return ListView(
            children: [
              for (final p in list)
                ListTile(
                  leading: ClipOval(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: PlaceImage(place: p),
                    ),
                  ),
                  title: Text(p.name),
                  subtitle: Text(p.region),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Дуртайгаас хасах',
                    onPressed: () => toggleFavorite(p.id),
                  ),
                  onTap: () => context.push('/place/${p.id}'),
                ),
            ],
          );
        },
      ),
    );
  }
}

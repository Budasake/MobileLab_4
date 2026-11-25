import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'favorite_place_ids';

final ValueNotifier<Set<String>> favorites = ValueNotifier<Set<String>>({});

Future<void> loadFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  favorites.value = (prefs.getStringList(_key) ?? const <String>[]).toSet();
}

Future<void> toggleFavorite(String id) async {
  final next = {...favorites.value};
  if (!next.remove(id)) next.add(id);
  favorites.value = next;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_key, next.toList());
}

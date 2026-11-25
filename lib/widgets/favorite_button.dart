import 'package:flutter/material.dart';

import '../state/favorites.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favorites,
      builder: (context, ids, _) {
        final fav = ids.contains(placeId);
        return IconButton(
          tooltip: fav ? 'Дуртайгаас хасах' : 'Дуртайд нэмэх',
          icon: Icon(
            fav ? Icons.favorite : Icons.favorite_border,
            color: fav ? Colors.redAccent : null,
          ),
          onPressed: () => toggleFavorite(placeId),
        );
      },
    );
  }
}

// lib/widgets/place_card.dart
import 'package:flutter/material.dart';

import '../models/place.dart';
import '../state/ratings.dart';
import 'place_image.dart';
import 'season_badge.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({super.key, required this.place, this.onTap});

  final Place place;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: userRatings,
      builder: (context, ratings, _) {
        final summary = ratingOf(place, ratings);
        return Semantics(
          label: '${place.name}, ${place.region}, '
              '${summary.hasRating ? 'үнэлгээ ${summary.label}' : 'шинэ газар'}',
          button: true,
          excludeSemantics: true,
          onTap: onTap,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PlaceImage(place: place, width: double.infinity),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: SeasonBadge(season: place.bestSeason),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                place.region,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            Text(
                              summary.hasRating ? summary.label : 'Шинэ',
                              style: text.labelMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

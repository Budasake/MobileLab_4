import 'package:flutter/foundation.dart';
import '../models/place.dart';

final userRatings = ValueNotifier<Map<String, int>>({});

void ratePlace(String placeId, int stars) {
  assert(stars >= 1 && stars <= 5);
  userRatings.value = {...userRatings.value, placeId: stars};
}

class RatingSummary {
  const RatingSummary(this.average, this.count, this.mine);
  final double average; 
  final int count;
  final int? mine;

  bool get hasRating => count > 0;
  String get label => average.toStringAsFixed(1);
}

RatingSummary ratingOf(Place place, [Map<String, int>? ratings]) {
  final mine = (ratings ?? userRatings.value)[place.id];
  final baseCount = place.rating > 0 ? place.ratingCount : 0;
  if (mine == null) return RatingSummary(place.rating, baseCount, null);
  final count = baseCount + 1;
  final average = (place.rating * baseCount + mine) / count;
  return RatingSummary(average, count, mine);
}

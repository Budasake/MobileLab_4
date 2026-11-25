// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/picked_location.dart';
import '../models/place.dart';
import '../state/ratings.dart';
import '../utils/geo.dart';
import '../utils/season.dart';
import '../widgets/place_image.dart';
import '../widgets/rating_input.dart';
import '../widgets/star_rating.dart';
import 'map_picker_screen.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(place.name)),
        body: PlaceDetailView(place: place),
      );
}

/// Scaffold-гүй хэсэг — master–detail дотор дахин ашиглагдана.
class PlaceDetailView extends StatelessWidget {
  const PlaceDetailView({super.key, required this.place});

  final Place place;

  void _rate(BuildContext context, int stars) {
    ratePlace(place.id, stars);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('«${place.name}»-д $stars од өглөө'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _openMap(BuildContext context) {
    context.push(
      '/map',
      extra: MapPickerArgs(
        readOnly: true,
        title: place.name,
        initial: PickedLocation(
          latitude: place.latitude!,
          longitude: place.longitude!,
          name: place.name,
          address: place.region,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // 1. Зураг + нэр + үнэлгээ (зураг дээр давхарласан)
    final imageSection = Stack(
      children: [
        PlaceImage(
          place: place,
          height: 260,
          width: double.infinity,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: text.headlineSmall?.copyWith(color: Colors.white),
                ),
                ValueListenableBuilder<Map<String, int>>(
                  valueListenable: userRatings,
                  builder: (context, ratings, _) {
                    final summary = ratingOf(place, ratings);
                    if (!summary.hasRating) {
                      return Text(
                        'Шинэ газар — үнэлгээ хараахан алга',
                        style: text.bodyMedium?.copyWith(color: Colors.white),
                      );
                    }
                    return Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        StarRating(rating: summary.average),
                        Text(
                          summary.label,
                          style:
                              text.titleMedium?.copyWith(color: Colors.white),
                        ),
                        Text(
                          '(${summary.count} үнэлгээ)',
                          style:
                              text.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );

    // 2. "Энэ газрыг үнэлэх" карт
    final rateSection = ValueListenableBuilder<Map<String, int>>(
      valueListenable: userRatings,
      builder: (context, ratings, _) {
        final summary = ratingOf(place, ratings);
        return _RateCard(
          mine: summary.mine,
          onRate: (stars) => _rate(context, stars),
        );
      },
    );

    // 3. Товч мэдээлэл (аймаг, зай, улирал)
    final statsSection = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _Stat(Icons.place, place.region)),
          Expanded(
            child: _Stat(
              Icons.route,
              place.distanceKm > 0 ? '${place.distanceKm} км' : '—',
            ),
          ),
          Expanded(
            child: _Stat(
              seasonStyle(place.bestSeason).icon,
              place.bestSeason,
              color: seasonStyle(place.bestSeason).color,
            ),
          ),
        ],
      ),
    );

    // 4. Улирлын карт
    final seasonSection = _SeasonCard(season: place.bestSeason);

    // 5. Байршил
    final locationSection = place.hasLocation
        ? ListTile(
            leading: const Icon(Icons.my_location),
            title: const Text('Байршил'),
            subtitle:
                Text(formatCoordinates(place.latitude!, place.longitude!)),
            trailing: const Icon(Icons.map_outlined),
            onTap: () => _openMap(context),
          )
        : const SizedBox.shrink();

    // 6. Тайлбар
    final descriptionSection = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Text(place.description, style: text.bodyLarge),
    );

    // Дарааллыг эндээс солино. Одоо: 1 ба 3 солигдсон.
    return ListView(
      children: [
        imageSection, // 1
        rateSection, // 2
        seasonSection, // 4
        locationSection, // 5
        descriptionSection, // 6
        statsSection, // 3
      ],
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.mine, required this.onRate});

  final int? mine;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              mine == null ? 'Энэ газрыг үнэлэх' : 'Таны үнэлгээ: $mine/5',
              style: text.titleSmall,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: RatingInput(value: mine ?? 0, onChanged: onRate),
            ),
            if (mine == null)
              Text('Од дээр дарж үнэлгээ өгнө үү', style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.label, {this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center),
        ],
      );
}

/// Улирлын тайлбар карт: температур, үйл ажиллагаа, зөвлөгөө.
class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.season});

  final String season;

  @override
  Widget build(BuildContext context) {
    final s = seasonStyle(season);
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      color: s.color.withAlpha(35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(s.icon, color: s.color, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Тохиромжтой улирал: $season', style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text('Температур: ${s.temperature}', style: text.bodyMedium),
                  Text('Үйл ажиллагаа: ${s.activities}',
                      style: text.bodyMedium),
                  if (s.tip.isNotEmpty)
                    Text('Анхаар: ${s.tip}', style: text.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

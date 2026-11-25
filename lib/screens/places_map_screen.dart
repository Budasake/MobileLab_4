// lib/screens/places_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../config.dart';
import '../data/places.dart';

/// Бие даан ажил: бүх газрыг marker-ээр харуулж, marker дарахад
/// дэлгэрэнгүй дэлгэц нээгдэнэ.
class PlacesMapScreen extends StatelessWidget {
  const PlacesMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final withLocation = places.where((p) => p.hasLocation).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Газрын зураг')),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(46.8625, 103.8467),
          initialZoom: 4.6,
          minZoom: 3,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: appPackageName,
          ),
          MarkerLayer(
            markers: [
              for (final p in withLocation)
                Marker(
                  point: LatLng(p.latitude!, p.longitude!),
                  width: 48,
                  height: 48,
                  alignment: Alignment.topCenter,
                  child: Tooltip(
                    message: p.name,
                    child: GestureDetector(
                      onTap: () => context.push('/place/${p.id}'),
                      child: Icon(
                        Icons.location_pin,
                        size: 48,
                        color: scheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SimpleAttributionWidget(
            source: Text('OpenStreetMap contributors'),
          ),
        ],
      ),
    );
  }
}

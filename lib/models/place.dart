import 'dart:typed_data';
import 'package:flutter/widgets.dart';

class Place {
  const Place({
    required this.id,
    required this.name,
    required this.region,
    required this.image,
    required this.description,
    required this.rating,
    this.ratingCount = 0,
    required this.distanceKm,
    required this.bestSeason,
    this.latitude,
    this.longitude,
    this.imageBytes,
  });

  final String id;
  final String name;
  final String region;
  final String image; 
  final String description;
  final double rating;
  final int ratingCount;
  final int distanceKm; 
  final String bestSeason; 
  final double? latitude;
  final double? longitude;
  final Uint8List? imageBytes;

  bool get hasLocation => latitude != null && longitude != null;

  ImageProvider get imageProvider =>
      imageBytes != null ? MemoryImage(imageBytes!) : AssetImage(image);
}

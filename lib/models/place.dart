// lib/models/place.dart
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
  final String image; // 'assets/images/...'
  final String description;
  final double rating; // анхны дундаж үнэлгээ 0–5; 0 = үнэлгээгүй
  final int ratingCount;
  final int distanceKm; // Улаанбаатараас (шулуун зай); 0 = тодорхойгүй
  final String bestSeason; // 'Хавар' | 'Зун' | 'Намар' | 'Өвөл'
  final double? latitude;
  final double? longitude;
  final Uint8List? imageBytes; // хэрэглэгчийн оруулсан зураг

  bool get hasLocation => latitude != null && longitude != null;

  ImageProvider get imageProvider =>
      imageBytes != null ? MemoryImage(imageBytes!) : AssetImage(image);
}

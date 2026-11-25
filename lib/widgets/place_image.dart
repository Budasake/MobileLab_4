// lib/widgets/place_image.dart
import 'package:flutter/material.dart';

import '../models/place.dart';

/// Газрын зураг. Зураг олдохгүй бол дүрс харуулж апп унахаас сэргийлнэ.
class PlaceImage extends StatelessWidget {
  const PlaceImage({
    super.key,
    required this.place,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final Place place;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Image(
      image: place.imageProvider,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: '${place.name} — зураг',
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: scheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(Icons.landscape, color: scheme.outline),
      ),
    );
  }
}

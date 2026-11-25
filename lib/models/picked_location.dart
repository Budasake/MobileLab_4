import '../utils/geo.dart';

class PickedLocation {
  const PickedLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.name,
    this.region,
  });

  final double latitude;
  final double longitude;
  final String? address;
  final String? name;
  final String? region;

  PickedLocation copyWith({String? address, String? name, String? region}) =>
      PickedLocation(
        latitude: latitude,
        longitude: longitude,
        address: address ?? this.address,
        name: name ?? this.name,
        region: region ?? this.region,
      );

  String get coordinates => formatCoordinates(latitude, longitude);
}

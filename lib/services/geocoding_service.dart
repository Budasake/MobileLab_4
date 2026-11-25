import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/picked_location.dart';

class GeocodingException implements Exception {
  const GeocodingException(this.message);
  final String message;
  @override
  String toString() => message;
}

class Geocoding {
  const Geocoding._();

  static const _host = 'nominatim.openstreetmap.org';
  static final _searchCache = <String, List<PickedLocation>>{};
  static final _reverseCache = <String, PickedLocation?>{};
  static DateTime _lastRequest = DateTime.fromMillisecondsSinceEpoch(0);
  static Future<void> _queue = Future.value();

  static Future<List<PickedLocation>> search(String query) async {
    final key = query.trim().toLowerCase();
    final cached = _searchCache[key];
    if (cached != null) return cached;

    final data = await _get('/search', {
      'q': query.trim(),
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '5',
      'countrycodes': 'mn',
      'accept-language': 'mn',
    });
    if (data is! List) return const [];
    final results = [
      for (final r in data.whereType<Map<String, dynamic>>()) _parse(r),
    ];
    _searchCache[key] = results;
    return results;
  }

  static Future<PickedLocation?> reverse(double lat, double lng) async {
    final key = '${lat.toStringAsFixed(4)},${lng.toStringAsFixed(4)}';
    if (_reverseCache.containsKey(key)) {
      return _at(_reverseCache[key], lat, lng);
    }
    final data = await _get('/reverse', {
      'lat': '$lat',
      'lon': '$lng',
      'format': 'jsonv2',
      'addressdetails': '1',
      'zoom': '14',
      'accept-language': 'mn',
    });
    final result = data is Map<String, dynamic> && !data.containsKey('error')
        ? _parse(data)
        : null;
    _reverseCache[key] = result;
    return _at(result, lat, lng);
  }

  static PickedLocation? _at(PickedLocation? r, double lat, double lng) =>
      r == null
          ? null
          : PickedLocation(
              latitude: lat,
              longitude: lng,
              address: r.address,
              name: r.name,
              region: r.region,
            );

  static Future<Object?> _get(String path, Map<String, String> params) {
    final result = _queue.then<Object?>((_) => _send(path, params));
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  static Future<Object?> _send(String path, Map<String, String> params) async {
    final wait = _lastRequest
        .add(const Duration(milliseconds: 1100))
        .difference(DateTime.now());
    if (wait > Duration.zero) await Future<void>.delayed(wait);
    _lastRequest = DateTime.now();

    final http.Response res;
    try {
      res = await http
          .get(
            Uri.https(_host, path, params),
            headers: kIsWeb ? null : {'User-Agent': nominatimUserAgent},
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const GeocodingException(
        'Сервер хариу өгсөнгүй. Интернэтээ шалгаад дахин оролдоно уу.',
      );
    } on http.ClientException catch (e) {
      throw GeocodingException('Сүлжээний алдаа: ${e.message}');
    }

    switch (res.statusCode) {
      case 200:
        return jsonDecode(utf8.decode(res.bodyBytes));
      case 429:
        throw const GeocodingException(
          'Хэт олон хүсэлт илгээлээ. Түр хүлээгээд дахин оролдоно уу.',
        );
      case 403:
        throw const GeocodingException(
          'Nominatim хүсэлтийг хаалаа (403). Түр хүлээгээд дахин оролдоно уу.',
        );
      default:
        throw GeocodingException('Серверийн алдаа (HTTP ${res.statusCode}).');
    }
  }

  static const _nameKeys = [
    'tourism',
    'natural',
    'water',
    'leisure',
    'historic',
    'village',
    'town',
    'hamlet',
    'city',
    'county',
  ];

  static const _regionKeys = ['state', 'city', 'province', 'region', 'county'];

  static PickedLocation _parse(Map<String, dynamic> r) {
    final address = r['address'] is Map
        ? (r['address'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    String? pick(List<String> keys) {
      for (final k in keys) {
        final v = address[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return null;
    }

    final rawName = r['name'];
    final name = rawName is String && rawName.trim().isNotEmpty
        ? rawName.trim()
        : pick(_nameKeys);

    return PickedLocation(
      latitude: double.parse('${r['lat']}'),
      longitude: double.parse('${r['lon']}'),
      address: r['display_name'] as String?,
      name: name,
      region: pick(_regionKeys),
    );
  }
}

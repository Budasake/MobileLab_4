// lib/config.dart
import 'package:flutter/foundation.dart';

/// OpenStreetMap-ийн ашиглах нөхцлийн дагуу хүсэлт бүрт апп-аа танилцуулна.
const appPackageName = 'com.example.travel_mn';

/// Nominatim-д илгээх User-Agent.
const nominatimUserAgent = 'travel_mn/1.3 (Flutter lab app; $appPackageName)';

/// Камераар зураг авах боломж (утас, таблет).
bool get cameraSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

import 'package:flutter/foundation.dart';
const appPackageName = 'com.example.travel_mn';
const nominatimUserAgent = 'travel_mn/1.3 (Flutter lab app; $appPackageName)';

bool get cameraSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

// Copyright (c) 2024-2026 Hamza Awan. All rights reserved.
// Licensed under AGPL-3.0. See LICENSE for details.
// Commercial use requires a separate license. See COMMERCIAL.md.

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

/// Singleton service that manages AdMob initialization and ad-unit IDs.
///
/// ┌─────────────────────────────────────────────────────────────────────┐
/// │  TODO: Before publishing, replace every test ID below with your    │
/// │  real AdMob ad-unit IDs from https://admob.google.com              │
/// └─────────────────────────────────────────────────────────────────────┘
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _initialized = false;

  /// Call once at app startup (before showing any ads).
  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  // ── Banner ad-unit IDs (test IDs — safe for development) ────────────
  // Android test banner: ca-app-pub-3940256099942544/6300978111
  // iOS test banner:     ca-app-pub-3940256099942544/2934735716

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6184885985065508/6276401753'; // Production banner ad unit
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // TODO: replace with real ID
    }
    throw UnsupportedError('Unsupported platform for ads');
  }
}

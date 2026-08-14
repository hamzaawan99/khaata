// Copyright (c) 2024-2026 Hamza Awan. All rights reserved.
// Licensed under AGPL-3.0. See LICENSE for details.
// Commercial use requires a separate license. See COMMERCIAL.md.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/purchase_service.dart';

/// Manages the user's premium (ad-free) status.
///
/// Premium = true  → all ads hidden, full feature access.
/// Premium = false → ads shown, can purchase "Remove Ads".
class PremiumProvider with ChangeNotifier {
  static const _keyPremium = 'is_premium';

  bool _isPremium = false;
  bool _isLoading = false;

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;

  final PurchaseService _purchaseService = PurchaseService();

  PremiumProvider() {
    _load();
    _listenToPurchases();
  }

  /// Load persisted premium status.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_keyPremium) ?? false;
    notifyListeners();
  }

  /// Listen to purchase stream for real-time updates.
  void _listenToPurchases() {
    _purchaseService.purchaseStream.listen((purchased) {
      if (purchased) {
        _setPremium(true);
      }
    });
  }

  /// Initiate the "Remove Ads" purchase flow.
  Future<void> purchaseRemoveAds() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _purchaseService.buyRemoveAds();
    } catch (e) {
      debugPrint('Purchase error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restore previous purchases (e.g. after reinstall).
  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _purchaseService.restorePurchases();
    } catch (e) {
      debugPrint('Restore error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPremium, value);
    notifyListeners();
  }
}

// Copyright (c) 2024-2026 Hamza Awan. All rights reserved.
// Licensed under AGPL-3.0. See LICENSE for details.
// Commercial use requires a separate license. See COMMERCIAL.md.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Handles the one-time "Remove Ads" in-app purchase.
///
/// ┌─────────────────────────────────────────────────────────────────────┐
/// │  Before publishing:                                                 │
/// │  1. Create a "remove_ads" managed product in Play Console           │
/// │     (In-app products → Create product → Product ID: remove_ads)     │
/// │  2. Set price to $3.99 (or your preferred price)                    │
/// │  3. Activate the product                                            │
/// └─────────────────────────────────────────────────────────────────────┘
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal() {
    _init();
  }

  static const String removeAdsProductId = 'remove_ads';

  final InAppPurchase _iap = InAppPurchase.instance;
  final _purchaseController = StreamController<bool>.broadcast();

  Stream<bool> get purchaseStream => _purchaseController.stream;

  bool _available = false;
  ProductDetails? _removeAdsProduct;

  Future<void> _init() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('In-app purchases not available on this device');
      return;
    }

    // Listen to purchase updates
    _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) => debugPrint('Purchase stream error: $error'),
    );

    // Load product details
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails({removeAdsProductId});
    if (response.error != null) {
      debugPrint('Error loading products: ${response.error}');
      return;
    }
    if (response.productDetails.isNotEmpty) {
      _removeAdsProduct = response.productDetails.first;
      debugPrint('Loaded product: ${_removeAdsProduct!.title} — ${_removeAdsProduct!.price}');
    } else {
      debugPrint('Product "$removeAdsProductId" not found. Create it in Play Console.');
    }
  }

  /// Get the formatted price string (e.g. "$3.99").
  String? get removeAdsPrice => _removeAdsProduct?.price;

  /// Start the purchase flow.
  Future<void> buyRemoveAds() async {
    if (_removeAdsProduct == null) {
      debugPrint('Remove Ads product not loaded yet');
      return;
    }
    final purchaseParam = PurchaseParam(productDetails: _removeAdsProduct!);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Restore previous purchases.
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID == removeAdsProductId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          // Grant premium access
          _purchaseController.add(true);
          debugPrint('Premium unlocked!');
        }
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    }
  }

  void dispose() {
    _purchaseController.close();
  }
}

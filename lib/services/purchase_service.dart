import 'dart:developer';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/feature_flags.dart';

class PurchaseService {
  static const _kPremiumProductId = 'premium_monthly';

  static Future<void> initialize() async {
    // Restore previous state
    final p = await SharedPreferences.getInstance();
    FeatureFlags.isPremiumEnabled = p.getBool('premium') ?? false;
  }

  static Future<void> buyPremium() async {
    try {
      if (kIsWeb) {
        // Web does not support in_app_purchase; use demo unlock or Stripe on web.
        return;
      }
      final available = await InAppPurchase.instance.isAvailable();
      if (!available) return;
      final response = await InAppPurchase.instance
          .queryProductDetails({_kPremiumProductId});
      if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
        return;
      }
      final purchaseParam =
          PurchaseParam(productDetails: response.productDetails.first);
      await InAppPurchase.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
      // NOTE: In a real app, verify purchase on server then unlock.
    } catch (e) {
      log('Purchase flow error: $e');
    }
  }

  static Future<void> unlockForDemo() async {
    final p = await SharedPreferences.getInstance();
    FeatureFlags.isPremiumEnabled = true;
    await p.setBool('premium', true);
  }
}

import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseManager {
  static const removeAdsProductId = 'remove_ads';
  static const _prefsKey = 'ads_removed';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _removeAdsProduct;
  bool _adsRemoved = false;

  void Function(bool adsRemoved)? onAdsRemovedChanged;

  bool get adsRemoved => _adsRemoved;
  bool get isRemoveAdsAvailable => _removeAdsProduct != null;
  String? get removeAdsPrice => _removeAdsProduct?.price;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _adsRemoved = prefs.getBool(_prefsKey) ?? false;

    if (!await _iap.isAvailable()) return;

    _subscription = _iap.purchaseStream.listen(_onPurchaseUpdate);

    final response = await _iap.queryProductDetails({removeAdsProductId});
    if (response.productDetails.isNotEmpty) {
      _removeAdsProduct = response.productDetails.first;
    }

    await _iap.restorePurchases();
  }

  Future<void> buyRemoveAds() async {
    final product = _removeAdsProduct;
    if (product == null) return;
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == removeAdsProductId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        await _setAdsRemoved(true);
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _setAdsRemoved(bool value) async {
    if (_adsRemoved == value) return;
    _adsRemoved = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
    onAdsRemovedChanged?.call(value);
  }

  void dispose() => _subscription?.cancel();
}

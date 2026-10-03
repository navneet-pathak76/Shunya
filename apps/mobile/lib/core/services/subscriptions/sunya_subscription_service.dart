import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

const sunyaAiMonthlyProductId = 'sunya_ai_monthly';

final sunyaSubscriptionProvider = Provider<SunyaSubscriptionService>((ref) {
  final service = SunyaSubscriptionService();
  ref.onDispose(service.dispose);
  service.initialize();
  return service;
});

class SunyaSubscriptionService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? monthlyProduct;
  bool available = false;
  bool active = false;

  Future<void> initialize() async {
    available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(
      _handlePurchases,
      onError: (_) {},
    );

    final response = await _iap.queryProductDetails({sunyaAiMonthlyProductId});
    if (response.productDetails.isNotEmpty) {
      monthlyProduct = response.productDetails.first;
    }
  }

  Future<bool> purchaseMonthly() async {
    final product = monthlyProduct;
    if (product == null || !available) return false;

    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _handlePurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID != sunyaAiMonthlyProductId) continue;
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        active = true;
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void dispose() => _subscription?.cancel();
}

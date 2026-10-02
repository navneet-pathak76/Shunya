import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../ai/sunya_ai_provider.dart';

const sunyaAiMonthlyProductId = 'sunya_ai_monthly';

final sunyaSubscriptionServiceProvider = Provider((ref) {
  final service = SunyaSubscriptionService(
    ref.read(sunyaAiProviderControllerProvider.notifier),
  );
  ref.onDispose(service.dispose);
  return service;
});

class SunyaSubscriptionService {
  SunyaSubscriptionService(this.accessController);

  final SunyaAiProviderController accessController;
  final InAppPurchase _store = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? monthlyProduct;

  Future<void> initialize() async {
    if (!kIsWeb) {
      _subscription ??= _store.purchaseStream.listen(_onPurchases);
    }
    await loadProduct();
  }

  Future<bool> loadProduct() async {
    if (kIsWeb) return false;
    final available = await _store.isAvailable();
    if (!available) return false;
    final response = await _store.queryProductDetails({sunyaAiMonthlyProductId});
    if (response.productDetails.isEmpty) return false;
    monthlyProduct = response.productDetails.first;
    return true;
  }

  Future<void> startTrial() => accessController.startSevenDayTrial();

  Future<bool> purchaseMonthly() async {
    final product = monthlyProduct;
    if (product == null) {
      await loadProduct();
    }
    final selected = monthlyProduct;
    if (selected == null) return false;
    return _store.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: selected),
    );
  }

  Future<void> restore() => _store.restorePurchases();

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != sunyaAiMonthlyProductId) continue;
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await accessController.setPremium(true);
      }
      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

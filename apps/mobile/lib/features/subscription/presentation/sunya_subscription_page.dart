import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/widgets/sunya_glass.dart';

const sunyaSubscriptionProductId = 'sunya_ai_monthly';

final sunyaBillingProvider = ChangeNotifierProvider<SunyaBillingController>((ref) => SunyaBillingController());

class SunyaBillingController extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> products = [];
  bool available = false;
  bool busy = false;
  String? error;

  SunyaBillingController() {
    _subscription = _iap.purchaseStream.listen(_handlePurchases);
    load();
  }

  Future<void> load() async {
    available = await _iap.isAvailable();
    if (!available) { notifyListeners(); return; }
    final response = await _iap.queryProductDetails({sunyaSubscriptionProductId});
    products = response.productDetails;
    error = response.error?.message;
    notifyListeners();
  }

  Future<void> buy() async {
    if (products.isEmpty) return;
    busy = true;
    error = null;
    notifyListeners();
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: products.first));
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.error) {
        error = purchase.error?.message ?? 'Purchase failed';
      }
      if (purchase.pendingCompletePurchase) await _iap.completePurchase(purchase);
    }
    busy = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class SunyaSubscriptionPage extends ConsumerWidget {
  const SunyaSubscriptionPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billing = ref.watch(sunyaBillingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('SUNYA AI')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('SUNYA AI', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          const Text('Personal health intelligence built around your complete SUNYA baseline, history and daily changes.'),
          const SizedBox(height: 20),
          const SunyaGlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('7-day free trial', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('Then ₹99/month as the initial launch price. The exact Play Store price is controlled by your configured subscription product.'),
            ]),
          ),
          const SizedBox(height: 12),
          const SunyaGlassCard(child: Text('Includes deeper cross-data analysis, personalized daily priorities, trend interpretation, adaptive planning and SUNYA-specific health intelligence.')),
          const SizedBox(height: 20),
          if (!billing.available)
            const Text('Google Play billing is unavailable in this build/device.')
          else if (billing.products.isEmpty)
            const Text('SUNYA AI subscription is not yet published/configured in Google Play Console.')
          else
            SunyaPrimaryButton(
              label: billing.busy ? 'Processing…' : 'Start SUNYA AI',
              icon: Icons.bolt_rounded,
              onPressed: billing.busy ? null : billing.buy,
            ),
          if (billing.error != null) ...[
            const SizedBox(height: 12),
            Text(billing.error!),
          ],
        ],
      ),
    );
  }
}

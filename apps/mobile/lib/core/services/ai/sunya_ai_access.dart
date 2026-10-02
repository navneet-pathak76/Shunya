import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SunyaAiProvider { chatgpt, gemini, claude, sunya }

extension SunyaAiProviderX on SunyaAiProvider {
  String get label => switch (this) {
        SunyaAiProvider.chatgpt => 'ChatGPT',
        SunyaAiProvider.gemini => 'Gemini',
        SunyaAiProvider.claude => 'Claude',
        SunyaAiProvider.sunya => 'SUNYA AI',
      };

  String get key => name;

  String get description => switch (this) {
        SunyaAiProvider.chatgpt => 'OpenAI models using your configured connection.',
        SunyaAiProvider.gemini => 'Google Gemini models using your configured connection.',
        SunyaAiProvider.claude => 'Anthropic Claude models using your configured connection.',
        SunyaAiProvider.sunya => 'SUNYA health intelligence: one model layer built around your complete personal context.',
      };
}

class SunyaAiAccess {
  const SunyaAiAccess({
    this.provider = SunyaAiProvider.sunya,
    this.email,
    this.displayName,
    this.trialStartedAt,
    this.subscriptionActive = false,
    this.admin = false,
  });

  final SunyaAiProvider provider;
  final String? email;
  final String? displayName;
  final DateTime? trialStartedAt;
  final bool subscriptionActive;
  final bool admin;

  bool get trialActive {
    final started = trialStartedAt;
    return started != null && DateTime.now().isBefore(started.add(const Duration(days: 7)));
  }

  int get trialDaysRemaining {
    final started = trialStartedAt;
    if (started == null) return 0;
    final remaining = started.add(const Duration(days: 7)).difference(DateTime.now()).inHours;
    return remaining <= 0 ? 0 : ((remaining + 23) ~/ 24);
  }

  bool get sunyaUnlocked => admin || subscriptionActive || trialActive;

  SunyaAiAccess copyWith({
    SunyaAiProvider? provider,
    String? email,
    String? displayName,
    DateTime? trialStartedAt,
    bool? subscriptionActive,
    bool? admin,
  }) =>
      SunyaAiAccess(
        provider: provider ?? this.provider,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        trialStartedAt: trialStartedAt ?? this.trialStartedAt,
        subscriptionActive: subscriptionActive ?? this.subscriptionActive,
        admin: admin ?? this.admin,
      );
}

final sunyaAiAccessProvider =
    StateNotifierProvider<SunyaAiAccessController, SunyaAiAccess>(
  (ref) => SunyaAiAccessController()..load(),
);

class SunyaAiAccessController extends StateNotifier<SunyaAiAccess> {
  SunyaAiAccessController() : super(const SunyaAiAccess());

  static const productId = 'sunya_ai_monthly';
  static const adminEmail = String.fromEnvironment('SUNYA_ADMIN_EMAIL');

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final providerName = p.getString('sunya.ai.provider') ?? 'sunya';
    final started = p.getString('sunya.ai.trialStartedAt');
    final email = p.getString('sunya.account.email');
    state = state.copyWith(
      provider: SunyaAiProvider.values.firstWhere(
        (value) => value.name == providerName,
        orElse: () => SunyaAiProvider.sunya,
      ),
      email: email,
      displayName: p.getString('sunya.account.name'),
      trialStartedAt: started == null ? null : DateTime.tryParse(started),
      subscriptionActive: p.getBool('sunya.ai.subscription') ?? false,
      admin: email != null &&
          adminEmail.isNotEmpty &&
          email.toLowerCase() == adminEmail.toLowerCase(),
    );
  }

  Future<void> setProvider(SunyaAiProvider provider) async {
    state = state.copyWith(provider: provider);
    final p = await SharedPreferences.getInstance();
    await p.setString('sunya.ai.provider', provider.name);
  }

  Future<void> setAccount({
    required String email,
    String? displayName,
  }) async {
    final p = await SharedPreferences.getInstance();
    final existingTrial = p.getString('sunya.ai.trialStartedAt');
    final trial = existingTrial == null
        ? DateTime.now().toUtc()
        : DateTime.tryParse(existingTrial);
    await p.setString('sunya.account.email', email);
    if (displayName != null && displayName.trim().isNotEmpty) {
      await p.setString('sunya.account.name', displayName.trim());
    }
    if (existingTrial == null && trial != null) {
      await p.setString('sunya.ai.trialStartedAt', trial.toIso8601String());
    }
    state = state.copyWith(
      email: email,
      displayName: displayName,
      trialStartedAt: trial,
      admin: adminEmail.isNotEmpty &&
          email.toLowerCase() == adminEmail.toLowerCase(),
    );
  }

  Future<void> setSubscriptionActive(bool active) async {
    state = state.copyWith(subscriptionActive: active);
    final p = await SharedPreferences.getInstance();
    await p.setBool('sunya.ai.subscription', active);
  }
}

class SunyaSubscriptionService {
  final InAppPurchase _store = InAppPurchase.instance;

  Future<bool> get available => _store.isAvailable();

  Future<List<ProductDetails>> loadProducts() async {
    final response = await _store.queryProductDetails(
      {SunyaAiAccessController.productId},
    );
    return response.productDetails;
  }

  Future<bool> purchaseMonthly(ProductDetails product) async {
    return _store.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Stream<List<PurchaseDetails>> get purchaseUpdates => _store.purchaseStream;

  Future<void> complete(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _store.completePurchase(purchase);
    }
  }
}

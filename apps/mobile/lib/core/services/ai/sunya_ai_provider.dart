import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SunyaAiProvider {
  chatgpt,
  gemini,
  claude,
  sunya,
}

extension SunyaAiProviderX on SunyaAiProvider {
  String get key => switch (this) {
        SunyaAiProvider.chatgpt => 'chatgpt',
        SunyaAiProvider.gemini => 'gemini',
        SunyaAiProvider.claude => 'claude',
        SunyaAiProvider.sunya => 'sunya',
      };

  String get label => switch (this) {
        SunyaAiProvider.chatgpt => 'ChatGPT',
        SunyaAiProvider.gemini => 'Gemini',
        SunyaAiProvider.claude => 'Claude',
        SunyaAiProvider.sunya => 'SUNYA AI',
      };

  String get description => switch (this) {
        SunyaAiProvider.chatgpt => 'OpenAI models',
        SunyaAiProvider.gemini => 'Google Gemini models',
        SunyaAiProvider.claude => 'Anthropic Claude models',
        SunyaAiProvider.sunya => 'SUNYA personal health intelligence',
      };
}

class SunyaAiAccess {
  const SunyaAiAccess({
    required this.provider,
    required this.trialActive,
    required this.trialEndsAt,
    required this.premium,
  });

  final SunyaAiProvider provider;
  final bool trialActive;
  final DateTime? trialEndsAt;
  final bool premium;
}

final sunyaAiProviderControllerProvider =
    StateNotifierProvider<SunyaAiProviderController, SunyaAiProvider>(
  (ref) => SunyaAiProviderController()..load(),
);

final sunyaAiAccessProvider = Provider<SunyaAiAccess>((ref) {
  final provider = ref.watch(sunyaAiProviderControllerProvider);
  final controller = ref.read(sunyaAiProviderControllerProvider.notifier);
  return SunyaAiAccess(
    provider: provider,
    trialActive: controller.trialActive,
    trialEndsAt: controller.trialEndsAt,
    premium: controller.premium,
  );
});

class SunyaAiProviderController extends StateNotifier<SunyaAiProvider> {
  SunyaAiProviderController() : super(SunyaAiProvider.sunya);

  DateTime? trialEndsAt;
  bool premium = false;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final key = p.getString('sunya.ai.provider') ?? 'sunya';
    state = SunyaAiProvider.values.firstWhere(
      (e) => e.key == key,
      orElse: () => SunyaAiProvider.sunya,
    );
    final trial = p.getString('sunya.ai.trialEndsAt');
    trialEndsAt = trial == null ? null : DateTime.tryParse(trial);
    premium = p.getBool('sunya.ai.premium') ?? false;
  }

  bool get trialActive =>
      trialEndsAt != null && DateTime.now().isBefore(trialEndsAt!);

  bool get premiumAccess => premium || trialActive;

  Future<void> select(SunyaAiProvider provider) async {
    state = provider;
    final p = await SharedPreferences.getInstance();
    await p.setString('sunya.ai.provider', provider.key);
  }

  Future<void> startSevenDayTrial() async {
    final p = await SharedPreferences.getInstance();
    final existing = p.getString('sunya.ai.trialEndsAt');
    if (existing != null) {
      trialEndsAt = DateTime.tryParse(existing);
      return;
    }
    trialEndsAt = DateTime.now().add(const Duration(days: 7));
    await p.setString('sunya.ai.trialEndsAt', trialEndsAt!.toIso8601String());
    state = SunyaAiProvider.sunya;
  }

  Future<void> setPremium(bool value) async {
    premium = value;
    final p = await SharedPreferences.getInstance();
    await p.setBool('sunya.ai.premium', value);
  }
}

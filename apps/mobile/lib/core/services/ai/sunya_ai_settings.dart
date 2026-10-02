import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SunyaAiProvider { chatgpt, gemini, claude, sunya }

extension SunyaAiProviderX on SunyaAiProvider {
  String get label => switch (this) {
    SunyaAiProvider.chatgpt => 'ChatGPT',
    SunyaAiProvider.gemini => 'Gemini',
    SunyaAiProvider.claude => 'Claude',
    SunyaAiProvider.sunya => 'SUNYA AI',
  };

  String get description => switch (this) {
    SunyaAiProvider.chatgpt => 'OpenAI model provider',
    SunyaAiProvider.gemini => 'Google Gemini provider',
    SunyaAiProvider.claude => 'Anthropic Claude provider',
    SunyaAiProvider.sunya => 'SUNYA personal health intelligence',
  };

  bool get premium => this == SunyaAiProvider.sunya;
}

class SunyaAiSettings {
  const SunyaAiSettings({
    this.provider = SunyaAiProvider.sunya,
    this.trialStartedAt,
  });

  final SunyaAiProvider provider;
  final DateTime? trialStartedAt;

  bool get trialAvailable => trialStartedAt == null;
  bool get trialActive =>
      trialStartedAt != null &&
      DateTime.now().isBefore(trialStartedAt!.add(const Duration(days: 7)));

  int get trialDaysRemaining {
    if (!trialActive) return 0;
    final remaining = trialStartedAt!
        .add(const Duration(days: 7))
        .difference(DateTime.now())
        .inHours;
    return ((remaining + 23) ~/ 24).clamp(0, 7);
  }
}

final sunyaAiSettingsProvider =
    StateNotifierProvider<SunyaAiSettingsController, SunyaAiSettings>(
  (ref) => SunyaAiSettingsController()..load(),
);

class SunyaAiSettingsController extends StateNotifier<SunyaAiSettings> {
  SunyaAiSettingsController() : super(const SunyaAiSettings());

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final value = p.getString('sunya.aiProvider') ?? 'sunya';
    final trial = p.getString('sunya.aiTrialStartedAt');
    state = SunyaAiSettings(
      provider: SunyaAiProvider.values.firstWhere(
        (x) => x.name == value,
        orElse: () => SunyaAiProvider.sunya,
      ),
      trialStartedAt: trial == null ? null : DateTime.tryParse(trial),
    );
  }

  Future<void> select(SunyaAiProvider provider) async {
    state = SunyaAiSettings(provider: provider, trialStartedAt: state.trialStartedAt);
    final p = await SharedPreferences.getInstance();
    await p.setString('sunya.aiProvider', provider.name);
  }

  Future<void> startTrial() async {
    if (!state.trialAvailable) return;
    final now = DateTime.now();
    state = SunyaAiSettings(provider: SunyaAiProvider.sunya, trialStartedAt: now);
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setString('sunya.aiProvider', SunyaAiProvider.sunya.name),
      p.setString('sunya.aiTrialStartedAt', now.toIso8601String()),
    ]);
  }
}

class SunyaAiProviderIcon extends StatelessWidget {
  const SunyaAiProviderIcon({super.key, required this.provider});
  final SunyaAiProvider provider;
  @override
  Widget build(BuildContext context) => Icon(
    switch (provider) {
      SunyaAiProvider.chatgpt => Icons.auto_awesome,
      SunyaAiProvider.gemini => Icons.diamond_outlined,
      SunyaAiProvider.claude => Icons.psychology_outlined,
      SunyaAiProvider.sunya => Icons.bolt_rounded,
    },
  );
}

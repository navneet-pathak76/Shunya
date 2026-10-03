import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ai/sunya_ai_settings.dart';
import '../../../core/widgets/sunya_glass.dart';

class AiProvidersPage extends ConsumerWidget {
  const AiProvidersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(sunyaAiSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('AI Providers')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Choose your intelligence layer', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          const Text('SUNYA keeps one normalized health context so you can switch providers without rebuilding your profile.'),
          const SizedBox(height: 18),
          for (final provider in SunyaAiProvider.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SunyaGlassCard(
                child: RadioListTile<SunyaAiProvider>(
                  value: provider,
                  groupValue: settings.provider,
                  onChanged: (value) {
                    if (value == null) return;
                    if (value == SunyaAiProvider.sunya && !settings.premium && !settings.trialActive) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start the 7-day SUNYA AI trial or subscribe to unlock SUNYA AI.')));
                      return;
                    }
                    ref.read(sunyaAiSettingsProvider.notifier).select(value);
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Row(children: [
                    SunyaAiProviderIcon(provider: provider),
                    const SizedBox(width: 10),
                    Text(provider.label),
                    if (provider.premium) ...[
                      const SizedBox(width: 8),
                      const Chip(label: Text('Premium')),
                    ],
                  ]),
                  subtitle: Text(provider.description),
                ),
              ),
            ),
          if (settings.trialActive)
            SunyaGlassCard(child: Text('SUNYA AI trial active • ' + settings.trialDaysRemaining.toString() + ' day(s) remaining'))
          else if (settings.trialAvailable)
            SunyaPrimaryButton(
              label: 'Start 7-day SUNYA AI trial',
              icon: Icons.bolt_rounded,
              onPressed: () => ref.read(sunyaAiSettingsProvider.notifier).startTrial(),
            )
          else
            const SunyaGlassCard(child: Text('Your 7-day SUNYA AI trial has ended. Choose a subscription to continue.')),
          const SizedBox(height: 14),
          const SunyaGlassCard(
            child: Text('AI providers receive only the context sent by SUNYA for a request. Review each provider’s current privacy terms before sending sensitive information.'),
          ),
        ],
      ),
    );
  }
}

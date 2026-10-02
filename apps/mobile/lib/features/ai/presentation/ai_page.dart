import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/ai/ai_gateway.dart';
import '../../../core/services/ai/adaptive_health_engine.dart';
import '../../../core/services/ai/health_context_builder.dart';
import '../../../core/services/ai/sunya_ai_settings.dart';
import '../../../core/settings/sunya_settings.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../../health_connect/presentation/health_connect_page.dart';
import '../../body/presentation/body_controller.dart';
import '../../hydration/presentation/hydration_controller.dart';
import '../../nutrition/presentation/nutrition_controller.dart';
import '../../sleep/presentation/sleep_controller.dart';

class AiPage extends ConsumerStatefulWidget {
  const AiPage({super.key});
  @override
  ConsumerState<AiPage> createState() => _AiPageState();
}

class _AiPageState extends ConsumerState<AiPage> {
  final input = TextEditingController();
  final messages = <String>[];
  bool loading = false;

  Future<void> ask() async {
    final q = input.text.trim();
    if (q.isEmpty || loading) return;
    input.clear();
    setState(() { messages.add('You: $q'); loading = true; });

    try {
      final provider = ref.read(sunyaAiSettingsProvider).provider;
      final aiSettings = ref.read(sunyaAiSettingsProvider);
      if (provider == SunyaAiProvider.sunya && !aiSettings.premium && !aiSettings.trialActive) {
        if (mounted) {
          setState(() {
            messages.add('SUNYA AI includes a 7-day free trial. Start the trial from the SUNYA AI plan screen to use the full personal intelligence layer.');
            loading = false;
          });
        }
        return;
      }

      final body = ref.read(bodyProvider);
      final hyd = ref.read(hydrationProvider);
      final nut = ref.read(nutritionProvider);
      final sleep = ref.read(sleepProvider);
      final health = await ref.read(healthSnapshotProvider.future);
      final settings = ref.read(sunyaSettingsProvider);
      final dob = body.profile?.dateOfBirth;
      final age = dob == null ? null : (DateTime.now().difference(dob).inDays / 365.25).floor();

      final plan = AdaptiveHealthEngine.build(
        HealthProfileInput(
          weightKg: body.weightKg,
          heightCm: body.heightCm,
          ageYears: age,
          sex: body.profile?.biologicalSex,
          hydrationMl: hyd.consumedMl,
          proteinConsumed: nut.protein,
          sleepHours: sleep.latest?.hours,
          dailySteps: health.steps,
          goal: settings.goal,
        ),
      );

      final context = SunyaHealthContextBuilder.build(
        body: body,
        hydration: hyd,
        nutrition: nut,
        sleep: sleep,
        health: health,
        name: settings.name,
        goal: settings.goal,
      );
      context['derivedPlan'] = {
        'bmi': plan.bmi,
        'bmr': plan.bmr,
        'calorieTarget': plan.calorieTarget,
        'proteinTarget': plan.proteinTarget,
        'waterTargetMl': plan.waterTargetMl,
        'recoveryScore': plan.recoveryScore,
        'trainingMode': plan.trainingMode,
        'priority': plan.priority,
        'actions': plan.actions,
      };

      final remote = await SunyaAiGateway().chat(
        message: q,
        provider: provider,
        context: context,
      );
      final answer = remote ??
          'AI provider is not configured or temporarily unavailable. Current local analysis: ${plan.priority} is the main priority. ${plan.actions.first}';
      if (mounted) setState(() { messages.add(answer); loading = false; });
    } catch (_) {
      if (mounted) setState(() { messages.add('SUNYA could not complete the analysis. Your local health data is still stored on this device.'); loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiSettings = ref.watch(sunyaAiSettingsProvider);
    final provider = aiSettings.provider;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SUNYA AI'),
        actions: [
          IconButton(
            tooltip: 'SUNYA AI plan',
            onPressed: () => context.push('/subscription'),
            icon: const Icon(Icons.workspace_premium_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                Text('Personal intelligence', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                const Text('One context layer combines Health Connect with everything you manually record in SUNYA. The selected AI analyses that combined history.'),
                const SizedBox(height: 16),
                SunyaGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Choose AI', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<SunyaAiProvider>(
                        value: provider,
                        decoration: const InputDecoration(labelText: 'AI provider'),
                        items: SunyaAiProvider.values.map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.label),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) ref.read(sunyaAiSettingsProvider.notifier).select(value);
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(provider.description),
                      if (provider == SunyaAiProvider.sunya) ...[
                        const SizedBox(height: 8),
                        Text(aiSettings.trialActive ? 'SUNYA AI trial active' : aiSettings.premium ? 'SUNYA AI premium active' : '7-day free trial available'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (messages.isEmpty)
                  const SunyaGlassCard(child: Text('Ask: “What is changing in my body, recovery, nutrition and sleep, and what should I focus on today?”')),
                ...messages.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SunyaGlassCard(child: Text(m)),
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(child: TextField(
                  controller: input,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(hintText: 'Ask about your health…'),
                )),
                IconButton(
                  onPressed: loading ? null : ask,
                  icon: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }
}

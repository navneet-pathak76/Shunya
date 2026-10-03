import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/ai/ai_gateway.dart';
import '../../../core/services/ai/adaptive_health_engine.dart';
import '../../../core/settings/sunya_settings.dart';
import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../../../core/widgets/sunya_logo.dart';
import '../../../core/services/subscriptions/sunya_subscription_service.dart';
import '../../health_connect/presentation/health_connect_page.dart';
import '../../body/presentation/body_controller.dart';
import '../../hydration/presentation/hydration_controller.dart';
import '../../nutrition/presentation/nutrition_controller.dart';
import '../../sleep/presentation/sleep_controller.dart';

class AiPage extends ConsumerStatefulWidget {
  const AiPage({super.key});
  @override ConsumerState<AiPage> createState() => _AiPageState();
}

class _AiPageState extends ConsumerState<AiPage> {
  final input = TextEditingController();
  final messages = <String>[];
  bool loading = false;

  Future<void> ask() async {
    final q = input.text.trim();
    if (q.isEmpty) return;
    input.clear();
    setState(() { messages.add('You: ' + q); loading = true; });

    final settings = ref.read(sunyaSettingsProvider);
    final selected = SunyaAiProvider.values.firstWhere(
      (p) => p.key == settings.aiProvider,
      orElse: () => SunyaAiProvider.sunya,
    );

    if (selected == SunyaAiProvider.sunya && !settings.sunyaAccess) {
      setState(() {
        messages.add('SUNYA AI requires its 7-day free trial or premium access. Start the trial below, or choose ChatGPT, Gemini or Claude.');
        loading = false;
      });
      return;
    }

    final body = ref.read(bodyProvider);
    final hyd = ref.read(hydrationProvider);
    final nut = ref.read(nutritionProvider);
    final sleep = ref.read(sleepProvider);
    final health = await ref.read(healthSnapshotProvider.future);
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
      ),
    );

    final context = {
      'profile': {
        'name': settings.name,
        'age': age ?? settings.age,
        'heightCm': body.heightCm ?? settings.heightCm,
        'weightKg': body.weightKg ?? settings.weightKg,
        'goal': settings.goal,
      },
      'trackedData': {
        'body': {
          'bmi': plan.bmi,
          'weightKg': body.weightKg,
          'bodyFatPercent': body.bodyFatPercent,
          'measurements': body.measurements.length,
        },
        'nutrition': {'calories': nut.calories, 'protein': nut.protein, 'meals': nut.meals.length},
        'hydration': {'consumedMl': hyd.consumedMl},
        'sleep': {'latestHours': sleep.latest?.hours, 'averageHours': sleep.averageHours, 'entries': sleep.entries.length},
        'healthConnect': {
          'steps': health.steps,
          'activeCalories': health.activeCalories,
          'totalCalories': health.totalCalories,
          'waterMl': health.waterMl,
          'sleepHours': health.sleepHours,
          'weightKg': health.weightKg,
          'heartRate': health.heartRate,
          'restingHeartRate': health.restingHeartRate,
          'hrv': health.hrv,
          'spo2': health.oxygen,
          'records': health.records,
        },
      },
      'derivedPlan': {
        'recovery': plan.recoveryScore,
        'priority': plan.priority,
        'caloriesTarget': plan.calorieTarget,
        'proteinTarget': plan.proteinTarget,
        'waterTargetMl': plan.waterTargetMl,
        'trainingMode': plan.trainingMode,
        'actions': plan.actions,
      },
    };

    final remote = await SunyaAiGateway().chat(
      message: q,
      provider: selected,
      context: context,
    );
    final answer = remote ?? ('SUNYA: ' + plan.priority + ' is the current priority. ' + plan.actions.first);

    if (mounted) setState(() { messages.add(answer); loading = false; });
  }

  Future<void> startTrial() async {
    final current = ref.read(sunyaSettingsProvider);
    await ref.read(sunyaSettingsProvider.notifier).update(
      current.copyWith(
        aiProvider: SunyaAiProvider.sunya.key,
        sunyaTrialStartedAt: current.sunyaTrialStartedAt ?? DateTime.now(),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(sunyaSettingsProvider);
    final provider = SunyaAiProvider.values.firstWhere(
      (p) => p.key == settings.aiProvider,
      orElse: () => SunyaAiProvider.sunya,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('SUNYA AI'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Chip(
              avatar: const Icon(Icons.auto_awesome, size: 16),
              label: Text(provider.label),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SunyaLogo(size: 90, showWordmark: true),
          const SizedBox(height: 24),
          Text('Choose your intelligence layer', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          const Text('Every provider receives the same structured SUNYA health context. SUNYA analyzes tracked history first, then the selected model turns it into personalized guidance.'),
          const SizedBox(height: 18),
          _providerSelector(settings, provider),
          const SizedBox(height: 14),
          if (!settings.sunyaAccess)
            SunyaGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SUNYA AI Premium', style: TextStyle(color: SunyaTheme.gold, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Start with a 7-day free trial. Premium is planned at ₹99/month, with deeper cross-domain analysis, personalized plans and the SUNYA model.'),
                  const SizedBox(height: 14),
                  SunyaPrimaryButton(label: 'Start 7-day free trial', icon: Icons.auto_awesome, onPressed: startTrial),
                  const SizedBox(height: 10),
                  SunyaPrimaryButton(
                    label: 'Subscribe ₹99/month',
                    icon: Icons.workspace_premium_outlined,
                    onPressed: () async {
                      final service = ref.read(sunyaSubscriptionProvider);
                      final started = await service.purchaseMonthly();
                      if (started && mounted) {
                        final current = ref.read(sunyaSettingsProvider);
                        await ref.read(sunyaSettingsProvider.notifier).update(
                          current.copyWith(sunyaPremium: true, aiProvider: SunyaAiProvider.sunya.key),
                        );
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 18),
          if (messages.isEmpty)
            const SunyaGlassCard(child: Text('Ask: “Analyze my body, sleep, nutrition, hydration and activity together. What should I change today?”')),
          ...messages.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SunyaGlassCard(child: Text(m)),
          )),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: input,
                  onSubmitted: loading ? null : (_) => ask(),
                  decoration: const InputDecoration(
                    hintText: 'Ask your health intelligence…',
                    prefixIcon: Icon(Icons.chat_bubble_outline),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: loading ? null : ask,
                icon: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _providerSelector(SunyaSettings settings, SunyaAiProvider provider) {
    return SunyaGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI provider', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SunyaAiProvider.values.map((item) {
              final selected = item == provider;
              final locked = item == SunyaAiProvider.sunya && !settings.sunyaAccess;
              return ChoiceChip(
                selected: selected,
                label: Text(item.label),
                avatar: Icon(item == SunyaAiProvider.sunya ? Icons.auto_awesome : Icons.psychology_outlined, size: 17),
                onSelected: (_) async {
                  if (locked) {
                    await startTrial();
                    return;
                  }
                  await ref.read(sunyaSettingsProvider.notifier).update(
                    ref.read(sunyaSettingsProvider).copyWith(aiProvider: item.key),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            provider == SunyaAiProvider.sunya && settings.sunyaAccess
                ? (settings.sunyaPremium
                    ? 'SUNYA AI Premium active.'
                    : 'SUNYA AI trial active — ' + (7 - DateTime.now().difference(settings.sunyaTrialStartedAt!).inDays).toString() + ' days remaining.')
                : 'ChatGPT, Gemini and Claude are available as external AI providers.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { input.dispose(); super.dispose(); }
}

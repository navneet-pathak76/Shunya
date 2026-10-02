import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/ai/ai_gateway.dart';
import '../../../core/services/ai/adaptive_health_engine.dart';
import '../../../core/services/ai/sunya_ai_settings.dart';
import '../../../core/services/ai/personal_baseline_engine.dart';
import '../../../core/widgets/sunya_glass.dart';
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

    try {
      final body = ref.read(bodyProvider);
      final hyd = ref.read(hydrationProvider);
      final nut = ref.read(nutritionProvider);
      final sleep = ref.read(sleepProvider);
      final health = await ref.read(healthSnapshotProvider.future);
      final ai = ref.read(sunyaAiSettingsProvider);
      final dob = body.profile?.dateOfBirth;
      final age = dob == null ? null : (DateTime.now().difference(dob).inDays / 365.25).floor();

      final previousWeight = body.measurements.length > 1 ? body.measurements[body.measurements.length - 2].weightKg : null;
      final previousBodyFat = body.measurements.length > 1 ? body.measurements[body.measurements.length - 2].bodyFatPercent : null;
      final previousSleep = sleep.entries.length > 1 ? sleep.entries[1].hours : null;
      final plan = AdaptiveHealthEngine.build(
        HealthProfileInput(
          weightKg: body.weightKg ?? health.weightKg,
          heightCm: body.heightCm ?? health.heightCm,
          ageYears: age,
          sex: body.profile?.biologicalSex,
          hydrationMl: hyd.consumedMl + health.waterMl.round(),
          proteinConsumed: nut.protein,
          sleepHours: sleep.latest?.hours ?? (health.sleepHours == 0 ? null : health.sleepHours),
          dailySteps: health.steps,
          goal: 'maintain',
        ),
      );

      final baseline = PersonalBaselineEngine.build(
        currentWeight: body.weightKg ?? health.weightKg,
        previousWeight: previousWeight,
        bodyFat: body.bodyFatPercent ?? health.bodyFatPercent,
        previousBodyFat: previousBodyFat,
        sleepHours: sleep.latest?.hours ?? (health.sleepHours == 0 ? null : health.sleepHours),
        previousSleepHours: previousSleep,
        steps: health.steps,
        waterMl: hyd.consumedMl + health.waterMl,
        waterTargetMl: plan.waterTargetMl.toDouble(),
        restingHeartRate: health.restingHeartRate,
        previousRestingHeartRate: health.restingHeartRate,
      );

      final context = {
        'personalBaseline': baseline.toJson(),
        'userProfile': {
          'name': body.profile?.name,
          'ageYears': age,
          'weightKg': body.weightKg ?? health.weightKg,
          'heightCm': body.heightCm ?? health.heightCm,
          'bodyFatPercent': body.bodyFatPercent ?? health.bodyFatPercent,
          'bmi': body.bmi ?? health.bmi,
        },
        'tracked': {
          'hydrationMl': hyd.consumedMl,
          'nutritionCalories': nut.calories,
          'nutritionProtein': nut.protein,
          'sleepHours': sleep.latest?.hours ?? health.sleepHours,
        },
        'healthConnect': health.toContext(),
        'adaptivePlan': {
          'recovery': plan.recoveryScore,
          'priority': plan.priority,
          'calories': plan.calorieTarget,
          'protein': plan.proteinTarget,
          'waterMl': plan.waterTargetMl,
          'trainingMode': plan.trainingMode,
          'actions': plan.actions,
        },
        'ai': {
          'provider': ai.provider.name,
          'sunyaTrialActive': ai.trialActive,
        },
      };

      final remote = await SunyaAiGateway().chat(
        message: q,
        provider: ai.provider,
        context: context,
      );
      final answer = remote ??
          'SUNYA: ' + plan.priority + ' is the current priority. ' + plan.actions.first;
      if (mounted) setState(() { messages.add(answer); loading = false; });
    } catch (e) {
      if (mounted) setState(() {
        messages.add('SUNYA: I could not complete the health analysis. Check your connected data and try again.');
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ai = ref.watch(sunyaAiSettingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SUNYA AI'),
        actions: [
          IconButton(
            tooltip: 'AI providers',
            onPressed: () => context.push('/ai/providers'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Personal intelligence', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Text('Provider: ' + ai.provider.label),
                const SizedBox(height: 12),
                if (ai.provider == SunyaAiProvider.sunya && ai.trialActive)
                  SunyaGlassCard(child: Text('SUNYA AI trial • ' + ai.trialDaysRemaining.toString() + ' days remaining')),
                if (messages.isEmpty)
                  const SunyaGlassCard(child: Text('Ask: “What should I focus on today?”')),
                ...messages.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SunyaGlassCard(child: Text(m)),
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(children: [
              Expanded(child: TextField(controller: input, decoration: const InputDecoration(hintText: 'Ask about your body, health or routine…'))),
              IconButton(
                onPressed: loading ? null : ask,
                icon: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { input.dispose(); super.dispose(); }
}

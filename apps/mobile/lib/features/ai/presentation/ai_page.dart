import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/services/ai/ai_gateway.dart';
import '../../../core/services/ai/adaptive_health_engine.dart';
import '../../../core/services/ai/sunya_ai_access.dart';
import '../../../core/services/auth/sunya_google_auth.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../../../core/providers/database_provider.dart';
import '../../body/presentation/body_controller.dart';
import '../../habits/presentation/habits_controller.dart';
import '../../workout/presentation/workout_controller.dart';
import '../../appearance/presentation/appearance_controller.dart';
import '../../health_connect/presentation/health_connect_page.dart';
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
  final googleAuth = SunyaGoogleAuthService();
  final subscriptions = SunyaSubscriptionService();
  StreamSubscription<List<PurchaseDetails>>? purchaseSubscription;
  bool loading = false;
  bool signingIn = false;

  @override
  void initState() {
    super.initState();
    purchaseSubscription = subscriptions.purchaseUpdates.listen(_handlePurchases);
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != SunyaAiAccessController.productId) continue;
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await ref.read(sunyaAiAccessProvider.notifier).setSubscriptionActive(true);
      }
      await subscriptions.complete(purchase);
    }
  }

  Future<void> _signIn() async {
    setState(() => signingIn = true);
    try {
      final account = await googleAuth.signIn();
      await ref.read(sunyaAiAccessProvider.notifier).setAccount(
            email: account.email,
            displayName: account.displayName,
            idToken: account.idToken,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed in as ' + account.email)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: ' + e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => signingIn = false);
    }
  }

  Future<void> _buySunyaAi() async {
    final products = await subscriptions.loadProducts();
    if (!mounted) return;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SUNYA AI subscription is not configured in Google Play yet.'),
        ),
      );
      return;
    }
    await subscriptions.purchaseMonthly(products.first);
  }

  Future<void> ask() async {
    final q = input.text.trim();
    if (q.isEmpty) return;

    final access = ref.read(sunyaAiAccessProvider);
    if (access.provider == SunyaAiProvider.sunya && !access.sunyaUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your SUNYA AI 7-day trial has ended. Choose a plan to continue.'),
        ),
      );
      return;
    }

    input.clear();
    setState(() {
      messages.add('You: ' + q);
      loading = true;
    });

    final body = ref.read(bodyProvider);
    final hyd = ref.read(hydrationProvider);
    final nut = ref.read(nutritionProvider);
    final sleep = ref.read(sleepProvider);
    final habits = ref.read(habitsProvider);
    final workouts = ref.read(workoutControllerProvider);
    final appearance = ref.read(appearanceProvider);
    final repository = await ref.read(localRecordRepositoryProvider.future);
    final goals = await repository.listDomain('goal');
    final moods = await repository.listDomain('mood');
    final journal = await repository.listDomain('journal');
    final medications = await repository.listDomain('medication');
    final health = await ref.read(healthSnapshotProvider.future);

    final dob = body.profile?.dateOfBirth;
    final age = dob == null
        ? null
        : (DateTime.now().difference(dob).inDays / 365.25).floor();

    final plan = AdaptiveHealthEngine.build(
      HealthProfileInput(
        weightKg: body.weightKg ?? health.weightKg,
        heightCm: body.heightCm ?? health.heightCm,
        ageYears: age,
        sex: body.profile?.biologicalSex,
        hydrationMl: hyd.consumedMl + health.waterMl.round(),
        proteinConsumed: nut.protein,
        sleepHours: sleep.latest?.hours ?? health.sleepHours,
        dailySteps: health.steps,
      ),
    );

    final context = <String, dynamic>{
      'analysisPolicy': {
        'goal': 'Create balanced whole-body guidance from every available user signal.',
        'doNotInventMissingData': true,
        'distinguishMeasuredEstimated': true,
        'medicalSafety':
            'Do not diagnose. Flag potentially concerning values for professional review.',
      },
      'manualAppData': {
        'body': {
          'weightKg': body.weightKg,
          'heightCm': body.heightCm,
          'bodyFatPercent': body.bodyFatPercent,
          'bmi': body.bmi,
          'measurements': body.measurements
              .map((m) => {
                    'date': m.date.toIso8601String(),
                    'weightKg': m.weightKg,
                    'heightCm': m.heightCm,
                    'bodyFatPercent': m.bodyFatPercent,
                  })
              .toList(),
          'regions': body.regionMeasurements
              .map((m) => {
                    'region': m.region.name,
                    'cm': m.centimetres,
                    'date': m.recordedAt.toIso8601String(),
                    'note': m.note,
                  })
              .toList(),
        },
        'hydration': {
          'todayMl': hyd.consumedMl,
          'goalMl': hyd.goalMl,
        },
        'nutrition': {
          'todayCalories': nut.calories,
          'todayProtein': nut.protein,
          'meals': nut.meals.map((m) => m.toJson()).toList(),
        },
        'sleep': {
          'latestHours': sleep.latest?.hours,
          'latestQuality': sleep.latest?.quality,
          'averageHours': sleep.averageHours,
        },
      },
      'healthConnect': health.toAiContext(),
      'habits': habits.items.map((h) => {
            'name': h.name,
            'completedToday': h.completedOn(DateTime.now()),
            'currentStreak': h.currentStreak,
            'completionCount': h.completedDates.length,
          }).toList(),
      'workouts': workouts.map((session) => {
            'startedAt': session.startedAt.toIso8601String(),
            'endedAt': session.endedAt?.toIso8601String(),
            'notes': session.notes,
            'sets': session.sets.map((set) => {
                  'exercise': set.exerciseName,
                  'repetitions': set.repetitions,
                  'weightKg': set.weightKg,
                  'completedAt': set.completedAt.toIso8601String(),
                }).toList(),
          }).toList(),
      'appearance': appearance.map((item) => {
            'capturedAt': item.capturedAt.toIso8601String(),
            'area': item.area.name,
            'notes': item.notes,
            'userScore': item.userScore,
            'hairDensityScore': item.hairDensityScore,
            'beardCoverageScore': item.beardCoverageScore,
            'underEyeScore': item.underEyeScore,
            'skinClarityScore': item.skinClarityScore,
            'hairShedding': item.hairShedding,
            'scalpItch': item.scalpItch,
            'scalpFlaking': item.scalpFlaking,
            'sleepHours': item.sleepHours,
          }).toList(),
      'goals': goals.map((r) => r.payload).toList(),
      'wellness': {
        'mood': moods.map((r) => r.payload).toList(),
        'journal': journal.map((r) => r.payload).toList(),
        'medications': medications.map((r) => r.payload).toList(),
      },
      'deterministicPlan': {
        'recovery': plan.recoveryScore,
        'priority': plan.priority,
        'calories': plan.calorieTarget,
        'protein': plan.proteinTarget,
        'waterMl': plan.waterTargetMl,
        'trainingMode': plan.trainingMode,
        'actions': plan.actions,
      },
    };

    final remote = await SunyaAiGateway().chat(
      message: q,
      provider: access.provider.key,
      idToken: access.idToken,
      context: context,
    );

    final answer = remote ??
        ('SUNYA: ' + plan.priority + ' is the current priority. ' + plan.actions.first);

    if (mounted) {
      setState(() {
        messages.add(answer);
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(sunyaAiAccessProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SUNYA AI'),
        actions: [
          if (access.email == null)
            TextButton.icon(
              onPressed: signingIn ? null : _signIn,
              icon: const Icon(Icons.login_rounded),
              label: Text(signingIn ? '…' : 'Google'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                Text(
                  'Personal intelligence',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 6),
                const Text(
                  'SUNYA combines your Health Connect data and everything you enter manually before generating personalized guidance.',
                ),
                const SizedBox(height: 16),
                _accountCard(context, access),
                const SizedBox(height: 14),
                _providerSelector(context, access),
                const SizedBox(height: 14),
                if (access.provider == SunyaAiProvider.sunya)
                  _sunyaPlanCard(context, access),
                const SizedBox(height: 14),
                if (messages.isEmpty)
                  const SunyaGlassCard(
                    child: Text(
                      'Ask: “Review my whole-body data and tell me what I should focus on today.”',
                    ),
                  ),
                ...messages.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SunyaGlassCard(child: Text(m)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    decoration: const InputDecoration(hintText: 'Ask your health AI…'),
                  ),
                ),
                IconButton(
                  onPressed: loading ? null : ask,
                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountCard(BuildContext context, SunyaAiAccess access) {
    if (access.email == null) {
      return SunyaGlassCard(
        child: Row(
          children: [
            const Icon(Icons.account_circle_outlined, size: 34),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Sign in with Google to sync your SUNYA account, trial and AI preferences.'),
            ),
            FilledButton(
              onPressed: signingIn ? null : _signIn,
              child: const Text('Sign in'),
            ),
          ],
        ),
      );
    }

    final status = access.admin
        ? access.email! + '\nAdmin access • SUNYA AI unlocked'
        : access.email! +
            '\n' +
            (access.trialActive
                ? access.trialDaysRemaining.toString() + ' trial days left'
                : access.subscriptionActive
                    ? 'SUNYA AI subscription active'
                    : 'SUNYA AI trial ended');

    return SunyaGlassCard(
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, size: 30),
          const SizedBox(width: 12),
          Expanded(child: Text(status)),
        ],
      ),
    );
  }

  Widget _providerSelector(BuildContext context, SunyaAiAccess access) {
    return SunyaGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose your AI', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'ChatGPT, Gemini and Claude are external providers. SUNYA AI is the managed personal-health layer.',
          ),
          const SizedBox(height: 12),
          ...SunyaAiProvider.values.map(
            (provider) => RadioListTile<SunyaAiProvider>(
              contentPadding: EdgeInsets.zero,
              value: provider,
              groupValue: access.provider,
              onChanged: (value) {
                if (value != null) {
                  ref.read(sunyaAiAccessProvider.notifier).setProvider(value);
                }
              },
              title: Text(provider.label),
              subtitle: Text(provider.description),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sunyaPlanCard(BuildContext context, SunyaAiAccess access) {
    final unlocked = access.sunyaUnlocked;
    return SunyaGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unlocked ? 'SUNYA AI is available' : 'SUNYA AI',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            access.admin
                ? 'Admin: unlimited access'
                : access.trialActive
                    ? '7-day new-user trial • ' + access.trialDaysRemaining.toString() + ' days remaining'
                    : 'Trial ended • continue with a monthly subscription',
          ),
          const SizedBox(height: 12),
          if (!access.admin && !access.subscriptionActive)
            FilledButton.icon(
              onPressed: _buySunyaAi,
              icon: const Icon(Icons.workspace_premium_outlined),
              label: const Text('Start SUNYA AI — ₹79/month'),
            ),
          if (access.admin)
            const Text('Admin pricing bypass is controlled by SUNYA_ADMIN_EMAIL.'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    purchaseSubscription?.cancel();
    input.dispose();
    super.dispose();
  }
}

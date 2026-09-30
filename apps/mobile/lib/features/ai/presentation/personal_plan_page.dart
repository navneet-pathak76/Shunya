import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ai/adaptive_health_engine.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../../body/presentation/body_controller.dart';
import '../../hydration/presentation/hydration_controller.dart';
import '../../nutrition/presentation/nutrition_controller.dart';
import '../../sleep/presentation/sleep_controller.dart';

class PersonalPlanPage extends ConsumerWidget {
  const PersonalPlanPage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final body = ref.watch(bodyProvider); final hydration = ref.watch(hydrationProvider); final nutrition = ref.watch(nutritionProvider); final sleep = ref.watch(sleepProvider); final dob = body.profile?.dateOfBirth;
    final age = dob == null ? null : (DateTime.now().difference(dob).inDays / 365.25).floor();
    final plan = AdaptiveHealthEngine.build(HealthProfileInput(weightKg: body.weightKg, heightCm: body.heightCm, ageYears: age, sex: body.profile?.biologicalSex, hydrationMl: hydration.consumedMl, proteinConsumed: nutrition.protein, sleepHours: sleep.latest?.hours));
    return Scaffold(appBar: AppBar(title: const Text('Today’s Plan')), body: ListView(padding: const EdgeInsets.all(20), children: [Text('Adaptive daily plan', style: Theme.of(context).textTheme.displaySmall), const SizedBox(height: 6), const Text('SUNYA calculates targets deterministically, then AI can personalize the plan.'), const SizedBox(height: 18), SunyaGlassCard(child: Row(children: [Text(plan.recoveryScore.toString(), style: Theme.of(context).textTheme.displaySmall), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Recovery', style: Theme.of(context).textTheme.titleLarge), Text(plan.priority + ' • ' + plan.trainingMode)]))])), const SizedBox(height: 12), _Target('Calories', plan.calorieTarget.toString() + ' kcal'), _Target('Protein', plan.proteinTarget.toString() + ' g'), _Target('Water', (plan.waterTargetMl / 1000).toStringAsFixed(1) + ' L'), if (plan.bmi != null) _Target('BMI', plan.bmi!.toStringAsFixed(1)), if (plan.bmr != null) _Target('BMR', plan.bmr.toString() + ' kcal/day'), const SizedBox(height: 12), Text('Next actions', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8), ...plan.actions.map((x) => Padding(padding: const EdgeInsets.only(bottom: 8), child: SunyaGlassCard(child: Row(children: [Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 12), Expanded(child: Text(x))])))), const SizedBox(height: 12), const SunyaGlassCard(child: Text('These are planning estimates, not medical diagnosis or treatment.'))]));
  }
}
class _Target extends StatelessWidget { const _Target(this.label, this.value); final String label, value; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: SunyaGlassCard(child: Row(children: [Expanded(child: Text(label)), Text(value, style: Theme.of(context).textTheme.titleLarge)]))); }

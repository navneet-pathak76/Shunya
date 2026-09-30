import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ai/ai_gateway.dart';
import '../../../core/services/ai/adaptive_health_engine.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../../body/presentation/body_controller.dart';
import '../../hydration/presentation/hydration_controller.dart';
import '../../nutrition/presentation/nutrition_controller.dart';
import '../../sleep/presentation/sleep_controller.dart';

class AiPage extends ConsumerStatefulWidget { const AiPage({super.key}); @override ConsumerState<AiPage> createState() => _AiPageState(); }
class _AiPageState extends ConsumerState<AiPage> {
  final input = TextEditingController(); final messages = <String>[]; bool loading = false;
  Future<void> ask() async {
    final q = input.text.trim(); if (q.isEmpty) return; input.clear(); setState(() { messages.add('You: ' + q); loading = true; });
    final body = ref.read(bodyProvider); final hyd = ref.read(hydrationProvider); final nut = ref.read(nutritionProvider); final sleep = ref.read(sleepProvider); final dob = body.profile?.dateOfBirth;
    final age = dob == null ? null : (DateTime.now().difference(dob).inDays / 365.25).floor();
    final plan = AdaptiveHealthEngine.build(HealthProfileInput(weightKg: body.weightKg, heightCm: body.heightCm, ageYears: age, sex: body.profile?.biologicalSex, hydrationMl: hyd.consumedMl, proteinConsumed: nut.protein, sleepHours: sleep.latest?.hours));
    final remote = await SunyaAiGateway().chat(message: q, context: {'plan': {'recovery': plan.recoveryScore, 'priority': plan.priority, 'calories': plan.calorieTarget, 'protein': plan.proteinTarget, 'waterMl': plan.waterTargetMl}});
    final answer = remote ?? ('SUNYA: ' + plan.priority + ' is the current priority. ' + plan.actions.first);
    if (mounted) setState(() { messages.add(answer); loading = false; });
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('SUNYA AI')), body: Column(children: [Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [Text('Personal intelligence', style: Theme.of(context).textTheme.displaySmall), const SizedBox(height: 8), const Text('SUNYA combines tracked data with deterministic health engines. Connect a backend AI provider for conversational planning.'), const SizedBox(height: 18), if (messages.isEmpty) const SunyaGlassCard(child: Text('Ask: “What should I focus on today?”')), ...messages.map((m) => Padding(padding: const EdgeInsets.only(bottom: 8), child: SunyaGlassCard(child: Text(m))))])), Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 12), child: Row(children: [Expanded(child: TextField(controller: input, decoration: const InputDecoration(hintText: 'Ask SUNYA…'))), IconButton(onPressed: loading ? null : ask, icon: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send))]))]));
  @override void dispose() { input.dispose(); super.dispose(); }
}

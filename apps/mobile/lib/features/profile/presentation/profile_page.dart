import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../body/presentation/body_controller.dart';
import '../../../core/widgets/sunya_glass.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(bodyProvider);
    final actions = [('Health Hub', Icons.favorite_outline, '/health'), ('Today\'s Plan', Icons.auto_awesome, '/ai/plan'), ('Goals', Icons.flag_outlined, '/goals'), ('Wellness', Icons.self_improvement_outlined, '/wellness'), ('Data & Privacy', Icons.privacy_tip_outlined, '/data')];
    return Scaffold(appBar: AppBar(title: const Text('Profile')), body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Your baseline', style: Theme.of(context).textTheme.displaySmall), const SizedBox(height: 6), const Text('The personal context SUNYA uses across modules.'), const SizedBox(height: 18),
      SunyaGlassCard(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Body profile', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12), _row('Height', b.heightCm == null ? '—' : b.heightCm!.toStringAsFixed(1) + ' cm'), _row('Weight', b.weightKg == null ? '—' : b.weightKg!.toStringAsFixed(1) + ' kg'), _row('BMI', b.bmi == null ? '—' : b.bmi!.toStringAsFixed(1)), _row('Body fat', b.bodyFatPercent == null ? '—' : b.bodyFatPercent!.toStringAsFixed(1) + ' %')])),
      const SizedBox(height: 16),
      Text('SUNYA systems', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 8),
      ...actions.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: SunyaGlassCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: Icon(item.$2, color: Theme.of(context).colorScheme.primary), title: Text(item.$1), trailing: const Icon(Icons.chevron_right), onTap: () => context.push(item.$3))))),
      const SizedBox(height: 8),
      const SunyaGlassCard(padding: EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Privacy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), SizedBox(height: 8), Text('SUNYA is local-first. Remote AI calls are optional and API keys stay on the backend, not in the Flutter client.')]))
    ]));
  }
  static Widget _row(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(a)), Text(b)]));
}

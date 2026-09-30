import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../body/presentation/body_controller.dart';
import '../../../core/settings/sunya_settings.dart';
import '../../../core/widgets/sunya_glass.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(bodyProvider);
    final s = ref.watch(sunyaSettingsProvider);
    final actions = [
      ('Health Hub', Icons.favorite_outline, '/health'),
      ('Today\'s Plan', Icons.auto_awesome, '/ai/plan'),
      ('Goals', Icons.flag_outlined, '/goals'),
      ('Wellness', Icons.self_improvement_outlined, '/wellness'),
      ('Appearance', Icons.face_retouching_natural_outlined, '/appearance'),
      ('Data & Privacy', Icons.privacy_tip_outlined, '/data'),
      ('Settings & UI', Icons.tune_rounded, '/settings'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(s.name),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Your baseline', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text(
            'The personal context SUNYA uses across modules.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          SunyaGlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile snapshot', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _row('Name', s.name),
                _row('Age', s.age == null ? '—' : '${s.age} yrs'),
                _row('Height', b.heightCm == null
                    ? (s.heightCm == null ? '—' : '${s.heightCm!.round()} cm')
                    : '${b.heightCm!.toStringAsFixed(1)} cm'),
                _row('Weight', b.weightKg == null
                    ? (s.weightKg == null ? '—' : '${s.weightKg!.toStringAsFixed(1)} kg')
                    : '${b.weightKg!.toStringAsFixed(1)} kg'),
                _row('Goal', s.goal),
                _row('BMI', b.bmi == null ? '—' : b.bmi!.toStringAsFixed(1)),
                _row('Body fat', b.bodyFatPercent == null
                    ? '—'
                    : '${b.bodyFatPercent!.toStringAsFixed(1)} %'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('SUNYA systems', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...actions.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SunyaGlassCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(item.$2, color: Theme.of(context).colorScheme.primary),
                  title: Text(item.$1),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(item.$3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const SunyaGlassCard(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Privacy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('SUNYA is local-first. Remote AI calls are optional and API keys stay on the backend, not in the Flutter client.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _row(String a, String b) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(child: Text(a)),
            Flexible(child: Text(b, textAlign: TextAlign.right)),
          ],
        ),
      );
}

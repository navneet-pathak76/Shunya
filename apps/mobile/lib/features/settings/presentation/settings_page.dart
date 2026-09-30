import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/sunya_settings.dart';
import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController name;
  late final TextEditingController age;
  late final TextEditingController height;
  late final TextEditingController weight;
  late final TextEditingController goal;

  @override
  void initState() {
    super.initState();
    final s = ref.read(sunyaSettingsProvider);
    name = TextEditingController(text: s.name);
    age = TextEditingController(text: s.age?.toString() ?? '');
    height = TextEditingController(text: s.heightCm?.toString() ?? '');
    weight = TextEditingController(text: s.weightKg?.toString() ?? '');
    goal = TextEditingController(text: s.goal);
  }

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    height.dispose();
    weight.dispose();
    goal.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final current = ref.read(sunyaSettingsProvider);
    await ref.read(sunyaSettingsProvider.notifier).update(
          current.copyWith(
            name: name.text.trim().isEmpty ? 'User' : name.text.trim(),
            age: int.tryParse(age.text.trim()),
            heightCm: double.tryParse(height.text.trim()),
            weightKg: double.tryParse(weight.text.trim()),
            goal: goal.text.trim().isEmpty
                ? 'Build a stronger, healthier baseline'
                : goal.text.trim(),
          ),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sunyaSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('SUNYA Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text('Personalize SUNYA',
              style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 6),
          Text(
            'Your profile powers greetings, context and future AI recommendations.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _section(
            context,
            'Profile',
            Column(
              children: [
                _field(name, 'Name', Icons.person_outline_rounded),
                _field(age, 'Age', Icons.cake_outlined, number: true),
                _field(height, 'Height (cm)', Icons.height_rounded, number: true),
                _field(weight, 'Weight (kg)', Icons.monitor_weight_outlined, number: true),
                _field(goal, 'Current goal', Icons.flag_outlined, maxLines: 2),
                const SizedBox(height: 8),
                SunyaPrimaryButton(
                  label: 'Save profile',
                  onPressed: saveProfile,
                  icon: Icons.check_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            context,
            'Glass system',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Glassmorphism'),
                  subtitle: const Text('Turn backdrop blur on/off globally'),
                  value: s.glassEnabled,
                  onChanged: (v) => ref
                      .read(sunyaSettingsProvider.notifier)
                      .setVisual(enabled: v),
                ),
                _slider(
                  context,
                  'Glass opacity',
                  s.glassOpacity,
                  .30,
                  .90,
                  (v) => ref
                      .read(sunyaSettingsProvider.notifier)
                      .setVisual(opacity: v),
                  '\${(s.glassOpacity * 100).round()}%',
                ),
                _slider(
                  context,
                  'Blur strength',
                  s.glassBlur,
                  0,
                  24,
                  (v) => ref
                      .read(sunyaSettingsProvider.notifier)
                      .setVisual(blur: v),
                  '\${s.glassBlur.round()} px',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            context,
            'Appearance',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme'),
                const SizedBox(height: 10),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {s.themeMode},
                  onSelectionChanged: (v) => ref
                      .read(sunyaSettingsProvider.notifier)
                      .setVisual(themeMode: v.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            context,
            'Performance',
            const Text(
              'SUNYA keeps blur configurable and avoids applying heavy filters to every screen. '
              'Use lower blur on older devices for smoother scrolling.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) =>
      SunyaGlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool number = false,
    int maxLines = 1,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
          ),
        ),
      );

  Widget _slider(
    BuildContext context,
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String valueLabel,
  ) =>
      Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(valueLabel,
                  style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            activeColor: SunyaTheme.blueBright,
            onChanged: onChanged,
          ),
        ],
      );
}

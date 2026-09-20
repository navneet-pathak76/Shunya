import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/sunya_motion.dart';
import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../../body/presentation/body_controller.dart';
import '../../hydration/presentation/hydration_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const modules = <_DashboardModule>[
    _DashboardModule('Body', '/body', Icons.accessibility_new_outlined, SunyaTheme.orange),
    _DashboardModule('Nutrition', '/nutrition', Icons.restaurant_outlined, SunyaTheme.nutrition),
    _DashboardModule('Hydration', '/hydration', Icons.water_drop_outlined, SunyaTheme.hydration),
    _DashboardModule('Workout', '/workout', Icons.fitness_center_outlined, SunyaTheme.orange),
    _DashboardModule('Sleep', '/sleep', Icons.bedtime_outlined, SunyaTheme.sleep),
    _DashboardModule('Habits', '/habits', Icons.repeat_outlined, SunyaTheme.success),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydration = ref.watch(hydrationProvider);
    final body = ref.watch(bodyProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';
    final hasBody = body.weightKg != null || body.heightCm != null || body.bodyFatPercent != null;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1050;
            final content = ListView(
              padding: EdgeInsets.fromLTRB(wide ? 24 : 20, 18, wide ? 24 : 20, 32),
              children: [
                _Header(greeting: greeting),
                const SizedBox(height: 18),
                _HeroCard(hydration: hydration, body: body, hasBody: hasBody),
                const SizedBox(height: 18),
                _SectionTitle(title: 'Today', action: 'View analytics', onTap: () => context.push('/analytics')),
                const SizedBox(height: 10),
                _MetricGrid(hydration: hydration, body: body, hasBody: hasBody),
                const SizedBox(height: 22),
                const _SectionTitle(title: 'Modules'),
                const SizedBox(height: 10),
                const _ModuleGrid(modules: modules),
                const SizedBox(height: 22),
                SunyaGlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: SunyaTheme.orangeSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: SunyaTheme.orange),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SUNYA insight', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              hydration.consumedMl == 0
                                  ? 'Start logging today. SUNYA will build your personal baseline as data accumulates.'
                                  : 'You have started today. Keep logging consistently so SUNYA can surface meaningful trends.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            if (!wide) return content;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 250, child: _DesktopRail()),
                Expanded(child: content),
                SizedBox(width: 290, child: _DesktopInsights(hydration: hydration, hasBody: hasBody)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.greeting});
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Your body. Your data. Your baseline.', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Profile',
          onPressed: () => context.push('/profile'),
          icon: const Icon(Icons.person_outline_rounded),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.hydration, required this.body, required this.hasBody});
  final HydrationState hydration;
  final BodyState body;
  final bool hasBody;

  @override
  Widget build(BuildContext context) {
    final progress = hydration.progress;
    return SunyaFadeSlide(
      child: SunyaGlassCard(
        padding: EdgeInsets.zero,
        borderRadius: SunyaTheme.radiusLarge,
        opacity: 0.7,
        child: Container(
          constraints: const BoxConstraints(minHeight: 280),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SunyaTheme.radiusLarge),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF171B20), Color(0xFF0B0E11)],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: -80,
                top: -100,
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: const DecoratedBox(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: const [SunyaTheme.orange, Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 560;
                    final summary = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TODAY', style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 1.8)),
                        const SizedBox(height: 8),
                        Text(
                          hasBody ? '${body.weightKg?.toStringAsFixed(1) ?? '—'} kg' : 'Build your baseline',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasBody ? 'Current body signal' : 'Log your first body measurement',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            _HeroChip(icon: Icons.water_drop_outlined, label: 'Hydration', value: '${(progress * 100).round()}%'),
                            const SizedBox(width: 8),
                            const _HeroChip(icon: Icons.bedtime_outlined, label: 'Sleep', value: 'Not logged'),
                          ],
                        ),
                      ],
                    );

                    final ring = SizedBox(
                      width: compact ? 118 : 150,
                      height: compact ? 118 : 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: compact ? 118 : 150,
                            height: compact ? 118 : 150,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 9,
                              backgroundColor: Colors.white.withOpacity(0.07),
                              valueColor: const AlwaysStoppedAnimation<Color>(SunyaTheme.orange),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${(progress * 100).round()}%', style: Theme.of(context).textTheme.headlineSmall),
                              Text('water', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    );

                    return compact
                        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [summary, const SizedBox(height: 26), Center(child: ring)])
                        : Row(children: [Expanded(child: summary), ring]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.045),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SunyaTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: SunyaTheme.textSecondary),
            const SizedBox(width: 7),
            Text('$label  ', style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      );
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.hydration, required this.body, required this.hasBody});
  final HydrationState hydration;
  final BodyState body;
  final bool hasBody;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Water', '${hydration.consumedMl}', 'ml', Icons.water_drop_outlined, SunyaTheme.hydration),
      ('Weight', hasBody ? body.weightKg!.toStringAsFixed(1) : '—', 'kg', Icons.monitor_weight_outlined, SunyaTheme.orange),
      ('Sleep', '—', 'hours', Icons.bedtime_outlined, SunyaTheme.sleep),
      ('Recovery', '—', 'score', Icons.bolt_outlined, SunyaTheme.success),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return SunyaFadeSlide(
          delay: Duration(milliseconds: 40 * index),
          child: SunyaGlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.$5.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(item.$4, color: item.$5, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(item.$2, style: Theme.of(context).textTheme.titleLarge),
                      Text(item.$3, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.modules});
  final List<_DashboardModule> modules;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: modules.map((module) {
          return InkWell(
            onTap: () => context.go(module.route),
            borderRadius: BorderRadius.circular(SunyaTheme.radiusMedium),
            child: SizedBox(
              width: 150,
              height: 116,
              child: SunyaGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(module.icon, color: module.accent),
                    const Spacer(),
                    Text(module.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text('Open module', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          if (action != null) TextButton(onPressed: onTap, child: Text(action!)),
        ],
      );
}

class _DesktopRail extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 0, 24),
        child: SunyaGlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SUNYA', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Human Operating System', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 28),
              Text('OVERVIEW', style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 1.4)),
              const SizedBox(height: 10),
              const _RailItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard', selected: true),
              const _RailItem(label: 'Body', icon: Icons.accessibility_new_outlined, route: '/body'),
              const _RailItem(label: 'Hydration', icon: Icons.water_drop_outlined, route: '/hydration'),
              const _RailItem(label: 'Nutrition', icon: Icons.restaurant_outlined, route: '/nutrition'),
              const _RailItem(label: 'Workout', icon: Icons.fitness_center_outlined, route: '/workout'),
              const Spacer(),
              Text('0 + ∞', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: SunyaTheme.orange)),
              const SizedBox(height: 4),
              Text('Sun · Earth · Moon · You', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
}

class _RailItem extends StatelessWidget {
  const _RailItem({required this.label, required this.icon, required this.route, this.selected = false});
  final String label;
  final IconData icon;
  final String route;
  final bool selected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          tileColor: selected ? SunyaTheme.orangeSoft : Colors.transparent,
          leading: Icon(icon, color: selected ? SunyaTheme.orange : SunyaTheme.textSecondary),
          title: Text(label, style: TextStyle(color: selected ? SunyaTheme.textPrimary : SunyaTheme.textSecondary)),
          onTap: () => context.go(route),
        ),
      );
}

class _DesktopInsights extends StatelessWidget {
  const _DesktopInsights({required this.hydration, required this.hasBody});
  final HydrationState hydration;
  final bool hasBody;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 24, 20, 24),
        child: Column(
          children: [
            SunyaGlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _InsightRow('Water', '${hydration.consumedMl} ml', SunyaTheme.hydration),
                  _InsightRow('Body', hasBody ? 'Tracked' : 'Not logged', SunyaTheme.orange),
                  const _InsightRow('Sleep', 'Not logged', SunyaTheme.sleep),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SunyaGlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: SunyaTheme.orange),
                  const SizedBox(height: 12),
                  Text('AI layer', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text('Insights will become useful as your personal dataset grows.', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      );
}

class _InsightRow extends StatelessWidget {
  const _InsightRow(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
            Text(value, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      );
}

class _DashboardModule {
  const _DashboardModule(this.name, this.route, this.icon, this.accent);
  final String name;
  final String route;
  final IconData icon;
  final Color accent;
}

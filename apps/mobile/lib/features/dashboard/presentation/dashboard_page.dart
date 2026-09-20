import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/sunya_theme.dart';
import '../../../core/widgets/sunya_glass.dart';
import '../../body/presentation/body_controller.dart';
import '../../hydration/presentation/hydration_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  static const modules = <_DashboardModule>[
    _DashboardModule('Body', '/body', Icons.accessibility_new_outlined),
    _DashboardModule('Nutrition', '/nutrition', Icons.restaurant_outlined),
    _DashboardModule('Hydration', '/hydration', Icons.water_drop_outlined),
    _DashboardModule('Workout', '/workout', Icons.fitness_center_outlined),
    _DashboardModule('Sleep', '/sleep', Icons.bedtime_outlined),
    _DashboardModule('Habits', '/habits', Icons.repeat_outlined),
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
            final isDesktop = constraints.maxWidth >= 1100;
            final bodyWidget = _SunyaBodyCenter(
              hydrationPercent: hydration.progress,
              weightLabel: hasBody ? '${body.weightKg?.toStringAsFixed(1) ?? '--'} kg' : 'No body data yet',
              bodyStatus: hasBody ? 'Stable signal' : 'Log your first measurement',
            );

            if (isDesktop) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 240, child: _Sidebar(context: context)),
                    const SizedBox(width: 20),
                    Expanded(child: bodyWidget),
                    const SizedBox(width: 20),
                    SizedBox(width: 300, child: _AnalyticsRail(context: context, hydration: hydration, hasBody: hasBody)),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text('Personal health command center', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 16),
                        bodyWidget,
                        const SizedBox(height: 18),
                        _MetricRow(hydration: hydration, hasBody: hasBody),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quick navigation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: modules.map((module) => _ModuleTile(module: module)).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return SunyaGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUNYA', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text('Daily overview', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          _NavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, selected: true, onTap: null),
          _NavItem(label: 'Body', icon: Icons.accessibility_new_outlined, onTap: null),
          _NavItem(label: 'Hydration', icon: Icons.water_drop_outlined, onTap: null),
          _NavItem(label: 'Nutrition', icon: Icons.restaurant_outlined, onTap: null),
          _NavItem(label: 'Workout', icon: Icons.fitness_center_outlined, onTap: null),
          const Spacer(),
          SunyaPrimaryButton(label: 'Log hydration', onPressed: () {}),
        ],
      ),
    );
  }
}

class _AnalyticsRail extends StatelessWidget {
  const _AnalyticsRail({required this.context, required this.hydration, required this.hasBody});
  final BuildContext context;
  final HydrationState hydration;
  final bool hasBody;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SunyaGlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              _StatRow(label: 'Water', value: '${hydration.consumedMl} ml', accent: SunyaTheme.hydration),
              _StatRow(label: 'Body', value: hasBody ? 'Tracked' : 'No data', accent: SunyaTheme.orange),
              _StatRow(label: 'Sleep', value: 'No data yet', accent: SunyaTheme.sleep),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SunyaGlassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI insight', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                hydration.consumedMl > 0 ? 'Hydration is active today. Keep the trend steady through the afternoon.' : 'No hydration data yet. Log your first glass to begin the trend.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SunyaBodyCenter extends StatelessWidget {
  const _SunyaBodyCenter({required this.hydrationPercent, required this.weightLabel, required this.bodyStatus});
  final double hydrationPercent;
  final String weightLabel;
  final String bodyStatus;

  @override
  Widget build(BuildContext context) {
    return SunyaGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Body / Today', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(weightLabel, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(bodyStatus, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: SunyaTheme.orangeSoft,
                  borderRadius: BorderRadius.circular(SunyaTheme.radiusMedium),
                  border: Border.all(color: SunyaTheme.border),
                ),
                child: Text('${(hydrationPercent * 100).round()}% hydration', style: const TextStyle(color: SunyaTheme.textPrimary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 440,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF0F172A), const Color(0xFF0A1118)],
              ),
              border: Border.all(color: SunyaTheme.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.75,
                        colors: [const Color(0xFF59C9FF).withOpacity(0.35), const Color(0xFF59C9FF).withOpacity(0.06), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  child: Container(
                    width: 160,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF8FE7FF), Color(0xFF1D9BF0)]),
                      boxShadow: [BoxShadow(color: const Color(0xFF1D9BF0).withOpacity(0.6), blurRadius: 44)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 44,
                  child: Container(
                    width: 180,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: const Color(0xFF19A3FF).withOpacity(0.22),
                      border: Border.all(color: const Color(0xFF7DE4FF).withOpacity(0.6)),
                    ),
                  ),
                ),
                Positioned(
                  left: 40,
                  top: 110,
                  child: _DataPill(label: 'Hydration', value: '${(hydrationPercent * 100).round()}%', color: SunyaTheme.hydration),
                ),
                Positioned(
                  right: 40,
                  top: 182,
                  child: _DataPill(label: 'Recovery', value: '87%', color: SunyaTheme.success),
                ),
                Positioned(
                  left: 82,
                  bottom: 82,
                  child: _DataPill(label: 'Calories', value: '1,940', color: SunyaTheme.orange),
                ),
                Positioned(
                  right: 74,
                  bottom: 92,
                  child: _DataPill(label: 'Sleep', value: '7h 30m', color: SunyaTheme.sleep),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataPill extends StatelessWidget {
  const _DataPill({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111B2A).withOpacity(0.9),
        border: Border.all(color: color.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: SunyaTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: SunyaTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.hydration, required this.hasBody});
  final HydrationState hydration;
  final bool hasBody;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SunyaGlassCard(padding: const EdgeInsets.all(16), child: _MiniMetric(label: 'Water', value: '${hydration.consumedMl} ml', icon: Icons.water_drop_outlined))),
        const SizedBox(width: 12),
        Expanded(child: SunyaGlassCard(padding: const EdgeInsets.all(16), child: _MiniMetric(label: 'Body', value: hasBody ? 'Tracked' : 'No data', icon: Icons.accessibility_new_outlined))),
        const SizedBox(width: 12),
        Expanded(child: SunyaGlassCard(padding: const EdgeInsets.all(16), child: _MiniMetric(label: 'Goals', value: '2 active', icon: Icons.flag_outlined))),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: SunyaTheme.orange),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module});
  final _DashboardModule module;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(module.route),
      borderRadius: BorderRadius.circular(SunyaTheme.radiusMedium),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SunyaTheme.surface.withOpacity(0.65),
          borderRadius: BorderRadius.circular(SunyaTheme.radiusMedium),
          border: Border.all(color: SunyaTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(module.icon, color: SunyaTheme.orange),
            const SizedBox(height: 18),
            Text(module.name, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.icon, this.selected = false, this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected ? SunyaTheme.orangeSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: selected ? SunyaTheme.orange : SunyaTheme.textSecondary),
        title: Text(label, style: TextStyle(color: selected ? SunyaTheme.textPrimary : SunyaTheme.textSecondary)),
        onTap: onTap,
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, required this.accent});
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _DashboardModule {
  const _DashboardModule(this.name, this.route, this.icon);
  final String name;
  final String route;
  final IconData icon;
}

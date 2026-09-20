import 'package:flutter/material.dart';

import '../theme/sunya_motion.dart';
import '../theme/sunya_theme.dart';
import 'sunya_glass.dart';

class SunyaModuleMetric {
  const SunyaModuleMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.accent = SunyaTheme.orange,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accent;
}

class SunyaModulePage extends StatelessWidget {
  const SunyaModulePage({
    super.key,
    required this.title,
    required this.description,
    required this.metrics,
    this.primaryAction,
  });

  final String title;
  final String description;
  final List<SunyaModuleMetric> metrics;
  final VoidCallback? primaryAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'More',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          SunyaFadeSlide(child: Text(title, style: Theme.of(context).textTheme.displaySmall)),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: metrics.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: columns == 2 ? 1.18 : 1.45,
                ),
                itemBuilder: (context, index) {
                  final metric = metrics[index];
                  return SunyaFadeSlide(
                    delay: Duration(milliseconds: 35 * index),
                    child: SunyaGlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: metric.accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: metric.accent.withOpacity(0.24)),
                            ),
                            child: Icon(metric.icon, color: metric.accent, size: 20),
                          ),
                          const Spacer(),
                          Text(metric.label, style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  metric.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              if (metric.unit.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(metric.unit, style: Theme.of(context).textTheme.bodySmall),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (primaryAction != null) ...[
            const SizedBox(height: 18),
            SunyaPrimaryButton(label: 'Add $title entry', onPressed: primaryAction, icon: Icons.add_rounded),
          ],
        ],
      ),
    );
  }
}

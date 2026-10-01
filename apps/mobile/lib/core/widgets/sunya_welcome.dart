import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/sunya_settings.dart';
import '../theme/sunya_theme.dart';
import 'sunya_glass.dart';

class SunyaWelcomeGate extends ConsumerStatefulWidget {
  const SunyaWelcomeGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<SunyaWelcomeGate> createState() => _SunyaWelcomeGateState();
}

class _SunyaWelcomeGateState extends ConsumerState<SunyaWelcomeGate>
    with SingleTickerProviderStateMixin {
  bool visible = false;
  late final AnimationController _controller;

  static const quotes = [
    'Small actions, repeated daily, become a different life.',
    'Build the system. Let consistency do the heavy lifting.',
    'Your future baseline is built by what you do today.',
    'Measure less to judge yourself, measure more to understand yourself.',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        setState(() => visible = true);
        _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void close() {
    _controller.reverse().whenComplete(() {
      if (mounted) setState(() => visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sunyaSettingsProvider);
    final quote = quotes[DateTime.now().day % quotes.length];
    final details = <String>[
      if (s.age != null) '${s.age} yrs',
      if (s.heightCm != null) '${s.heightCm!.round()} cm',
      if (s.weightKg != null) '${s.weightKg!.toStringAsFixed(1)} kg',
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 350),
            opacity: visible ? 1 : 0,
            child: ColoredBox(
              color: Colors.black.withOpacity(.58),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 560,
                      maxHeight: MediaQuery.sizeOf(context).height - 44,
                    ),
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOutCubic,
                      ),
                      child: SunyaGlassCard(
                        padding: const EdgeInsets.all(26),
                        borderRadius: 30,
                        opacity: .72,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      colors: [
                                        SunyaTheme.blueBright,
                                        SunyaTheme.blueGlow
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: SunyaTheme.blueBrightSoft,
                                        blurRadius: 24,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: close,
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'SUNYA AI',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    letterSpacing: 2.2,
                                    fontWeight: FontWeight.w700,
                                    color: SunyaTheme.blueBright,
                                  ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Good ${_partOfDay()}, ${s.name}.',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              details.isEmpty
                                  ? 'Your personal health system is ready. Start by building your baseline.'
                                  : 'Your current profile: ${details.join('  •  ')}.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: SunyaTheme.blueBright.withOpacity(.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: SunyaTheme.blueBright.withOpacity(.18),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.format_quote_rounded,
                                    color: SunyaTheme.blueBright,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      quote,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(height: 1.35),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              s.goal,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: close,
                                child: const Text('Start today'),
                              ),
                            ),
                          ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _partOfDay() {
    final h = DateTime.now().hour;
    return h < 12 ? 'morning' : h < 18 ? 'afternoon' : 'evening';
  }
}

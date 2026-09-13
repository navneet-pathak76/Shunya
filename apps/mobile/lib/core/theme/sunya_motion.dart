import 'package:flutter/material.dart';

class SunyaMotion {
  SunyaMotion._();

  static const fast = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 420);

  static const curve = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubic;
}

class SunyaFadeSlide extends StatelessWidget {
  const SunyaFadeSlide({super.key, required this.child, this.delay = Duration.zero, this.offset = const Offset(0, 0.04)});
  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: SunyaMotion.standard + delay,
        curve: SunyaMotion.curve,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(offset: offset * (1 - value), child: child),
        ),
        child: child,
      );
}

class SunyaPressScale extends StatefulWidget {
  const SunyaPressScale({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<SunyaPressScale> createState() => _SunyaPressScaleState();
}

class _SunyaPressScaleState extends State<SunyaPressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1,
          duration: SunyaMotion.fast,
          curve: SunyaMotion.curve,
          child: widget.child,
        ),
      );
}

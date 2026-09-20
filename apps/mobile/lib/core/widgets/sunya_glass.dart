import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/sunya_theme.dart';

class SunyaGlassCard extends StatelessWidget {
  const SunyaGlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.borderRadius = SunyaTheme.radiusMedium, this.opacity = 0.55});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double opacity;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: SunyaTheme.surface.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: SunyaTheme.border),
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 18, offset: Offset(0, 8))],
            ),
            child: child,
          ),
        ),
      );
}

class SunyaPrimaryButton extends StatelessWidget {
  const SunyaPrimaryButton({super.key, required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
          label: Text(label),
          style: FilledButton.styleFrom(
            backgroundColor: SunyaTheme.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SunyaTheme.radiusMedium)),
          ),
        ),
      );
}

class SunyaSectionHeader extends StatelessWidget {
  const SunyaSectionHeader({super.key, required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
        ],
      );
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/sunya_settings.dart';
import '../theme/sunya_theme.dart';

class SunyaGlassCard extends ConsumerWidget {
  const SunyaGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = SunyaTheme.radiusMedium,
    this.opacity = 0.55,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double opacity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(sunyaSettingsProvider);
    final effectiveOpacity =
        ((opacity * .35) + (settings.glassOpacity * .65))
            .clamp(.12, .92)
            .toDouble();
    final surfaceOpacity =
        (effectiveOpacity + (isDark ? 0 : .18)).clamp(0.0, 1.0).toDouble();

    Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(surfaceOpacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: scheme.primary.withOpacity(isDark ? .18 : .11),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(isDark ? .20 : .10),
            blurRadius: isDark ? 22 : 18,
            spreadRadius: isDark ? -4 : 0,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );

    if (settings.glassEnabled && settings.glassBlur > 0) {
      card = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: settings.glassBlur,
          sigmaY: settings.glassBlur,
        ),
        child: card,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: card,
    );
  }
}

class SunyaPrimaryButton extends StatelessWidget {
  const SunyaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shadowColor: scheme.primary.withOpacity(.24),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SunyaTheme.radiusMedium),
          ),
        ),
      ),
    );
  }
}

class SunyaSectionHeader extends StatelessWidget {
  const SunyaSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action!)),
        ],
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/sunya_theme.dart';

class SunyaLogo extends StatelessWidget {
  const SunyaLogo({
    super.key,
    this.size = 72,
    this.showWordmark = false,
    this.compact = false,
  });

  final double size;
  final bool showWordmark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mark = SvgPicture.asset(
      'assets/sunya_logo.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (!showWordmark) return mark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(height: 8),
        Text(
          'S U N Y A',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                letterSpacing: compact ? 5.5 : 7,
                fontWeight: FontWeight.w300,
                color: isDark ? SunyaTheme.ivory : SunyaTheme.ink,
              ),
        ),
        const SizedBox(height: 4),
        const Text(
          'INFINITE WITHIN.  |  BEYOND UNDERSTANDING.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.7,
            color: SunyaTheme.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          compact ? 'S U N Y A' : 'S U N Y A',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                letterSpacing: compact ? 5.5 : 7,
                fontWeight: FontWeight.w300,
                color: SunyaThemeIvory.of(context),
              ),
        ),
        const SizedBox(height: 4),
        const Text(
          'INFINITE WITHIN.  |  BEYOND UNDERSTANDING.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 1.7,
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class SunyaThemeIvory {
  static Color of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF111111);
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SunyaLogo extends StatelessWidget {
  const SunyaLogo({super.key, this.size = 72, this.showWordmark = false});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/sunya_logo.svg',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        if (showWordmark) ...[
          const SizedBox(height: 10),
          Text(
            'S U N Y A',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  letterSpacing: 7,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFFF5F5F5),
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'INFINITE WITHIN.  |  BEYOND UNDERSTANDING.',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.8,
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

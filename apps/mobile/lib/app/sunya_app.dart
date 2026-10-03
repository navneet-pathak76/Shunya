import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/sunya_router.dart';
import '../core/settings/sunya_settings.dart';
import '../core/theme/sunya_theme.dart';
import '../core/widgets/sunya_auth_gate.dart';

class SunyaApp extends ConsumerWidget {
  const SunyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(sunyaSettingsProvider);
    return MaterialApp.router(
      title: 'SUNYA',
      debugShowCheckedModeBanner: false,
      theme: SunyaTheme.light,
      darkTheme: SunyaTheme.dark,
      themeMode: settings.themeMode,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        return Container(
          decoration: BoxDecoration(
            gradient: SunyaTheme.backgroundGradient(brightness),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (brightness == Brightness.dark)
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.78, 0.92),
                        radius: 0.78,
                        colors: [
                          Color(0x22D4AF37),
                          Color(0x090D1420),
                          Color(0x00000000),
                        ],
                        stops: [0.0, 0.42, 1.0],
                      ),
                    ),
                  ),
                ),
              SunyaAuthGate(
                child: child ?? const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
      routerConfig: sunyaRouter,
    );
  }
}

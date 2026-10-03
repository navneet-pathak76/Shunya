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
              if (brightness == Brightness.dark) ...[
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(-0.82, 0.92),
                        radius: 0.92,
                        colors: [
                          Color(0x1FD4AF37),
                          Color(0x0A0D0D0F),
                          Color(0x00000000),
                        ],
                        stops: [0.0, 0.42, 1.0],
                      ),
                    ),
                  ),
                ),
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0.88, -0.72),
                        radius: 0.76,
                        colors: [
                          Color(0x14D4AF37),
                          Color(0x050D0D0F),
                          Color(0x00000000),
                        ],
                        stops: [0.0, 0.46, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
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

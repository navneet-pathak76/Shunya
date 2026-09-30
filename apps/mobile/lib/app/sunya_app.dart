import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/sunya_router.dart';
import '../core/settings/sunya_settings.dart';
import '../core/theme/sunya_theme.dart';
import '../core/widgets/sunya_welcome.dart';

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
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: SunyaTheme.backgroundGradient(brightness),
          ),
          child: SunyaWelcomeGate(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      routerConfig: sunyaRouter,
    );
  }
}

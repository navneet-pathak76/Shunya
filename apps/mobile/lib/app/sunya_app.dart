import 'package:flutter/material.dart';

import 'router/sunya_router.dart';
import '../core/theme/sunya_theme.dart';

class SunyaApp extends StatelessWidget {
  const SunyaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SUNYA',
      debugShowCheckedModeBanner: false,
      theme: SunyaTheme.light,
      darkTheme: SunyaTheme.dark,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: SunyaTheme.backgroundGradient(brightness),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: sunyaRouter,
    );
  }
}

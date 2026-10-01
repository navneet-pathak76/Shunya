import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunya/app/sunya_app.dart';

void main() {
  testWidgets('SUNYA app boots and shows the app shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SunyaApp()));

    // The welcome overlay intentionally appears after a short startup delay.
    // Verify the underlying app shell before that presentation animation begins.
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunya/app/sunya_app.dart';

void main() {
  testWidgets('SUNYA app boots and shows the app shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SunyaApp()));

    // Allow the welcome startup timer and presentation animation to finish.
    // The underlying app shell remains mounted beneath the overlay.
    await tester.pump(const Duration(milliseconds: 1100));

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}

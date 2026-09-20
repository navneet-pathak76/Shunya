import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sunya/app/sunya_app.dart';

void main() {
  testWidgets('SUNYA app boots and shows the dashboard shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SunyaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Personal health command center'), findsOneWidget);
  });
}

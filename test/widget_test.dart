import 'package:flutter_test/flutter_test.dart';

import 'package:her_little_world/main.dart';

void main() {
  testWidgets('App renders the gift screen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HerLittleWorldApp());
    // pump once to build the initial frame (repeating animations prevent
    // pumpAndSettle from completing).
    await tester.pump();

    // The gift screen should show the recipient's name.
    expect(find.text('Put Her Name Here'), findsOneWidget);

    // The tagline should be visible.
    expect(find.text('a tiny world I built, just for you'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:her_little_world/content.dart';
import 'package:her_little_world/main.dart';
import 'package:her_little_world/screens/garden_screen.dart';
import 'package:her_little_world/screens/hub_screen.dart';
import 'package:her_little_world/screens/playlist_screen.dart';
import 'package:her_little_world/state/journey_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App renders the gift screen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HerLittleWorldApp());
    // pump once to build the initial frame (repeating animations prevent
    // pumpAndSettle from completing).
    await tester.pump();

    expect(find.text(AppContent.herName), findsOneWidget);
    expect(find.text('a tiny world I built, just for you'), findsOneWidget);
  });

  testWidgets('tapping the gift opens the hub', (WidgetTester tester) async {
    await tester.pumpWidget(const HerLittleWorldApp());
    await tester.pump();

    await tester.tap(find.byKey(const Key('gift_box')));
    // Let the gift-box open animation run and the page transition finish.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.text('Welcome to your little world'), findsOneWidget);
  });

  group('Hub', () {
    Widget hubApp(JourneyState state) => ChangeNotifierProvider.value(
          value: state,
          child: const MaterialApp(home: HubScreen()),
        );

    testWidgets('surprise node is locked until all three chapters are done',
        (WidgetTester tester) async {
      await tester.pumpWidget(hubApp(JourneyState()));
      await tester.pump();

      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byIcon(Icons.cake_rounded), findsNothing);
    });

    testWidgets('tapping the locked surprise shows the hint',
        (WidgetTester tester) async {
      await tester.pumpWidget(hubApp(JourneyState()));
      await tester.pump();

      await tester.tap(find.text('The Surprise'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('finish the Garden, Treehouse & Starry Hill first'),
        findsOneWidget,
      );
    });

    testWidgets('surprise unlocks when all three chapters are done',
        (WidgetTester tester) async {
      final state = JourneyState()
        ..completeGarden()
        ..completeTreehouse()
        ..completeStarryHill();
      await tester.pumpWidget(hubApp(state));
      await tester.pump();

      expect(find.byIcon(Icons.lock_rounded), findsNothing);
      expect(find.byIcon(Icons.cake_rounded), findsOneWidget);
    });
  });

  group('Garden', () {
    testWidgets('tapping a flower reveals its memory card',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: JourneyState(),
          child: const MaterialApp(home: GardenScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('flower_0')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.text(AppContent.gardenMemories.first.message),
        findsOneWidget,
      );
    });
  });

  group('Playlist', () {
    testWidgets('renders the in-app player with the bundled tracks',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PlaylistScreen()));
      await tester.pump();

      expect(find.text('the soundtrack of us'), findsOneWidget);
      expect(find.text('demo melody'), findsWidgets);
      expect(find.text('made just for you'), findsWidgets);
      // Player controls should be present.
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    });
  });

  group('JourneyState', () {
    test('all chapters must be complete before the finale unlocks', () {
      final state = JourneyState()..completeGarden();
      expect(state.allChaptersDone, isFalse);

      state
        ..completeTreehouse()
        ..completeStarryHill();
      expect(state.allChaptersDone, isTrue);
    });

    test('completed chapters persist across new instances', () async {
      final first = JourneyState();
      first
        ..completeGarden()
        ..completeTreehouse();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final second = JourneyState();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(second.gardenVisited, isTrue);
      expect(second.treehouseVisited, isTrue);
      expect(second.starryHillVisited, isFalse);
    });

    test('reset clears persisted chapters', () async {
      final state = JourneyState()
        ..completeGarden()
        ..completeStarryHill();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await state.reset();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final fresh = JourneyState();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(fresh.allChaptersDone, isFalse);
    });
  });
}
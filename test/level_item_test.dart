import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:flying_words/src/level_selection/level_item.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';
import 'package:flying_words/src/style/palette.dart';
import 'package:provider/provider.dart';

final _lesson = Lesson(number: 1, verse: 'Test 1,1', text: 'Alpha Beta Gamma');

Widget _wrap(PlayerProgress progress) {
  return MultiProvider(
    providers: [
      Provider(create: (_) => Palette()),
      ChangeNotifierProvider.value(value: progress),
    ],
    child: MaterialApp(home: Scaffold(body: LevelItem(_lesson))),
  );
}

void main() {
  testWidgets('fresh verse: only seal I is open, no stars yet',
      (tester) async {
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    await tester.pumpWidget(_wrap(progress));

    expect(find.text('Test 1,1'), findsOneWidget);
    expect(find.byKey(const Key('padlock-slow')), findsNothing);
    expect(find.byKey(const Key('padlock-normal')), findsOneWidget);
    expect(find.byKey(const Key('padlock-insane')), findsOneWidget);
    // No earned stars anywhere.
    expect(find.byIcon(Icons.star), findsNothing);
    // Seals I and II offer three star slots, seal III one.
    expect(find.byIcon(Icons.star_border), findsNWidgets(7));
  });

  testWidgets('flawless run on seal I shows three stars and opens seal II',
      (tester) async {
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    progress.setScoreforVerse('Test 1,1', Difficulty.slow,
        Score(score: 100, errors: 0, duration: const Duration(seconds: 45)));

    await tester.pumpWidget(_wrap(progress));

    expect(find.byKey(const Key('padlock-normal')), findsNothing);
    expect(find.byKey(const Key('padlock-insane')), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(3));
    // The best run's time appears under the seal.
    expect(find.byKey(const Key('besttime-slow')), findsOneWidget);
    expect(find.text('00:45'), findsOneWidget);

    // Flush the simulated async persistence writes.
    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets('the eye toggle arms a blind run for this verse',
      (tester) async {
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    await tester.pumpWidget(_wrap(progress));

    expect(find.byKey(const Key('blind-1-off')), findsOneWidget);
    await tester.tap(find.byKey(const Key('blind-1-off')));
    await tester.pump();
    expect(find.byKey(const Key('blind-1-on')), findsOneWidget);
    // Toggling back works too.
    await tester.tap(find.byKey(const Key('blind-1-on')));
    await tester.pump();
    expect(find.byKey(const Key('blind-1-off')), findsOneWidget);
  });
}

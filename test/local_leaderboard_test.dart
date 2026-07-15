import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:flying_words/src/leaderboard/local_leaderboard_screen.dart';
import 'package:flying_words/src/level_selection/levels.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';
import 'package:flying_words/src/style/palette.dart';
import 'package:flying_words/src/verses/bolls_bible_api_client.dart';
import 'package:flying_words/src/verses/custom_verses_controller.dart';
import 'package:flying_words/src/verses/persistence/memory_custom_verses_persistence.dart';
import 'package:provider/provider.dart';

import 'helpers/localized_material_app.dart';

Widget _wrap(PlayerProgress progress) {
  return MultiProvider(
    providers: [
      Provider(create: (_) => Palette()),
      ChangeNotifierProvider.value(value: progress),
      ChangeNotifierProvider(
        create: (_) => CustomVersesController(
          store: MemoryCustomVersesPersistence(),
          api: BollsBibleApiClient(),
        ),
      ),
    ],
    child: const LocalizedMaterialApp(home: LocalLeaderboardScreen()),
  );
}

void main() {
  setUpAll(() async {
    await loadCuratedVerses();
  });

  testWidgets('empty state before any run is finished', (tester) async {
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    await tester.pumpWidget(_wrap(progress));
    await tester.pump();

    expect(find.text('Gesamtpunktzahl: 0'), findsOneWidget);
    expect(find.text('Auswendig gelernte Verse: 0'), findsOneWidget);
    expect(find.byKey(const Key('leaderboard-list')), findsNothing);
    expect(
        find.textContaining('Noch keine Läufe abgeschlossen'), findsOneWidget);
  });

  testWidgets('runs are ranked by score, highest first', (tester) async {
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    progress.setScoreforVerse(
        verseProgressKey(gameLevels[0]), Difficulty.slow, Score(score: 50));
    progress.setScoreforVerse(
        verseProgressKey(gameLevels[1]), Difficulty.normal, Score(score: 200));
    progress.setScoreforVerse(
        verseProgressKey(gameLevels[1]), Difficulty.slow, Score(score: 20));

    await tester.pumpWidget(_wrap(progress));
    await tester.pump();

    expect(find.text('Gesamtpunktzahl: 270'), findsOneWidget);

    final texts = tester
        .widgetList<Text>(find.descendant(
          of: find.byKey(const Key('leaderboard-list')),
          matching: find.byType(Text),
        ))
        .map((t) => t.data)
        .toList();
    // Highest score (200) must be ranked before the lower ones (50, 20).
    expect(texts.indexOf('200'), lessThan(texts.indexOf('50')));
    expect(texts.indexOf('50'), lessThan(texts.indexOf('20')));

    // Flush the simulated async persistence writes.
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('shows how many verses are memorized (3 stars on Seal II)',
      (tester) async {
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    progress.setScoreforVerse(verseProgressKey(gameLevels[0]),
        Difficulty.normal, Score(score: 50, errors: 0));

    await tester.pumpWidget(_wrap(progress));
    await tester.pump();

    expect(find.text('Auswendig gelernte Verse: 1'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
  });
}

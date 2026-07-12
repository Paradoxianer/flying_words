import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/audio/audio_controller.dart';
import 'package:flying_words/src/game_internals/bible_reference.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:flying_words/src/level_selection/level_item.dart';
import 'package:flying_words/src/level_selection/level_selection_screen.dart';
import 'package:flying_words/src/level_selection/levels.dart';
import 'package:flying_words/src/level_selection/sealed_verse_card.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';
import 'package:flying_words/src/settings/settings.dart';
import 'package:flying_words/src/settings/persistence/memory_settings_persistence.dart';
import 'package:flying_words/src/style/palette.dart';
import 'package:flying_words/src/verses/bible_api_client.dart';
import 'package:flying_words/src/verses/bolls_bible_api_client.dart';
import 'package:flying_words/src/verses/custom_verses_controller.dart';
import 'package:flying_words/src/verses/persistence/memory_custom_verses_persistence.dart';
import 'package:provider/provider.dart';

import 'helpers/localized_material_app.dart';

/// A fake API client so custom verses can be seeded without a network.
class _FakeBibleApiClient implements BibleApiClient {
  @override
  String get defaultTranslation => 'MB';

  @override
  Future<FetchedVerse> fetchPassage(BibleReference reference,
          {String? translation}) async =>
      FetchedVerse(text: 'eins zwei drei', translation: 'MB');
}

Widget _wrap(PlayerProgress progress, {CustomVersesController? customVerses}) {
  return MultiProvider(
    providers: [
      Provider(create: (_) => Palette()),
      ChangeNotifierProvider.value(value: progress),
      ChangeNotifierProvider.value(
        value: customVerses ??
            CustomVersesController(
              store: MemoryCustomVersesPersistence(),
              api: BollsBibleApiClient(),
            ),
      ),
      Provider<SettingsController>(
        create: (_) => SettingsController(
            persistence: MemoryOnlySettingsPersistence()),
      ),
      Provider<AudioController>(create: (_) => AudioController()),
    ],
    child: const LocalizedMaterialApp(home: LevelSelectionScreen()),
  );
}

void main() {
  setUpAll(() async {
    await loadCuratedVerses();
  });

  // A tall surface so the lazy ListView builds every card.
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('fresh player: 3 verses open, the rest sealed', (tester) async {
    useTallSurface(tester);
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    await tester.pumpWidget(_wrap(progress));
    await tester.pump();

    expect(find.byType(LevelItem), findsNWidgets(3));
    expect(find.byType(SealedVerseCard), findsNWidgets(gameLevels.length - 3));
    // The first sealed card explains how to open it.
    expect(
        find.textContaining('um diese Seite zu öffnen'), findsOneWidget);
  });

  testWidgets('finishing verse 3 unlocks a fourth verse', (tester) async {
    useTallSurface(tester);
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    // Third curated verse finished on seal I.
    progress.setScoreforVerse(
        verseProgressKey(gameLevels[2]), Difficulty.slow, Score(score: 10));

    await tester.pumpWidget(_wrap(progress));
    await tester.pump();

    expect(find.byType(LevelItem), findsNWidgets(4));
    expect(find.byType(SealedVerseCard), findsNWidgets(gameLevels.length - 4));

    // Flush the simulated async persistence writes.
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('own verses section appears once all curated verses are done',
      (tester) async {
    useTallSurface(tester);
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    for (final level in gameLevels) {
      progress.setScoreforVerse(
          verseProgressKey(level), Difficulty.slow, Score(score: 10));
    }

    await tester.pumpWidget(_wrap(progress));
    await tester.pump();

    expect(find.text('Eigene Verse'), findsOneWidget);
    expect(find.byKey(const Key('add-verse')), findsOneWidget);
    expect(find.text('Vers hinzufügen'), findsOneWidget);
    // No sealed cards left.
    expect(find.byType(SealedVerseCard), findsNothing);

    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets(
      'own verses mastered on Seal III collapse into a closed section (#80)',
      (tester) async {
    useTallSurface(tester);
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    for (final level in gameLevels) {
      progress.setScoreforVerse(
          verseProgressKey(level), Difficulty.slow, Score(score: 10));
    }

    final customVerses = CustomVersesController(
        store: MemoryCustomVersesPersistence(), api: _FakeBibleApiClient());
    final mastered = await customVerses.addFromReference(
      reference: const BibleReference(book: 'JHN', chapter: 3, verseStart: 16),
      display: 'Mastered verse',
      progress: progress,
    );
    final inProgress = await customVerses.addFromReference(
      reference: const BibleReference(book: 'JHN', chapter: 3, verseStart: 17),
      display: 'In-progress verse',
      progress: progress,
    );
    // Only the first verse is fully mastered (Seal III / insane done).
    progress.setScoreforVerse(
        verseProgressKey(mastered), Difficulty.insane, Score(score: 10));
    progress.setScoreforVerse(
        verseProgressKey(inProgress), Difficulty.slow, Score(score: 10));

    await tester.pumpWidget(_wrap(progress, customVerses: customVerses));
    await tester.pump();

    // The mastered verse is tucked away, the in-progress one stays visible.
    expect(find.text('In-progress verse'), findsOneWidget);
    expect(find.text('Mastered verse'), findsNothing);
    expect(find.byKey(const Key('finished-own-verses')), findsOneWidget);
    expect(find.text('Abgeschlossen (1)'), findsOneWidget);

    // Expanding it reveals the mastered verse too.
    await tester.tap(find.byKey(const Key('finished-own-verses')));
    await tester.pumpAndSettle();
    expect(find.text('Mastered verse'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
  });
}

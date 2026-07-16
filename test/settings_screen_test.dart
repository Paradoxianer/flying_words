import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/ads/ads_controller.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:flying_words/src/in_app_purchase/in_app_purchase.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';
import 'package:flying_words/src/settings/persistence/memory_settings_persistence.dart';
import 'package:flying_words/src/settings/settings.dart';
import 'package:flying_words/src/settings/settings_screen.dart';
import 'package:flying_words/src/style/palette.dart';
import 'package:provider/provider.dart';

import 'helpers/localized_material_app.dart';

void main() {
  Widget wrap(PlayerProgress progress) => MultiProvider(
        providers: [
          Provider(create: (_) => Palette()),
          Provider<SettingsController>(
            create: (_) =>
                SettingsController(persistence: MemoryOnlySettingsPersistence()),
          ),
          ChangeNotifierProvider.value(value: progress),
          Provider<AdsController?>.value(value: null),
          ChangeNotifierProvider<InAppPurchaseController?>.value(value: null),
        ],
        child: const LocalizedMaterialApp(home: SettingsScreen()),
      );

  testWidgets(
      'resetting progress requires confirmation and does nothing on cancel '
      '(#101)', (tester) async {
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    progress.setScoreforVerse('v', Difficulty.slow, Score(score: 42));

    await tester.pumpWidget(wrap(progress));
    await tester.tap(find.text('Fortschritt zurücksetzen'));
    await tester.pumpAndSettle();

    // The confirmation dialog is up; progress is untouched so far.
    expect(find.text('Fortschritt wirklich zurücksetzen?'), findsOneWidget);
    expect(progress.getScoreforVerse('v', Difficulty.slow)!.score, 42);

    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(find.text('Fortschritt wirklich zurücksetzen?'), findsNothing);
    expect(progress.getScoreforVerse('v', Difficulty.slow)!.score, 42);
  });

  testWidgets('confirming the dialog actually resets progress (#101)',
      (tester) async {
    final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
    progress.setScoreforVerse('v', Difficulty.slow, Score(score: 42));

    await tester.pumpWidget(wrap(progress));
    await tester.tap(find.text('Fortschritt zurücksetzen'));
    await tester.pumpAndSettle();

    // Two matches now: the settings line and the dialog's confirm button.
    await tester.tap(find.text('Fortschritt zurücksetzen').last);
    await tester.pumpAndSettle();

    expect(progress.getScoreforVerse('v', Difficulty.slow), isNull);
    expect(find.text('Der Fortschritt wurde zurückgesetzt.'), findsOneWidget);

    // Flush the simulated async persistence writes from reset().
    await tester.pump(const Duration(milliseconds: 600));
  });
}

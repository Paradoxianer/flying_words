import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/ads/ads_controller.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/game_internals/level_state.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:flying_words/src/in_app_purchase/in_app_purchase.dart';
import 'package:flying_words/src/play_session/text_progress.dart';
import 'package:flying_words/src/style/palette.dart';
import 'package:flying_words/src/win_game/win_game_screen.dart';
import 'package:provider/provider.dart';

Lesson _lesson() =>
    Lesson(number: 1, verse: 'Test 1,1', text: 'Alpha Beta Gamma');

LevelState _finishedState({Set<int> errors = const {}}) {
  final state = LevelState(onWin: (_) {}, length: 3);
  for (final index in errors) {
    state.addErrorIndex(index);
  }
  state.setWordIndex(3);
  return state;
}

void main() {
  testWidgets('TextProgress shows the whole verse with missed words marked',
      (tester) async {
    await tester.pumpWidget(Provider(
      create: (_) => Palette(),
      child: MaterialApp(
        home: Scaffold(
          body:
              TextProgress(lesson: _lesson(), state: _finishedState(errors: {1})),
        ),
      ),
    ));

    final richText = tester.widget<RichText>(find.descendant(
      of: find.byType(TextProgress),
      matching: find.byType(RichText),
    ));
    final spans = (richText.text as TextSpan).children!.cast<TextSpan>();

    expect(spans.map((s) => s.text).join(), 'Alpha Beta Gamma ');
    // The missed word is highlighted, the others are not.
    final palette = Palette();
    expect(spans[1].style!.color, palette.sealRed);
    expect(spans[0].style!.color, palette.ink);
    expect(spans[2].style!.color, palette.ink);
  });

  testWidgets('WinGameScreen shows verse, marked errors and stats',
      (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AdsController?>.value(value: null),
        ChangeNotifierProvider<InAppPurchaseController?>.value(value: null),
        Provider(create: (_) => Palette()),
      ],
      child: MaterialApp(
        home: WinGameScreen(
          score: Score(score: 42, duration: const Duration(seconds: 90)),
          lesson: _lesson(),
          levelState: _finishedState(errors: {2}),
          difficulty: Difficulty.slow,
        ),
      ),
    ));

    expect(find.text('Gewonnen!'), findsOneWidget);
    expect(find.text('Test 1,1'), findsOneWidget);
    expect(find.byType(TextProgress), findsOneWidget);
    expect(find.textContaining('Score: 42'), findsOneWidget);
    expect(find.textContaining('Fehler: 1'), findsOneWidget);
    expect(find.textContaining('Zeit: 01:30'), findsOneWidget);
    // One error on seal I: two earned stars out of three.
    expect(find.byIcon(Icons.star), findsNWidgets(2));
    expect(find.byIcon(Icons.star_border), findsNWidgets(1));
    // No previous best passed: this run is the first best time.
    expect(find.text('Neue Bestzeit!'), findsOneWidget);
  });

  testWidgets('WinGameScreen compares against the previous best time',
      (tester) async {
    Widget screen(Score? previousBest) => MultiProvider(
          providers: [
            Provider<AdsController?>.value(value: null),
            ChangeNotifierProvider<InAppPurchaseController?>.value(value: null),
            Provider(create: (_) => Palette()),
          ],
          child: MaterialApp(
            home: WinGameScreen(
              score:
                  Score(score: 42, duration: const Duration(seconds: 90)),
              lesson: _lesson(),
              levelState: _finishedState(),
              difficulty: Difficulty.slow,
              previousBest: previousBest,
            ),
          ),
        );

    // Faster than the previous best: celebrate.
    await tester.pumpWidget(screen(
        Score(score: 10, duration: const Duration(seconds: 120))));
    expect(find.text('Neue Bestzeit!'), findsOneWidget);

    // Slower: show what to beat.
    await tester.pumpWidget(screen(
        Score(score: 10, duration: const Duration(seconds: 60))));
    expect(find.text('Bestzeit: 01:00'), findsOneWidget);
    expect(find.text('Neue Bestzeit!'), findsNothing);
  });
}

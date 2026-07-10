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
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TextProgress(lesson: _lesson(), state: _finishedState(errors: {1})),
      ),
    ));

    final richText = tester.widget<RichText>(find.descendant(
      of: find.byType(TextProgress),
      matching: find.byType(RichText),
    ));
    final spans = (richText.text as TextSpan).children!.cast<TextSpan>();

    expect(spans.map((s) => s.text).join(), 'Alpha Beta Gamma ');
    // The missed word is highlighted, the others are not.
    expect(spans[1].style!.color, Colors.deepOrangeAccent);
    expect(spans[0].style!.color, Colors.black);
    expect(spans[2].style!.color, Colors.black);
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
        ),
      ),
    ));

    expect(find.text('Gewonnen!'), findsOneWidget);
    expect(find.text('Test 1,1'), findsOneWidget);
    expect(find.byType(TextProgress), findsOneWidget);
    expect(find.textContaining('Score: 42'), findsOneWidget);
    expect(find.textContaining('Fehler: 1'), findsOneWidget);
    expect(find.textContaining('Zeit: 01:30'), findsOneWidget);
  });
}

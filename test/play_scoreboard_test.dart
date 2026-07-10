import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/level_state.dart';
import 'package:flying_words/src/play_session/play_scoreboard.dart';

void main() {
  testWidgets('PlayScoreboard shows progress, time and errors',
      (tester) async {
    final state = LevelState(onWin: (_) {}, length: 5);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PlayScoreboard(state: state, wordCount: 5)),
    ));

    expect(find.text('1/5'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    // Two seconds pass.
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:02'), findsOneWidget);

    // The player advances and makes an error.
    state.nextWordIndex();
    state.addErrorIndex(1);
    await tester.pump();
    expect(find.text('2/5'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('PlayScoreboard stops the clock when the lesson is finished',
      (tester) async {
    final state = LevelState(onWin: (_) {}, length: 2);
    state.setWordIndex(2);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PlayScoreboard(state: state, wordCount: 2)),
    ));

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:00'), findsOneWidget);
    // The word counter is clamped to the total.
    expect(find.text('2/2'), findsOneWidget);
  });
}

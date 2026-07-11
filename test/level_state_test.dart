import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/level_state.dart';

void main() {
  test('streak grows with catches and resets on any error', () {
    final state = LevelState(onWin: (_) {}, length: 10);
    expect(state.streak, 0);

    state.registerCatch();
    state.registerCatch();
    state.registerCatch();
    expect(state.streak, 3);

    state.addErrorIndex(3);
    expect(state.streak, 0);

    state.registerCatch();
    expect(state.streak, 1);
  });

  test('pause state notifies listeners and toggles', () {
    final state = LevelState(onWin: (_) {}, length: 10);
    var notified = 0;
    state.addListener(() => notified++);

    state.setPaused(true);
    expect(state.paused, isTrue);
    expect(notified, 1);

    // Setting the same value again does not notify.
    state.setPaused(true);
    expect(notified, 1);

    state.setPaused(false);
    expect(state.paused, isFalse);
    expect(notified, 2);
  });

  test('blind run: hidden from the first word and never shown again', () {
    final state = LevelState(onWin: (_) {}, length: 10);
    expect(state.blindRun, isFalse);

    // Hidden before the first word is solved.
    state.setTextHidden(true);
    expect(state.blindRun, isTrue);

    state.nextWordIndex();
    expect(state.blindRun, isTrue);

    // Peeking cancels the bonus for this run.
    state.setTextHidden(false);
    state.setTextHidden(true);
    expect(state.blindRun, isFalse);
  });

  test('hiding the text mid-run gives no blind bonus', () {
    final state = LevelState(onWin: (_) {}, length: 10);
    state.nextWordIndex();
    state.setTextHidden(true);
    expect(state.textHidden, isTrue);
    expect(state.blindRun, isFalse);
  });

  test('repeated errors on the same word still reset the streak', () {
    final state = LevelState(onWin: (_) {}, length: 10);
    state.addErrorIndex(0);
    state.registerCatch();
    // The same word index errors again (e.g. timeout on a retried word).
    state.addErrorIndex(0);
    expect(state.streak, 0);
    expect(state.numErrors, 1);
  });
}

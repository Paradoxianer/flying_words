import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';

void main() {
  group('Score.fromResult', () {
    test('does not crash for runs under one second', () {
      final score = Score.fromResult(
          20, Difficulty.slow, const Duration(milliseconds: 500), 0);
      expect(score.score, greaterThan(0));
    });

    test('does not crash for zero duration', () {
      final score = Score.fromResult(20, Difficulty.slow, Duration.zero, 0);
      expect(score.score, greaterThan(0));
    });

    test(
        'a terrible enough run is worth nothing, not floored to one point '
        'anymore (#114 - that floor is also why "finished" used to require '
        'score > 0)', () {
      final score = Score.fromResult(
          20, Difficulty.insane, const Duration(minutes: 30), 1000);
      expect(score.score, 0);
    });

    test('faster runs score higher', () {
      final fast = Score.fromResult(
          20, Difficulty.normal, const Duration(seconds: 20), 0);
      final slow = Score.fromResult(
          20, Difficulty.normal, const Duration(seconds: 60), 0);
      expect(fast.score, greaterThan(slow.score));
    });

    test('errors reduce the score', () {
      final clean = Score.fromResult(
          20, Difficulty.normal, const Duration(seconds: 30), 0);
      final sloppy = Score.fromResult(
          20, Difficulty.normal, const Duration(seconds: 30), 5);
      expect(clean.score, greaterThan(sloppy.score));
    });

    test('the blind bonus multiplies the score by 1.5', () {
      final normal = Score.fromResult(
          20, Difficulty.normal, const Duration(seconds: 30), 0);
      final blind = Score.fromResult(
          20, Difficulty.normal, const Duration(seconds: 30), 0,
          blindBonus: true);
      expect(blind.score, (normal.score * 1.5).round());
    });

    test('higher difficulty scores higher for the same result', () {
      final slow = Score.fromResult(
          20, Difficulty.slow, const Duration(seconds: 30), 0);
      final insane = Score.fromResult(
          20, Difficulty.insane, const Duration(seconds: 30), 0);
      expect(insane.score, greaterThan(slow.score));
    });

    test('carries the word count through, for the error-rate star math '
        '(#114)', () {
      final score = Score.fromResult(
          20, Difficulty.slow, const Duration(seconds: 30), 3);
      expect(score.wordCount, 20);
      expect(score.errors, 3);
    });
  });
}

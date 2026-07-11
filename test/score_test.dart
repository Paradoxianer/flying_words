import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';

void main() {
  group('Score.fromResult', () {
    test('does not crash for runs under one second', () {
      final score = Score.fromResult(
          1, Difficulty.slow, const Duration(milliseconds: 500), 0);
      expect(score.score, greaterThan(0));
    });

    test('does not crash for zero duration', () {
      final score = Score.fromResult(1, Difficulty.slow, Duration.zero, 0);
      expect(score.score, greaterThan(0));
    });

    test('a won level is never worth less than one point', () {
      final score = Score.fromResult(
          1, Difficulty.insane, const Duration(minutes: 30), 1000);
      expect(score.score, 1);
    });

    test('faster runs score higher', () {
      final fast = Score.fromResult(
          1, Difficulty.normal, const Duration(seconds: 20), 0);
      final slow = Score.fromResult(
          1, Difficulty.normal, const Duration(seconds: 60), 0);
      expect(fast.score, greaterThan(slow.score));
    });

    test('errors reduce the score', () {
      final clean = Score.fromResult(
          1, Difficulty.normal, const Duration(seconds: 30), 0);
      final sloppy = Score.fromResult(
          1, Difficulty.normal, const Duration(seconds: 30), 5);
      expect(clean.score, greaterThan(sloppy.score));
    });

    test('the blind bonus multiplies the score by 1.5', () {
      final normal = Score.fromResult(
          1, Difficulty.normal, const Duration(seconds: 30), 0);
      final blind = Score.fromResult(
          1, Difficulty.normal, const Duration(seconds: 30), 0,
          blindBonus: true);
      expect(blind.score, (normal.score * 1.5).round());
    });

    test('higher difficulty scores higher for the same result', () {
      final slow = Score.fromResult(
          1, Difficulty.slow, const Duration(seconds: 30), 0);
      final insane = Score.fromResult(
          1, Difficulty.insane, const Duration(seconds: 30), 0);
      expect(insane.score, greaterThan(slow.score));
    });
  });
}

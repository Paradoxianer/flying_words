import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';

void main() {
  group('Score.errors', () {
    test('fromResult keeps the error count', () {
      final score =
          Score.fromResult(20, Difficulty.slow, const Duration(seconds: 30), 2);
      expect(score.errors, 2);
    });

    test('errors survive the JSON round trip', () {
      final score = Score(score: 10, errors: 2);
      final restored = Score.fromJson(
          json.decode(json.encode(score.toJson())) as Map<String, dynamic>);
      expect(restored.errors, 2);
    });

    test('legacy JSON without errors stays null', () {
      final restored = Score.fromJson({'score': 10, 'duration': 0});
      expect(restored.errors, isNull);
    });
  });

  group('VerseProgress.stars (#39)', () {
    test('no score means no stars', () {
      expect(VerseProgress().stars(Difficulty.slow), 0);
    });

    test('stars follow the error count on seal I and II', () {
      final progress = VerseProgress();
      progress[Difficulty.slow] = Score(score: 10, errors: 0);
      progress[Difficulty.normal] = Score(score: 10, errors: 2);
      expect(progress.stars(Difficulty.slow), 3);
      expect(progress.stars(Difficulty.normal), 2);

      progress[Difficulty.normal] = Score(score: 10, errors: 5);
      expect(progress.stars(Difficulty.normal), 1);
    });

    test('insane awards a single master star for finishing', () {
      final progress = VerseProgress();
      progress[Difficulty.insane] = Score(score: 10, errors: 0);
      expect(progress.stars(Difficulty.insane), 1);
      expect(VerseProgress.maxStars(Difficulty.insane), 1);
      expect(VerseProgress.maxStars(Difficulty.slow), 3);
    });

    test('legacy scores without an error count are worth one star', () {
      final progress = VerseProgress();
      progress[Difficulty.slow] = Score(score: 10);
      expect(progress.stars(Difficulty.slow), 1);
    });
  });

  group('PlayerProgress keeps the best stars', () {
    test('a higher score with worse stars does not replace a flawless run',
        () {
      final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
      progress.setScoreforVerse(
          'v', Difficulty.slow, Score(score: 100, errors: 0)); // 3 stars
      progress.setScoreforVerse(
          'v', Difficulty.slow, Score(score: 999, errors: 5)); // 1 star

      final kept = progress.getScoreforVerse('v', Difficulty.slow)!;
      expect(kept.errors, 0);
      expect(kept.score, 100);
    });

    test('equal stars: the higher score wins', () {
      final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
      progress.setScoreforVerse(
          'v', Difficulty.slow, Score(score: 100, errors: 0));
      progress.setScoreforVerse(
          'v', Difficulty.slow, Score(score: 300, errors: 0));
      expect(progress.getScoreforVerse('v', Difficulty.slow)!.score, 300);
    });
  });

  group('VerseProgress.unlocked (#26)', () {
    test('seal I is always open', () {
      expect(VerseProgress().unlocked(Difficulty.slow), isTrue);
      expect(VerseProgress().unlocked(Difficulty.normal), isFalse);
      expect(VerseProgress().unlocked(Difficulty.insane), isFalse);
    });

    test('the next seal needs two stars on the previous one', () {
      final progress = VerseProgress();
      progress[Difficulty.slow] = Score(score: 10, errors: 5); // one star
      expect(progress.unlocked(Difficulty.normal), isFalse);

      progress[Difficulty.slow] = Score(score: 10, errors: 2); // two stars
      expect(progress.unlocked(Difficulty.normal), isTrue);
      expect(progress.unlocked(Difficulty.insane), isFalse);

      progress[Difficulty.normal] = Score(score: 10, errors: 0); // three stars
      expect(progress.unlocked(Difficulty.insane), isTrue);
    });
  });
}

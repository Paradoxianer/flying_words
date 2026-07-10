import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';

void main() {
  group('Score JSON', () {
    test('round trip keeps score and duration', () {
      final score = Score(score: 420, duration: const Duration(seconds: 90));
      final restored = Score.fromJson(
          json.decode(json.encode(score.toJson())) as Map<String, dynamic>);
      expect(restored.score, 420);
      expect(restored.duration, const Duration(seconds: 90));
    });
  });

  group('VerseProgress JSON', () {
    test('round trip keeps scores per difficulty', () {
      final progress = VerseProgress();
      progress[Difficulty.slow] = Score(score: 10);
      progress[Difficulty.insane] =
          Score(score: 99, duration: const Duration(seconds: 12));

      final restored = VerseProgress.fromJson(
          json.decode(json.encode(progress.toJson())) as Map<String, dynamic>);

      expect(restored[Difficulty.slow]!.score, 10);
      expect(restored[Difficulty.insane]!.score, 99);
      expect(restored[Difficulty.insane]!.duration, const Duration(seconds: 12));
      expect(restored.containsKey(Difficulty.normal), isFalse);
    });

    test('ignores unknown difficulty names instead of crashing', () {
      final restored = VerseProgress.fromJson({
        'slow': {'score': 5, 'duration': 0},
        'nightmare': {'score': 1, 'duration': 0},
      });
      expect(restored.length, 1);
      expect(restored[Difficulty.slow]!.score, 5);
    });

    test('finished only for positive scores', () {
      final progress = VerseProgress();
      expect(progress.finished(Difficulty.slow), isFalse);
      progress[Difficulty.slow] = Score(score: 0);
      expect(progress.finished(Difficulty.slow), isFalse);
      progress[Difficulty.slow] = Score(score: 3);
      expect(progress.finished(Difficulty.slow), isTrue);
    });

    test('fullScore sums all difficulties', () {
      final progress = VerseProgress();
      progress[Difficulty.slow] = Score(score: 10);
      progress[Difficulty.normal] = Score(score: 25);
      expect(progress.fullScore(), 35);
    });
  });

  group('PlayerProgress.setScoreforVerse', () {
    test('stores a first score and persists it', () async {
      final store = MemoryOnlyPlayerProgressPersistence();
      final progress = PlayerProgress(store);

      progress.setScoreforVerse('Johannes 3, 16', Difficulty.slow, Score(score: 42));

      expect(progress.getScoreforVerse('Johannes 3, 16', Difficulty.slow)!.score, 42);
      expect(progress.playerScore, 42);

      // Wait for the (simulated) async store writes to finish.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final persisted = await store.getPlayerProgress();
      expect(persisted['Johannes 3, 16']![Difficulty.slow]!.score, 42);
      expect(await store.getPlayerHighscore(), 42);
    });

    test('keeps the better score', () {
      final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());

      progress.setScoreforVerse('v', Difficulty.slow, Score(score: 42));
      progress.setScoreforVerse('v', Difficulty.slow, Score(score: 10));
      expect(progress.getScoreforVerse('v', Difficulty.slow)!.score, 42);

      progress.setScoreforVerse('v', Difficulty.slow, Score(score: 50));
      expect(progress.getScoreforVerse('v', Difficulty.slow)!.score, 50);
    });

    test('playerScore sums best scores over verses and difficulties', () {
      final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());

      progress.setScoreforVerse('v1', Difficulty.slow, Score(score: 10));
      progress.setScoreforVerse('v1', Difficulty.insane, Score(score: 100));
      progress.setScoreforVerse('v2', Difficulty.slow, Score(score: 7));

      expect(progress.playerScore, 117);
    });

    test('scores for other difficulties are kept', () {
      final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());

      progress.setScoreforVerse('v', Difficulty.slow, Score(score: 10));
      progress.setScoreforVerse('v', Difficulty.normal, Score(score: 20));

      expect(progress.getScoreforVerse('v', Difficulty.slow)!.score, 10);
      expect(progress.getScoreforVerse('v', Difficulty.normal)!.score, 20);
    });

    test('reset clears everything', () {
      final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
      progress.setScoreforVerse('v', Difficulty.slow, Score(score: 10));

      progress.reset();

      expect(progress.playerScore, 0);
      expect(progress.getScoreforVerse('v', Difficulty.slow), isNull);
    });
  });

  group('PlayerProgress.getLatestFromStore', () {
    test('loads progress and recalculates the highscore', () async {
      final store = MemoryOnlyPlayerProgressPersistence();
      final seed = VerseProgress();
      seed[Difficulty.slow] = Score(score: 30);
      await store.savePlayerProgress({'v': seed});

      final progress = PlayerProgress(store);
      await progress.getLatestFromStore();

      expect(progress.getScoreforVerse('v', Difficulty.slow)!.score, 30);
      expect(progress.playerScore, 30);
    });
  });
}

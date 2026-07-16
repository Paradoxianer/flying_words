import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';

void main() {
  group('VerseProgress.starsForRun (#114)', () {
    test('an absolutely flawless run always earns three stars', () {
      expect(VerseProgress.starsForRun(Difficulty.slow, 0, 3), 3);
      expect(VerseProgress.starsForRun(Difficulty.slow, 0, 40), 3);
      // Even with an unknown word count, zero known errors is unambiguous.
      expect(VerseProgress.starsForRun(Difficulty.slow, 0, null), 3);
    });

    test('an error rate at or under 10% still earns two stars', () {
      // 1/20 = 5%.
      expect(VerseProgress.starsForRun(Difficulty.slow, 1, 20), 2);
      // 2/20 = 10%, right at the boundary.
      expect(VerseProgress.starsForRun(Difficulty.normal, 2, 20), 2);
    });

    test('an error rate over 10% but at or under 30% earns one star', () {
      // 3/20 = 15%.
      expect(VerseProgress.starsForRun(Difficulty.slow, 3, 20), 1);
      // 6/20 = 30%, right at the boundary.
      expect(VerseProgress.starsForRun(Difficulty.normal, 6, 20), 1);
    });

    test(
        'an error rate over 30% earns zero stars - previously there was no '
        'such case at all, so even every single word wrong still earned a '
        'star', () {
      // 7/20 = 35%.
      expect(VerseProgress.starsForRun(Difficulty.slow, 7, 20), 0);
      // Every word wrong.
      expect(VerseProgress.starsForRun(Difficulty.normal, 20, 20), 0);
    });

    test('seal III (insane) always earns its single master star on '
        'completion, regardless of errors', () {
      expect(VerseProgress.starsForRun(Difficulty.insane, 0, 20), 1);
      expect(VerseProgress.starsForRun(Difficulty.insane, 20, 20), 1);
    });

    test(
        'legacy data without a known word count falls back to the old '
        'flat one-star-if-any-errors behavior', () {
      expect(VerseProgress.starsForRun(Difficulty.slow, 5, null), 1);
      expect(VerseProgress.starsForRun(Difficulty.slow, null, 20), 1);
    });
  });

  group('Score JSON', () {
    test('round trip keeps score and duration', () {
      final score = Score(score: 420, duration: const Duration(seconds: 90));
      final restored = Score.fromJson(
          json.decode(json.encode(score.toJson())) as Map<String, dynamic>);
      expect(restored.score, 420);
      expect(restored.duration, const Duration(seconds: 90));
    });

    test('round trip keeps errors and wordCount (#114)', () {
      final score = Score(score: 420, errors: 2, wordCount: 20);
      final restored = Score.fromJson(
          json.decode(json.encode(score.toJson())) as Map<String, dynamic>);
      expect(restored.errors, 2);
      expect(restored.wordCount, 20);
    });

    test('legacy JSON without wordCount restores it as null', () {
      final restored = Score.fromJson({'score': 10, 'duration': 0});
      expect(restored.wordCount, isNull);
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

    test(
        'finished once a Score exists at all, regardless of its value '
        '(#114 - it used to require score > 0, but a score can now be '
        'legitimately 0 for a bad run without blocking verse progression)',
        () {
      final progress = VerseProgress();
      expect(progress.finished(Difficulty.slow), isFalse);
      progress[Difficulty.slow] = Score(score: 0);
      expect(progress.finished(Difficulty.slow), isTrue);
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

  group('PlayerProgress leaderboard stats (#14)', () {
    test('bestSingleRunScore is the highest single run, not the sum', () {
      final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
      progress.setScoreforVerse('a', Difficulty.slow, Score(score: 50));
      progress.setScoreforVerse('b', Difficulty.normal, Score(score: 200));
      progress.setScoreforVerse('b', Difficulty.slow, Score(score: 20));

      expect(progress.bestSingleRunScore, 200);
      // The sum (playerScore) is a different number entirely.
      expect(progress.playerScore, 270);
    });

    test('bestSingleRunScore is 0 with no runs at all', () {
      final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
      expect(progress.bestSingleRunScore, 0);
    });

    test(
        'memorizedVerseCount only counts verses with all 3 stars on Seal II',
        () {
      final progress = PlayerProgress(MemoryOnlyPlayerProgressPersistence());
      // 3 stars on Seal II (normal): flawless run, no errors.
      progress.setScoreforVerse(
          'mastered', Difficulty.normal, Score(score: 50, errors: 0));
      // Only 2 stars on Seal II: a couple of errors.
      progress.setScoreforVerse(
          'in-progress', Difficulty.normal, Score(score: 50, errors: 2));
      // Seal III alone doesn't count - it only requires 2 stars on Seal II
      // to unlock, not 3.
      progress.setScoreforVerse(
          'sealed-iii-only', Difficulty.insane, Score(score: 50));

      expect(
        progress.memorizedVerseCount(
            ['mastered', 'in-progress', 'sealed-iii-only', 'never-played']),
        1,
      );
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

    test(
        'migrates progress stored under an old, localized display key to '
        'the stable verse number (#2)', () async {
      final store = MemoryOnlyPlayerProgressPersistence();
      final seed = VerseProgress();
      seed[Difficulty.slow] = Score(score: 30);
      // Simulates progress persisted before the #2 key migration, keyed by
      // the (localized, unstable) display text instead of the verse number.
      await store.savePlayerProgress({'Johannes 3, 16': seed});
      final lesson =
          Lesson(number: 2, verse: 'Johannes 3, 16', text: 'Denn also');

      final progress = PlayerProgress(store);
      await progress.getLatestFromStore(knownLessons: [lesson]);

      expect(progress.getScoreforVerse('Johannes 3, 16', Difficulty.slow),
          isNull);
      expect(
          progress.getScoreforVerse(verseProgressKey(lesson), Difficulty.slow)!
              .score,
          30);

      // The migration is persisted, not just applied in memory.
      final reloaded = PlayerProgress(store);
      await reloaded.getLatestFromStore();
      expect(
          reloaded
              .getScoreforVerse(verseProgressKey(lesson), Difficulty.slow)!
              .score,
          30);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';

void main() {
  final verses = ['v1', 'v2', 'v3', 'v4', 'v5', 'v6'];

  PlayerProgress freshProgress() =>
      PlayerProgress(MemoryOnlyPlayerProgressPersistence());

  group('verse progression (#52)', () {
    test('three verses are open at the start', () {
      final progress = freshProgress();
      expect(progress.unlockedVerseCount(verses), 3);
      expect(progress.verseUnlocked(verses, 0), isTrue);
      expect(progress.verseUnlocked(verses, 2), isTrue);
      expect(progress.verseUnlocked(verses, 3), isFalse);
    });

    test('finishing a verse on seal I opens the next one', () {
      final progress = freshProgress();
      progress.setScoreforVerse('v1', Difficulty.slow, Score(score: 10));
      expect(progress.unlockedVerseCount(verses), 4);
      expect(progress.verseUnlocked(verses, 3), isTrue);
      expect(progress.verseUnlocked(verses, 4), isFalse);
    });

    test('only seal I counts for unlocking, not the harder seals', () {
      final progress = freshProgress();
      // A win on normal without one on slow should not chain-unlock.
      progress.setScoreforVerse('v1', Difficulty.normal, Score(score: 10));
      expect(progress.unlockedVerseCount(verses), 3);
    });

    test('the count is capped at the number of verses', () {
      final progress = freshProgress();
      for (final v in verses) {
        progress.setScoreforVerse(v, Difficulty.slow, Score(score: 10));
      }
      expect(progress.unlockedVerseCount(verses), verses.length);
    });
  });
}

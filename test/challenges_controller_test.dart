import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/challenges/challenges_controller.dart';
import 'package:flying_words/src/challenges/challenges_data.dart';
import 'package:flying_words/src/challenges/persistence/memory_challenges_persistence.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/jokers/joker_type.dart';

void main() {
  group('ChallengesController.ensureCurrent', () {
    test('rolls a daily verse from the unlocked list on first call', () async {
      final controller = ChallengesController(MemoryOnlyChallengesPersistence());
      await controller.ensureCurrent([1, 2, 3], now: DateTime(2026, 7, 20));

      expect(controller.data.dailyDate, '2026-07-20');
      expect([1, 2, 3], contains(controller.data.dailyVerseNumber));
      expect(controller.data.dailyClaimed, isFalse);
    });

    test('keeps the same daily verse on repeated calls the same day',
        () async {
      final controller = ChallengesController(MemoryOnlyChallengesPersistence());
      await controller.ensureCurrent([1, 2, 3], now: DateTime(2026, 7, 20, 9));
      final first = controller.data.dailyVerseNumber;

      await controller.ensureCurrent([1, 2, 3], now: DateTime(2026, 7, 20, 21));
      expect(controller.data.dailyVerseNumber, first);
    });

    test('rolls a new daily verse and resets dailyClaimed the next day',
        () async {
      final controller = ChallengesController(MemoryOnlyChallengesPersistence());
      await controller.ensureCurrent([5], now: DateTime(2026, 7, 20));
      await controller.registerWin(
        verseNumber: 5,
        difficulty: Difficulty.slow,
        errors: 0,
        now: DateTime(2026, 7, 20),
      );
      expect(controller.data.dailyClaimed, isTrue);

      await controller.ensureCurrent([5], now: DateTime(2026, 7, 21));
      expect(controller.data.dailyDate, '2026-07-21');
      expect(controller.data.dailyClaimed, isFalse);
    });

    test('rolls one of the three weekly variants, stable within the week',
        () async {
      final controller = ChallengesController(MemoryOnlyChallengesPersistence());
      // Wednesday.
      await controller.ensureCurrent([1], now: DateTime(2026, 7, 22));
      final difficulty = controller.data.weeklyDifficulty;
      final target = controller.data.weeklyTarget;
      expect(weeklyVariants.map((v) => v.difficulty), contains(difficulty));
      expect(target, greaterThan(0));

      // Friday, same week: unchanged.
      await controller.ensureCurrent([1], now: DateTime(2026, 7, 24));
      expect(controller.data.weeklyDifficulty, difficulty);
      expect(controller.data.weeklyTarget, target);

      // The following Monday: a new week starts.
      await controller.ensureCurrent([1], now: DateTime(2026, 7, 27));
      expect(controller.data.weekStart, '2026-07-27');
      expect(controller.data.weeklyStars, 0);
      expect(controller.data.weeklyClaimed, isFalse);
    });
  });

  group('ChallengesController.registerWin', () {
    test('awards a Joker for completing the daily verse on seal I',
        () async {
      final controller = ChallengesController(MemoryOnlyChallengesPersistence());
      await controller.ensureCurrent([7], now: DateTime(2026, 7, 20));
      final verse = controller.data.dailyVerseNumber!;

      final earned = await controller.registerWin(
        verseNumber: verse,
        difficulty: Difficulty.slow,
        errors: 0,
        now: DateTime(2026, 7, 20),
      );

      expect(earned, hasLength(1));
      expect(controller.data.dailyClaimed, isTrue);

      // Claiming again the same day earns nothing more.
      final earnedAgain = await controller.registerWin(
        verseNumber: verse,
        difficulty: Difficulty.slow,
        errors: 0,
        now: DateTime(2026, 7, 20, 12),
      );
      expect(earnedAgain, isEmpty);
    });

    test('does not award the daily Joker on the wrong seal', () async {
      final controller = ChallengesController(MemoryOnlyChallengesPersistence());
      await controller.ensureCurrent([7], now: DateTime(2026, 7, 20));
      final verse = controller.data.dailyVerseNumber!;

      final earned = await controller.registerWin(
        verseNumber: verse,
        difficulty: Difficulty.normal,
        errors: 0,
        now: DateTime(2026, 7, 20),
      );
      expect(earned, isEmpty);
      expect(controller.data.dailyClaimed, isFalse);
    });

    test('accumulates weekly stars only on the rolled seal and claims once '
        'the target is reached', () async {
      final controller = ChallengesController(MemoryOnlyChallengesPersistence());
      await controller.ensureCurrent([1], now: DateTime(2026, 7, 20));
      // Force a known variant regardless of the random roll.
      final difficulty = controller.data.weeklyDifficulty!;
      final target = controller.data.weeklyTarget;

      // A run on a different seal doesn't count.
      final otherDifficulty = Difficulty.values
          .firstWhere((d) => d != difficulty);
      await controller.registerWin(
        verseNumber: 1,
        difficulty: otherDifficulty,
        errors: 0,
        now: DateTime(2026, 7, 20),
      );
      expect(controller.data.weeklyStars, 0);

      // Flawless runs on the rolled seal earn 3 stars each (or 1 on insane).
      final starsPerRun = difficulty == Difficulty.insane ? 1 : 3;
      final runsNeeded = (target / starsPerRun).ceil();
      List<int> earnedCounts = [];
      for (var i = 0; i < runsNeeded; i++) {
        final earned = await controller.registerWin(
          verseNumber: 1,
          difficulty: difficulty,
          errors: 0,
          // Same day every time, so the streak logic can't also award a
          // Joker and skew the count this test is checking.
          now: DateTime(2026, 7, 20, 8 + i),
        );
        earnedCounts.add(earned.length);
      }
      expect(controller.data.weeklyClaimed, isTrue);
      expect(controller.data.weeklyStars, greaterThanOrEqualTo(target));
      // The 2-Joker reward is granted exactly once, on the run that hits
      // the target.
      expect(earnedCounts.where((c) => c > 0).length, 1);
    });

    test('streak grows on consecutive days and resets after a gap',
        () async {
      final controller = ChallengesController(MemoryOnlyChallengesPersistence());
      await controller.registerWin(
        verseNumber: 1,
        difficulty: Difficulty.slow,
        errors: 0,
        now: DateTime(2026, 7, 20),
      );
      expect(controller.data.streakDays, 1);

      await controller.registerWin(
        verseNumber: 1,
        difficulty: Difficulty.slow,
        errors: 0,
        now: DateTime(2026, 7, 21),
      );
      expect(controller.data.streakDays, 2);

      // Playing again the same day doesn't double-count.
      await controller.registerWin(
        verseNumber: 1,
        difficulty: Difficulty.slow,
        errors: 0,
        now: DateTime(2026, 7, 21, 20),
      );
      expect(controller.data.streakDays, 2);

      // A missed day resets the streak to 1, not 0.
      await controller.registerWin(
        verseNumber: 1,
        difficulty: Difficulty.slow,
        errors: 0,
        now: DateTime(2026, 7, 23),
      );
      expect(controller.data.streakDays, 1);
    });

    test('awards a Joker at the 3-day and 7-day streak milestones, once each',
        () async {
      final controller = ChallengesController(MemoryOnlyChallengesPersistence());
      final start = DateTime(2026, 7, 20);
      final rewardCounts = <int>[];
      for (var day = 0; day < 7; day++) {
        final earned = await controller.registerWin(
          verseNumber: 1,
          difficulty: Difficulty.slow,
          errors: 5,
          now: start.add(Duration(days: day)),
        );
        rewardCounts.add(earned.length);
      }
      expect(controller.data.streakDays, 7);
      // Day index 2 (the 3rd day) and day index 6 (the 7th day) award one
      // Joker each from the streak; no other day does.
      expect(rewardCounts[2], 1);
      expect(rewardCounts[6], 1);
      expect(rewardCounts[0] + rewardCounts[1] + rewardCounts[3] +
          rewardCounts[4] + rewardCounts[5], 0);
      expect(controller.data.streak3Claimed, isTrue);
      expect(controller.data.streak7Claimed, isTrue);
    });

    test('a broken streak can earn the milestones again', () async {
      final controller = ChallengesController(MemoryOnlyChallengesPersistence());
      for (var day = 0; day < 3; day++) {
        await controller.registerWin(
          verseNumber: 1,
          difficulty: Difficulty.slow,
          errors: 5,
          now: DateTime(2026, 7, 20).add(Duration(days: day)),
        );
      }
      expect(controller.data.streak3Claimed, isTrue);

      // Skip several days, breaking the streak.
      final earned = await controller.registerWin(
        verseNumber: 1,
        difficulty: Difficulty.slow,
        errors: 5,
        now: DateTime(2026, 7, 30),
      );
      expect(earned, isEmpty);
      expect(controller.data.streakDays, 1);
      expect(controller.data.streak3Claimed, isFalse);
    });
  });

  group('ChallengesController.randomJokerType', () {
    test('always returns one of the four Joker types', () {
      final controller = ChallengesController(
        MemoryOnlyChallengesPersistence(),
        random: Random(42),
      );
      for (var i = 0; i < 20; i++) {
        expect(JokerType.values, contains(controller.randomJokerType()));
      }
    });
  });

  group('ChallengesController persistence', () {
    test('getLatestFromStore loads previously persisted data', () async {
      final store = MemoryOnlyChallengesPersistence();
      final seed = ChallengesController(store);
      await seed.ensureCurrent([1, 2, 3], now: DateTime(2026, 7, 20));
      // Flush the simulated async persistence write.
      await Future<void>.delayed(const Duration(milliseconds: 600));

      final loaded = ChallengesController(store);
      await loaded.getLatestFromStore();
      expect(loaded.data.dailyDate, '2026-07-20');
      expect(loaded.data.dailyVerseNumber, seed.data.dailyVerseNumber);
    });

    test('concurrent calls only load from the store once', () async {
      final store = MemoryOnlyChallengesPersistence();
      await store.saveData(const ChallengesData());
      final controller = ChallengesController(store);

      // Both race to trigger the load; must not clobber each other.
      final results = await Future.wait([
        controller.ensureCurrent([1, 2, 3], now: DateTime(2026, 7, 20)),
        controller.getLatestFromStore(),
      ]);
      expect(results, hasLength(2));
      expect(controller.data.dailyDate, '2026-07-20');
      expect(controller.data.dailyVerseNumber, isNotNull);
    });
  });
}

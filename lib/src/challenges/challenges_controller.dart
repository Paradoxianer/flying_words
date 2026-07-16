// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../game_internals/lesson.dart';
import '../jokers/joker_type.dart';
import '../player_progress/player_progress.dart';
import 'challenges_data.dart';
import 'persistence/challenges_persistence.dart';

/// The three weekly star-goal variants (#53): easier seals need more stars
/// per run to reach the same target, harder seals need fewer runs but each
/// one is tougher - so all three take roughly comparable effort.
const weeklyVariants = [
  (difficulty: Difficulty.slow, target: 12),
  (difficulty: Difficulty.normal, target: 6),
  (difficulty: Difficulty.insane, target: 3),
];

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime _mondayOf(DateTime d) {
  final date = DateTime(d.year, d.month, d.day);
  return date.subtract(Duration(days: date.weekday - 1));
}

int _seedFor(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

/// Tracks the daily verse, the weekly star goal and the play streak (#53
/// Phase C) - local-only, no backend needed. Awards Jokers as the reward
/// currency; the caller (see `PlaySessionScreen._playerWon`) is
/// responsible for actually crediting them to [JokerInventoryController],
/// keeping this controller decoupled from that one.
class ChallengesController extends ChangeNotifier {
  final ChallengesPersistence _store;
  final Random _random;

  ChallengesData _data = const ChallengesData();

  /// Memoizes the initial load so it only ever happens once, however many
  /// callers ask for it concurrently ([ensureCurrent], [registerWin], an
  /// explicit [getLatestFromStore] call from `main.dart`) - without this,
  /// a load landing *after* one of the read-modify-write methods below had
  /// already rolled and saved fresh data would clobber it with the older
  /// stored state.
  Future<void>? _loadFuture;

  ChallengesController(ChallengesPersistence store, {Random? random})
      : _store = store,
        _random = random ?? Random();

  ChallengesData get data => _data;

  Future<void> _ensureLoaded() {
    return _loadFuture ??= _store.getData().then((loaded) {
      _data = loaded;
      notifyListeners();
    });
  }

  Future<void> getLatestFromStore() => _ensureLoaded();

  void _save() {
    notifyListeners();
    unawaited(_store.saveData(_data));
  }

  JokerType randomJokerType() =>
      JokerType.values[_random.nextInt(JokerType.values.length)];

  /// Rolls a fresh daily verse and/or weekly goal if the stored ones have
  /// expired. [unlockedVerseNumbers] must be the curated verses ([Lesson]s)
  /// already unlocked in [PlayerProgress] - the daily verse is drawn only
  /// from those, so a player can always actually play it.
  Future<void> ensureCurrent(List<int> unlockedVerseNumbers,
      {DateTime? now}) async {
    await _ensureLoaded();
    if (unlockedVerseNumbers.isEmpty) return;
    final today = now ?? DateTime.now();
    final todayKey = dateKey(today);
    final weekStartKey = dateKey(_mondayOf(today));

    var next = _data;
    var changed = false;

    if (_data.dailyDate != todayKey) {
      final pick = unlockedVerseNumbers[
          Random(_seedFor(today)).nextInt(unlockedVerseNumbers.length)];
      next = next.copyWith(
        dailyDate: todayKey,
        dailyVerseNumber: pick,
        dailyClaimed: false,
      );
      changed = true;
    }

    if (_data.weekStart != weekStartKey) {
      final variant = weeklyVariants[
          Random(_seedFor(_mondayOf(today))).nextInt(weeklyVariants.length)];
      next = next.copyWith(
        weekStart: weekStartKey,
        weeklyDifficulty: variant.difficulty,
        weeklyTarget: variant.target,
        weeklyStars: 0,
        weeklyClaimed: false,
      );
      changed = true;
    }

    if (changed) {
      _data = next;
      _save();
    }
  }

  /// Updates the streak and the daily/weekly progress for a just-won run,
  /// awarding a random Joker for each thing newly completed. Call
  /// [ensureCurrent] first so today's/this week's challenge is current.
  Future<List<JokerType>> registerWin({
    required int verseNumber,
    required Difficulty difficulty,
    required int errors,
    DateTime? now,
  }) async {
    await _ensureLoaded();
    final today = now ?? DateTime.now();
    final todayKey = dateKey(today);
    final earned = <JokerType>[];
    var next = _data;

    // Streak: any win counts, at most once per day.
    if (next.lastPlayedDate != todayKey) {
      final yesterdayKey = dateKey(today.subtract(const Duration(days: 1)));
      final continues = next.lastPlayedDate == yesterdayKey;
      final streakDays = continues ? next.streakDays + 1 : 1;
      next = next.copyWith(
        lastPlayedDate: todayKey,
        streakDays: streakDays,
        // A fresh streak can earn the milestones again.
        streak3Claimed: continues ? next.streak3Claimed : false,
        streak7Claimed: continues ? next.streak7Claimed : false,
      );
      if (streakDays >= 3 && !next.streak3Claimed) {
        next = next.copyWith(streak3Claimed: true);
        earned.add(randomJokerType());
      }
      if (streakDays >= 7 && !next.streak7Claimed) {
        next = next.copyWith(streak7Claimed: true);
        earned.add(randomJokerType());
      }
    }

    // "Vers des Tages": today's verse, on seal I, once a day.
    if (!next.dailyClaimed &&
        next.dailyDate == todayKey &&
        next.dailyVerseNumber == verseNumber &&
        difficulty == Difficulty.slow) {
      next = next.copyWith(dailyClaimed: true);
      earned.add(randomJokerType());
    }

    // "Wochen-Schreiber": stars earned this week on the rolled seal.
    if (!next.weeklyClaimed && next.weeklyDifficulty == difficulty) {
      final stars = VerseProgress.starsForRun(difficulty, errors);
      final weeklyStars = next.weeklyStars + stars;
      next = next.copyWith(weeklyStars: weeklyStars);
      if (weeklyStars >= next.weeklyTarget) {
        next = next.copyWith(weeklyClaimed: true);
        earned.addAll([randomJokerType(), randomJokerType()]);
      }
    }

    _data = next;
    _save();
    return earned;
  }
}

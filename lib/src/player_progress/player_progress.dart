// Copyright 2023, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:quiver/collection.dart';

import 'persistence/player_progress_persistence.dart';

//a Wrapper around a Map<Difficulty, Score> to make the Code more readable and
// and  implement some more Features
class VerseProgress extends DelegatingMap<Difficulty, Score> {
  final Map<Difficulty, Score> _progress = {};

  VerseProgress();

  @override
  Map<Difficulty, Score> get delegate => _progress;

  factory VerseProgress.fromJson(Map<String, dynamic> json) {
    final verseProgress = VerseProgress();
    json.forEach((key, value) {
      final difficulty = Difficulty.values.asNameMap()[key];
      if (difficulty != null && value is Map<String, dynamic>) {
        verseProgress[difficulty] = Score.fromJson(value);
      }
    });
    return verseProgress;
  }

  // JSON only allows String keys, so the Difficulty enum is stored by name.
  Map<String, dynamic> toJson() =>
      _progress.map((difficulty, score) => MapEntry(difficulty.name, score.toJson()));

  bool finished(Difficulty difficulty) => (this[difficulty]?.score ?? 0) > 0;

  /// Maximum stars for [difficulty]: seal I and II award up to three stars,
  /// seal III (insane) a single "master star" - finishing it at all is the
  /// achievement. (Design decision in #39.)
  static int maxStars(Difficulty difficulty) =>
      difficulty == Difficulty.insane ? 1 : 3;

  /// Stars for a single finished run on [difficulty] with [errors] errors:
  /// three for a flawless run, two for at most two errors, one for
  /// finishing. Legacy scores without an error count are worth one star.
  static int starsForRun(Difficulty difficulty, int? errors) {
    if (difficulty == Difficulty.insane) {
      return 1;
    }
    if (errors == null) {
      return 1;
    }
    if (errors == 0) {
      return 3;
    }
    return errors <= 2 ? 2 : 1;
  }

  /// Stars earned on [difficulty] (best stored run).
  int stars(Difficulty difficulty) {
    final score = this[difficulty];
    if (score == null || score.score <= 0) {
      return 0;
    }
    return starsForRun(difficulty, score.errors);
  }

  /// A difficulty unlocks once the previous one has at least two stars
  /// (strict unlocking, design decision in #39). Seal I is always open.
  bool unlocked(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.slow:
        return true;
      case Difficulty.normal:
        return stars(Difficulty.slow) >= 2;
      case Difficulty.insane:
        return stars(Difficulty.normal) >= 2;
    }
  }

  int fullScore() {
    int fullScore = 0;
    forEach((key, value) {
      fullScore += value.score;
    });
    return fullScore;
  }
}

/// Encapsulates the player's progress.
class PlayerProgress extends ChangeNotifier {
  int _playerScore = 0;

  //String defines a verse the other map is a Map where the Score corresponding to the given difficulty is stored
  Map<String, VerseProgress> _progress = <String, VerseProgress>{};
  final PlayerProgressPersistence _store;

  /// Creates an instance of [PlayerProgress] backed by an injected
  /// persistence [store].
  PlayerProgress(PlayerProgressPersistence store) : _store = store;

  /// The sum of the best scores over all verses and difficulties.
  int get playerScore => _playerScore;

  /// Fetches the latest data from the backing persistence store.
  ///
  /// [knownLessons] (curated + custom verses) is used once to migrate
  /// progress stored under the old, localized display-text keys to the
  /// stable [verseProgressKey] (#2) - safe to pass every time since already
  /// migrated keys are left untouched.
  Future<void> getLatestFromStore({List<Lesson> knownLessons = const []}) async {
    final stored = await _store.getPlayerProgress();
    final migrated = _migrateLegacyKeys(stored, knownLessons);
    _progress = migrated.progress;
    final storedHighscore = await _store.getPlayerHighscore();
    _playerScore = _calculateTotalScore();
    // A stored highscore can be higher than the recalculated one, e.g. after
    // progress data was lost; never lower the player's highscore silently.
    if (storedHighscore > _playerScore) {
      _playerScore = storedHighscore;
    } else if (storedHighscore < _playerScore) {
      await _store.savePlayerHighscore(_playerScore);
    }
    if (migrated.changed) {
      unawaited(_store.savePlayerProgress(_progress));
    }
    notifyListeners();
  }

  /// Remaps any key in [stored] that matches a known lesson's old, localized
  /// display text to that lesson's stable [verseProgressKey]; keys that are
  /// already stable (or match nothing known) are left as they are.
  ({Map<String, VerseProgress> progress, bool changed}) _migrateLegacyKeys(
      Map<String, VerseProgress> stored, List<Lesson> knownLessons) {
    final keyForDisplay = {
      for (final lesson in knownLessons) lesson.verse: verseProgressKey(lesson),
    };
    var changed = false;
    final result = <String, VerseProgress>{};
    stored.forEach((key, value) {
      final newKey = keyForDisplay[key];
      if (newKey != null && newKey != key) changed = true;
      result[newKey ?? key] = value;
    });
    return (progress: result, changed: changed);
  }

  /// Resets the player's progress so it's like if they just started
  /// playing the game for the first time.
  void reset() {
    _playerScore = 0;
    _progress.clear();
    notifyListeners();
    _store.savePlayerHighscore(_playerScore);
    _store.savePlayerProgress(_progress);
  }

  /// only called if you sucessfull finished a Difficutly on a Lesson
  void setScoreforVerse(String verse, Difficulty difficulty, Score score) {
    final verseProgress = _progress.putIfAbsent(verse, () => VerseProgress());
    final existing = verseProgress[difficulty];
    if (existing != null) {
      // Stars must never go down: keep the run with more stars, and only
      // for equal stars the one with the higher score.
      final existingStars =
          VerseProgress.starsForRun(difficulty, existing.errors);
      final newStars = VerseProgress.starsForRun(difficulty, score.errors);
      if (existingStars > newStars ||
          (existingStars == newStars && existing.score >= score.score)) {
        return;
      }
    }
    verseProgress[difficulty] = score;
    _playerScore = _calculateTotalScore();
    notifyListeners();
    unawaited(_store.savePlayerHighscore(_playerScore));
    unawaited(_store.savePlayerProgress(_progress));
  }

  Score? getScoreforVerse(String verse, Difficulty difficulty) =>
      _progress[verse]?[difficulty];

  /// The progress for [verse]; empty (nothing unlocked beyond seal I,
  /// no stars) if the verse was never played.
  VerseProgress progressForVerse(String verse) =>
      _progress[verse] ?? VerseProgress();

  /// Number of verses open at the start before any is finished (#52).
  static const initialUnlockedVerses = 3;

  /// How many verses of [orderedVerses] are unlocked: the first
  /// [initialUnlockedVerses] plus one more for every verse finished on
  /// seal I (chain unlock), capped at the list length. Passing the verse
  /// references in play order keeps the chain independent of the data
  /// source (#15).
  int unlockedVerseCount(List<String> orderedVerses) {
    var finished = 0;
    for (final verse in orderedVerses) {
      if (progressForVerse(verse).finished(Difficulty.slow)) {
        finished++;
      }
    }
    final unlocked = initialUnlockedVerses + finished;
    return unlocked > orderedVerses.length ? orderedVerses.length : unlocked;
  }

  /// Whether the verse at [index] in [orderedVerses] is unlocked (#52).
  bool verseUnlocked(List<String> orderedVerses, int index) =>
      index < unlockedVerseCount(orderedVerses);

  /// The single highest score across every verse and difficulty - unlike
  /// [playerScore], which is the sum of all of them. Feeds the "best single
  /// run" leaderboard (#14).
  int get bestSingleRunScore {
    var best = 0;
    for (final verseProgress in _progress.values) {
      for (final score in verseProgress.values) {
        if (score.score > best) best = score.score;
      }
    }
    return best;
  }

  /// How many of [verseKeys] are mastered with all 3 stars on Seal II - the
  /// bar decided on for "learned by heart" in #14's leaderboard discussion.
  /// Reaching Seal III doesn't automatically count: it only requires 2
  /// stars on Seal II to unlock, not 3.
  int memorizedVerseCount(List<String> verseKeys) => verseKeys
      .where((key) => progressForVerse(key).stars(Difficulty.normal) == 3)
      .length;

  int _calculateTotalScore() {
    int total = 0;
    for (final verseProgress in _progress.values) {
      total += verseProgress.fullScore();
    }
    return total;
  }

  // TODO: When ready, change these achievement IDs.
  // You configure this in App Store Connect.
  //achievementIdIOS: 'first_win',
  // You get this string when you configure an achievement in Play Console.
  //achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
}

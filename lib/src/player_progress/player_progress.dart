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

  /// A verse/difficulty is "finished" once it has been played at all - a
  /// stored [Score] exists, regardless of how good it is. Deliberately not
  /// based on the score's *value* (#114): that used to force every score
  /// to be at least 1 (see the old `Score.fromResult`), which is also why
  /// a run with every single word wrong could still earn a star, points,
  /// and count as a new best.
  bool finished(Difficulty difficulty) => this[difficulty] != null;

  /// Maximum stars for [difficulty]: seal I and II award up to three stars,
  /// seal III (insane) a single "master star" - finishing it at all is the
  /// achievement, *if* it was actually cleared and not just survived
  /// (design decision in #39, refined in #114: without an accuracy floor
  /// the master star wouldn't mean anything, since infinite errors would
  /// earn the same star as a clean run).
  static int maxStars(Difficulty difficulty) =>
      difficulty == Difficulty.insane ? 1 : 3;

  /// The error rate (errors / wordCount) below which a run still earns two
  /// stars, and below which it earns at least one - on seal III this is
  /// the single line between earning the master star or not (#114).
  /// Anything above [oneStarMaxErrorRate] earns zero - there used to be no
  /// such case at all, so even a completely botched run earned a star.
  static const twoStarMaxErrorRate = 0.10;
  static const oneStarMaxErrorRate = 0.30;

  /// Stars for a single finished run on [difficulty] with [errors] errors
  /// out of [wordCount] words: three (or, on seal III, the single master
  /// star) only for an absolutely flawless run, then fewer depending on
  /// the error *rate* (#114) - a fixed error count doesn't scale fairly
  /// across verses of very different lengths. Legacy scores saved before
  /// [wordCount] was tracked, or with an unknown error count, are worth
  /// one star if they have any errors at all (or the max if they're known
  /// to have none).
  static int starsForRun(Difficulty difficulty, int? errors, int? wordCount) {
    if (errors == 0) {
      return maxStars(difficulty);
    }
    if (errors == null || wordCount == null || wordCount <= 0) {
      // Legacy data (or an unknown error count): conservative flat one
      // star, same fallback this used to be for every difficulty.
      return 1;
    }
    final errorRate = errors / wordCount;
    if (difficulty == Difficulty.insane) {
      return errorRate <= oneStarMaxErrorRate ? 1 : 0;
    }
    if (errorRate <= twoStarMaxErrorRate) {
      return 2;
    }
    if (errorRate <= oneStarMaxErrorRate) {
      return 1;
    }
    return 0;
  }

  /// Stars earned on [difficulty] (best stored run).
  int stars(Difficulty difficulty) {
    final score = this[difficulty];
    if (score == null) {
      return 0;
    }
    return starsForRun(difficulty, score.errors, score.wordCount);
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
      final existingStars = VerseProgress.starsForRun(
          difficulty, existing.errors, existing.wordCount);
      final newStars = VerseProgress.starsForRun(
          difficulty, score.errors, score.wordCount);
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

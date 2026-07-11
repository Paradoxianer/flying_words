// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../game_internals/bible_reference.dart';
import '../game_internals/lesson.dart';
import '../player_progress/player_progress.dart';
import 'bible_api_client.dart';
import 'persistence/custom_verses_persistence.dart';

/// Whether the "own verses" feature is unlocked: every curated verse must
/// be finished on seal I first (#52/#15). [curatedVerses] are the display
/// references in play order.
bool customVersesUnlocked(
    List<String> curatedVerses, PlayerProgress progress) {
  if (curatedVerses.isEmpty) return false;
  return curatedVerses.every(
      (verse) => progress.progressForVerse(verse).finished(Difficulty.slow));
}

/// Manages the verses the player added themselves. New verses come in
/// packs: a new one can only be added while fewer than [packSize] of the
/// existing custom verses are still unfinished on seal I (#15/#52).
class CustomVersesController extends ChangeNotifier {
  /// How many unfinished custom verses block adding more.
  static const packSize = 3;

  final CustomVersesPersistence _store;
  final BibleApiClient _api;

  List<Lesson> _verses = [];
  List<Lesson> get verses => List.unmodifiable(_verses);

  CustomVersesController({
    required CustomVersesPersistence store,
    required BibleApiClient api,
  })  : _store = store,
        _api = api;

  Future<void> loadFromStore() async {
    _verses = await _store.load();
    notifyListeners();
  }

  /// Custom verses not yet finished on seal I.
  int unfinishedCount(PlayerProgress progress) => _verses
      .where(
          (l) => !progress.progressForVerse(l.verse).finished(Difficulty.slow))
      .length;

  /// A new custom verse may be added while fewer than [packSize] existing
  /// ones are still unfinished - this enforces the "packs of three" rule.
  bool canAddMore(PlayerProgress progress) =>
      unfinishedCount(progress) < packSize;

  /// Fetches the passage text for [display]/[reference] via the Bible API
  /// and adds it as a custom verse. Throws [VerseFetchException] on failure
  /// and [StateError] if the pack limit is reached.
  Future<Lesson> addFromReference({
    required BibleReference reference,
    required String display,
    required PlayerProgress progress,
    String? translation,
  }) async {
    if (!canAddMore(progress)) {
      throw StateError('Erst die offenen eigenen Verse abschließen.');
    }
    final fetched =
        await _api.fetchPassage(reference, translation: translation);
    final lesson = Lesson(
      // Custom verse numbers continue after the largest one so they stay
      // unique across the merged list.
      number: _nextNumber(),
      verse: display,
      text: fetched.text,
      reference: reference,
      translation: fetched.translation,
      custom: true,
    );
    _verses = [..._verses, lesson];
    notifyListeners();
    unawaited(_store.save(_verses));
    return lesson;
  }

  Future<void> remove(String display) async {
    _verses = _verses.where((l) => l.verse != display).toList();
    notifyListeners();
    await _store.save(_verses);
  }

  int _nextNumber() {
    var max = 1000; // keep custom numbers well clear of the curated ones
    for (final l in _verses) {
      if (l.number >= max) max = l.number + 1;
    }
    return max;
  }
}

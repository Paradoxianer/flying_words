// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flying_words/src/player_progress/player_progress.dart';

import 'player_progress_persistence.dart';

/// An in-memory implementation of [PlayerProgressPersistence].
/// Useful for testing.
class MemoryOnlyPlayerProgressPersistence implements PlayerProgressPersistence {
  int _highScore = 0;
  Map<String, VerseProgress> _progress = <String, VerseProgress>{};

  @override
  Future<int> getPlayerHighscore() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _highScore;
  }

  @override
  Future<Map<String, VerseProgress>> getPlayerProgress() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _progress;
  }

  @override
  Future<void> savePlayerHighscore(int highScore) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _highScore = highScore;
  }

  @override
  Future<void> savePlayerProgress(
      Map<String, VerseProgress> playerProgress) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _progress = playerProgress;
  }
}

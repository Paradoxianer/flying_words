// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';
import 'package:games_services/games_services.dart';

/// An interface of persistence stores for the player's progress.
///
/// Implementations can range from simple in-memory storage through
/// local preferences to cloud saves.
abstract class PlayerProgressPersistence {

  Future<int> getPlayerHighscore();
  Future<Map<String,VerseProgress>> getPlayerProgress();
  Future<Score?> getPlayerScore(String verse, Difficulty forDifficulty);


  Future<void> savePlayerHighscore(int level);
  Future<void> savePlayerProgress(Map<String,VerseProgress> playerProgress);
  Future<void> savePlayerScore(String verse, Difficulty forDifficulty, Score score);
}

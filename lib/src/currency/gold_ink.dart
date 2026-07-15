// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../game_internals/lesson.dart';
import '../player_progress/player_progress.dart';
import 'persistence/gold_ink_persistence.dart';

/// Base Goldtinte reward per seal, before the flawless bonus (decided in
/// #54's discussion).
const goldInkBaseReward = {
  Difficulty.slow: 10,
  Difficulty.normal: 25,
  Difficulty.insane: 60,
};

/// Goldtinte earned for a run on [difficulty] with [errors] mistakes: the
/// seal's base reward, plus 50% for a flawless (max-star) run.
int goldInkForRun(Difficulty difficulty, int errors) {
  final base = goldInkBaseReward[difficulty]!;
  final stars = VerseProgress.starsForRun(difficulty, errors);
  final flawless = stars >= VerseProgress.maxStars(difficulty);
  return flawless ? (base * 1.5).round() : base;
}

/// Tracks the player's Goldtinte ("gold ink") balance - the in-game
/// currency earned by finishing verses (#54). Spending it on Jokers is a
/// later step (#53).
class GoldInkController extends ChangeNotifier {
  final GoldInkPersistence _store;

  int _balance = 0;

  GoldInkController(GoldInkPersistence store) : _store = store;

  int get balance => _balance;

  Future<void> getLatestFromStore() async {
    _balance = await _store.getBalance();
    notifyListeners();
  }

  /// Adds [amount] to the balance and persists it.
  void earn(int amount) {
    if (amount <= 0) return;
    _balance += amount;
    notifyListeners();
    unawaited(_store.saveBalance(_balance));
  }
}

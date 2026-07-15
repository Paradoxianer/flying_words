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
/// seal's base reward, plus 50% for a flawless (max-star) run, plus another
/// 50% if [blindBonus] applies (the verse text was hidden the whole run) -
/// the same two bonuses and the same stacking `Score.fromResult` already
/// uses for the run's score. If [jokerUsed] applies (any joker was used
/// this run, #53), the total is halved afterwards - the steep joker price
/// is the main economic brake, this is just a reward-layer correction and
/// never touches stars, score or leaderboards.
int goldInkForRun(Difficulty difficulty, int errors,
    {bool blindBonus = false, bool jokerUsed = false}) {
  final base = goldInkBaseReward[difficulty]!;
  final stars = VerseProgress.starsForRun(difficulty, errors);
  final flawless = stars >= VerseProgress.maxStars(difficulty);
  var amount = flawless ? base * 1.5 : base.toDouble();
  if (blindBonus) amount *= 1.5;
  if (jokerUsed) amount *= 0.5;
  return amount.round();
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

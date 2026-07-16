// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../game_internals/lesson.dart';
import '../player_progress/player_progress.dart';
import 'persistence/gold_ink_persistence.dart';

/// Goldtinte reward per seal for a flawless run (revised 16.07.2026: a run
/// with any errors used to still earn the full base reward, which felt
/// wrong - 5 errors on seal II paid out the same 25 as a perfect run).
const goldInkBaseReward = {
  Difficulty.slow: 5,
  Difficulty.normal: 12,
  Difficulty.insane: 25,
};

/// Goldtinte granted for watching a rewarded ad in the shop (#54 Phase D
/// addendum) - deliberately equal to a flawless seal I win, so it reads as
/// "worth about the easiest win" rather than a shortcut past earning it.
final goldInkRewardedAdAmount = goldInkBaseReward[Difficulty.slow]!;

/// Goldtinte earned for a run on [difficulty] with [errors] mistakes.
///
/// Only a flawless (max-star) run earns anything at all - seal I/II need
/// zero errors, seal III's only star is already a completion star, so any
/// finish there counts. On top of that: +50% if [blindBonus] applies (the
/// verse text was hidden the whole run), the same bonus and stacking
/// `Score.fromResult` uses for the run's score; halved if [jokerUsed]
/// applies (any joker was used this run, #53) - the steep joker price is
/// the main economic brake, this is just a reward-layer correction and
/// never touches stars, score or leaderboards.
int goldInkForRun(Difficulty difficulty, int errors,
    {bool blindBonus = false, bool jokerUsed = false}) {
  final stars = VerseProgress.starsForRun(difficulty, errors);
  final flawless = stars >= VerseProgress.maxStars(difficulty);
  if (!flawless) return 0;
  var amount = goldInkBaseReward[difficulty]!.toDouble();
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

  /// Deducts [amount] from the balance if there's enough (#54 Phase D
  /// shop); returns whether the spend went through.
  bool spend(int amount) {
    if (amount <= 0 || _balance < amount) return false;
    _balance -= amount;
    notifyListeners();
    unawaited(_store.saveBalance(_balance));
    return true;
  }
}

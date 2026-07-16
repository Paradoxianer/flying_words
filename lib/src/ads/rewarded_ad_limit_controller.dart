// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'persistence/rewarded_ad_limit_persistence.dart';
import 'rewarded_ad_limit_data.dart';

/// How many rewarded ads a player may watch per category per day (#54
/// Phase D addendum) - a guardrail so the free path doesn't turn into
/// unlimited grinding.
const rewardedAdDailyLimit = 5;

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Tracks how many rewarded ads the player has watched today, for two
/// independent categories: watching to receive a Joker, and watching to
/// receive Goldtinte. Local-only, no backend needed - same shape as
/// [ChallengesController]'s daily rollover.
class RewardedAdLimitController extends ChangeNotifier {
  final RewardedAdLimitPersistence _store;

  RewardedAdLimitData _data = const RewardedAdLimitData();

  /// Memoizes the initial load, same reasoning as
  /// `ChallengesController._loadFuture`: without this, a load landing
  /// after a watched-ad write would clobber it with stale data.
  Future<void>? _loadFuture;

  RewardedAdLimitController(this._store);

  Future<void> _ensureLoaded() {
    return _loadFuture ??= _store.getData().then((loaded) {
      _data = loaded;
      notifyListeners();
    });
  }

  Future<void> getLatestFromStore() => _ensureLoaded();

  /// [_data] if it's still for today, otherwise a fresh zeroed-out record
  /// for today - without persisting the rollover until an ad is actually
  /// watched.
  RewardedAdLimitData _today([DateTime? now]) {
    final todayKey = _dateKey(now ?? DateTime.now());
    return _data.date == todayKey ? _data : RewardedAdLimitData(date: todayKey);
  }

  int jokerAdsWatchedToday({DateTime? now}) => _today(now).jokerAdsWatched;

  int goldInkAdsWatchedToday({DateTime? now}) => _today(now).goldInkAdsWatched;

  bool canWatchJokerAd({DateTime? now}) =>
      jokerAdsWatchedToday(now: now) < rewardedAdDailyLimit;

  bool canWatchGoldInkAd({DateTime? now}) =>
      goldInkAdsWatchedToday(now: now) < rewardedAdDailyLimit;

  Future<void> recordJokerAdWatched({DateTime? now}) async {
    await _ensureLoaded();
    final today = _today(now);
    _data = today.copyWith(jokerAdsWatched: today.jokerAdsWatched + 1);
    _save();
  }

  Future<void> recordGoldInkAdWatched({DateTime? now}) async {
    await _ensureLoaded();
    final today = _today(now);
    _data = today.copyWith(goldInkAdsWatched: today.goldInkAdsWatched + 1);
    _save();
  }

  void _save() {
    notifyListeners();
    unawaited(_store.saveData(_data));
  }
}

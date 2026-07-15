// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'joker_type.dart';
import 'persistence/joker_inventory_persistence.dart';

/// Tracks how many of each Joker (#53) the player owns. Jokers start at
/// zero - there is no free starter kit; earning them is a later step
/// (the Goldtinte shop, #54 Phase D).
class JokerInventoryController extends ChangeNotifier {
  final JokerInventoryPersistence _store;

  Map<JokerType, int> _counts = {for (final type in JokerType.values) type: 0};

  JokerInventoryController(JokerInventoryPersistence store) : _store = store;

  int countOf(JokerType type) => _counts[type] ?? 0;

  Future<void> getLatestFromStore() async {
    _counts = await _store.getCounts();
    notifyListeners();
  }

  /// Adds [amount] of [type] to the inventory (e.g. bought in the shop).
  void add(JokerType type, [int amount = 1]) {
    if (amount <= 0) return;
    _counts = Map.of(_counts)..[type] = countOf(type) + amount;
    notifyListeners();
    unawaited(_store.saveCounts(_counts));
  }

  /// Spends one [type] Joker, if any are owned. Returns whether one was
  /// actually spent - callers use this to decide whether to also trigger
  /// the Joker's gameplay effect on [LevelState].
  bool use(JokerType type) {
    final current = countOf(type);
    if (current <= 0) return false;
    _counts = Map.of(_counts)..[type] = current - 1;
    notifyListeners();
    unawaited(_store.saveCounts(_counts));
    return true;
  }
}

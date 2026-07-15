// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../joker_type.dart';
import 'joker_inventory_persistence.dart';

/// An in-memory implementation of [JokerInventoryPersistence]. Useful for
/// testing.
class MemoryOnlyJokerInventoryPersistence implements JokerInventoryPersistence {
  Map<JokerType, int> _counts = {for (final type in JokerType.values) type: 0};

  @override
  Future<Map<JokerType, int>> getCounts() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return Map.of(_counts);
  }

  @override
  Future<void> saveCounts(Map<JokerType, int> counts) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _counts = Map.of(counts);
  }
}

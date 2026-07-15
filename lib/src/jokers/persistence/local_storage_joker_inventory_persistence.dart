// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

import '../joker_type.dart';
import 'joker_inventory_persistence.dart';

/// An implementation of [JokerInventoryPersistence] that uses
/// `package:shared_preferences`, one int entry per [JokerType].
class LocalStorageJokerInventoryPersistence
    implements JokerInventoryPersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  String _keyFor(JokerType type) => 'jokerCount_${type.name}';

  @override
  Future<Map<JokerType, int>> getCounts() async {
    final prefs = await instanceFuture;
    return {
      for (final type in JokerType.values)
        type: prefs.getInt(_keyFor(type)) ?? 0,
    };
  }

  @override
  Future<void> saveCounts(Map<JokerType, int> counts) async {
    final prefs = await instanceFuture;
    for (final entry in counts.entries) {
      await prefs.setInt(_keyFor(entry.key), entry.value);
    }
  }
}

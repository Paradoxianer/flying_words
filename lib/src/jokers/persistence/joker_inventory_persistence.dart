// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../joker_type.dart';

/// An interface of persistence stores for the player's Joker inventory.
abstract class JokerInventoryPersistence {
  Future<Map<JokerType, int>> getCounts();

  Future<void> saveCounts(Map<JokerType, int> counts);
}

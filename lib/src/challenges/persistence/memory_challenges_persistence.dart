// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../challenges_data.dart';
import 'challenges_persistence.dart';

/// An in-memory implementation of [ChallengesPersistence]. Useful for
/// testing.
class MemoryOnlyChallengesPersistence implements ChallengesPersistence {
  ChallengesData _data = const ChallengesData();

  @override
  Future<ChallengesData> getData() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _data;
  }

  @override
  Future<void> saveData(ChallengesData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _data = data;
  }
}

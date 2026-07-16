// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../challenges_data.dart';

/// An interface of persistence stores for the daily/weekly challenges and
/// play streak (#53 Phase C).
abstract class ChallengesPersistence {
  Future<ChallengesData> getData();

  Future<void> saveData(ChallengesData data);
}

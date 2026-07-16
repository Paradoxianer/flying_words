// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../rewarded_ad_limit_data.dart';

/// An interface of persistence stores for the daily rewarded-ad watch
/// limits (#54 Phase D addendum).
abstract class RewardedAdLimitPersistence {
  Future<RewardedAdLimitData> getData();

  Future<void> saveData(RewardedAdLimitData data);
}

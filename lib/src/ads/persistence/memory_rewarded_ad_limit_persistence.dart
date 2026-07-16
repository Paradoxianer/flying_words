// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../rewarded_ad_limit_data.dart';
import 'rewarded_ad_limit_persistence.dart';

/// An in-memory implementation of [RewardedAdLimitPersistence]. Useful for
/// testing.
class MemoryOnlyRewardedAdLimitPersistence
    implements RewardedAdLimitPersistence {
  RewardedAdLimitData _data = const RewardedAdLimitData();

  @override
  Future<RewardedAdLimitData> getData() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _data;
  }

  @override
  Future<void> saveData(RewardedAdLimitData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _data = data;
  }
}

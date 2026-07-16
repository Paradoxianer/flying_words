// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../rewarded_ad_limit_data.dart';
import 'rewarded_ad_limit_persistence.dart';

/// An implementation of [RewardedAdLimitPersistence] that uses
/// `package:shared_preferences`.
class LocalStorageRewardedAdLimitPersistence
    implements RewardedAdLimitPersistence {
  static final _log = Logger('LocalStorageRewardedAdLimitPersistence');

  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<RewardedAdLimitData> getData() async {
    final prefs = await instanceFuture;
    final jsonString = prefs.getString('rewardedAdLimitData');
    if (jsonString == null) {
      return const RewardedAdLimitData();
    }
    try {
      return RewardedAdLimitData.fromJson(
          json.decode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      // Corrupt or incompatible data must not prevent the game from
      // starting - worst case, the player gets a fresh daily limit early.
      _log.severe(
          'Could not parse stored rewarded-ad limit data, starting fresh', e);
      return const RewardedAdLimitData();
    }
  }

  @override
  Future<void> saveData(RewardedAdLimitData data) async {
    final prefs = await instanceFuture;
    await prefs.setString('rewardedAdLimitData', json.encode(data.toJson()));
  }
}

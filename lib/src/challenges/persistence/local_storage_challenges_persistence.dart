// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../challenges_data.dart';
import 'challenges_persistence.dart';

/// An implementation of [ChallengesPersistence] that uses
/// `package:shared_preferences`.
class LocalStorageChallengesPersistence implements ChallengesPersistence {
  static final _log = Logger('LocalStorageChallengesPersistence');

  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<ChallengesData> getData() async {
    final prefs = await instanceFuture;
    final jsonString = prefs.getString('challengesData');
    if (jsonString == null) {
      return const ChallengesData();
    }
    try {
      return ChallengesData.fromJson(
          json.decode(jsonString) as Map<String, dynamic>);
    } catch (e) {
      // Corrupt or incompatible data must not prevent the game from starting.
      _log.severe('Could not parse stored challenges data, starting fresh', e);
      return const ChallengesData();
    }
  }

  @override
  Future<void> saveData(ChallengesData data) async {
    final prefs = await instanceFuture;
    await prefs.setString('challengesData', json.encode(data.toJson()));
  }
}

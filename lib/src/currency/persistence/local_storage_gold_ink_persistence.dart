// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

import 'gold_ink_persistence.dart';

/// An implementation of [GoldInkPersistence] that uses
/// `package:shared_preferences`.
class LocalStorageGoldInkPersistence implements GoldInkPersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<int> getBalance() async {
    final prefs = await instanceFuture;
    return prefs.getInt('goldInkBalance') ?? 0;
  }

  @override
  Future<void> saveBalance(int balance) async {
    final prefs = await instanceFuture;
    await prefs.setInt('goldInkBalance', balance);
  }
}

// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'gold_ink_persistence.dart';

/// An in-memory implementation of [GoldInkPersistence]. Useful for testing.
class MemoryOnlyGoldInkPersistence implements GoldInkPersistence {
  int _balance = 0;

  @override
  Future<int> getBalance() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _balance;
  }

  @override
  Future<void> saveBalance(int balance) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _balance = balance;
  }
}

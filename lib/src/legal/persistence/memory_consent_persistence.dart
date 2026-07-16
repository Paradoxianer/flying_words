// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'consent_persistence.dart';

/// An in-memory implementation of [ConsentPersistence]. Useful for testing.
class MemoryOnlyConsentPersistence implements ConsentPersistence {
  bool _seen = false;

  @override
  Future<bool> getPrivacyNoticeSeen() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _seen;
  }

  @override
  Future<void> savePrivacyNoticeSeen(bool seen) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _seen = seen;
  }
}

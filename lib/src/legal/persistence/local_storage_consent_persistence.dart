// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

import 'consent_persistence.dart';

/// An implementation of [ConsentPersistence] that uses
/// `package:shared_preferences`.
class LocalStorageConsentPersistence implements ConsentPersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<bool> getPrivacyNoticeSeen() async {
    final prefs = await instanceFuture;
    return prefs.getBool('privacyNoticeSeen') ?? false;
  }

  @override
  Future<void> savePrivacyNoticeSeen(bool seen) async {
    final prefs = await instanceFuture;
    await prefs.setBool('privacyNoticeSeen', seen);
  }
}

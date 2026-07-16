// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'persistence/consent_persistence.dart';

/// Tracks whether the player has already acknowledged the privacy notice
/// shown on first app start (#111).
class ConsentController extends ChangeNotifier {
  final ConsentPersistence _store;

  bool _privacyNoticeSeen = false;

  ConsentController(ConsentPersistence store) : _store = store;

  bool get privacyNoticeSeen => _privacyNoticeSeen;

  Future<void> getLatestFromStore() async {
    _privacyNoticeSeen = await _store.getPrivacyNoticeSeen();
    notifyListeners();
  }

  /// Records that the player has seen and acknowledged the privacy notice.
  void markPrivacyNoticeSeen() {
    if (_privacyNoticeSeen) return;
    _privacyNoticeSeen = true;
    notifyListeners();
    unawaited(_store.savePrivacyNoticeSeen(true));
  }
}

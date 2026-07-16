// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// An interface of persistence stores for whether the player has already
/// seen the privacy notice shown on first app start (#111).
abstract class ConsentPersistence {
  Future<bool> getPrivacyNoticeSeen();

  Future<void> savePrivacyNoticeSeen(bool seen);
}

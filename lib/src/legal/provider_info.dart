// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The legal provider identity shown on the Impressum and privacy policy
/// screens (#18).
///
/// Fill this in once here before release - it feeds every localized legal
/// text via ARB placeholders instead of being duplicated per screen and
/// language.
class ProviderInfo {
  static const name = 'Matthias Lindner';
  static const street = 'Horst-Menzel-Str. 5';
  static const zipCity = '09112 Chemnitz';
  static const country = 'Germany';
  static const email = 'two4god@gmail.com';
  static const phone = '+49 163 86 87 637';

  /// Street, ZIP/city and country joined for the privacy policy's shorter
  /// "controller" section, which doesn't split the address into lines.
  static const address = '$street\n$zipCity\n$country';

  /// Last time the privacy policy's substance changed. Update this whenever
  /// the "Datenschutzerklärung" section texts change materially.
  static const privacyPolicyLastUpdated = '2026-07-15';
}

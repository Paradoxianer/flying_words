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
  static const name = '[PLATZHALTER: Name/Organisation | PLACEHOLDER: name/organization]';
  static const street = '[PLATZHALTER: Straße und Hausnummer | PLACEHOLDER: street and house number]';
  static const zipCity = '[PLATZHALTER: PLZ und Ort | PLACEHOLDER: postal code and city]';
  static const country = '[PLATZHALTER: Land | PLACEHOLDER: country]';
  static const email = '[PLATZHALTER: E-Mail-Adresse | PLACEHOLDER: email address]';
  static const phone = '[PLATZHALTER: Telefonnummer, falls vorhanden | PLACEHOLDER: phone number, if any]';

  /// Street, ZIP/city and country joined for the privacy policy's shorter
  /// "controller" section, which doesn't split the address into lines.
  static const address = '$street\n$zipCity\n$country';

  /// Last time the privacy policy's substance changed. Update this whenever
  /// the "Datenschutzerklärung" section texts change materially.
  static const privacyPolicyLastUpdated = '[PLATZHALTER: Datum | PLACEHOLDER: date]';
}

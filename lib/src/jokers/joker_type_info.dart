// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';
import 'joker_type.dart';

/// What a Joker costs in Goldtinte in the shop (#54 Phase D) - the same
/// for all four, revised 16.07.2026 alongside the Goldtinte earning rate
/// so the two stay in balance with each other.
const jokerPriceInGoldInk = 12;

IconData jokerIcon(JokerType type) {
  switch (type) {
    case JokerType.sanduhr:
      return Icons.hourglass_bottom;
    case JokerType.vergebung:
      return Icons.favorite;
    case JokerType.klarheit:
      return Icons.cleaning_services;
    case JokerType.bonuszeit:
      return Icons.timer_outlined;
  }
}

String jokerName(AppLocalizations l10n, JokerType type) {
  switch (type) {
    case JokerType.sanduhr:
      return l10n.jokerSanduhrName;
    case JokerType.vergebung:
      return l10n.jokerVergebungName;
    case JokerType.klarheit:
      return l10n.jokerKlarheitName;
    case JokerType.bonuszeit:
      return l10n.jokerBonuszeitName;
  }
}

String jokerDescription(AppLocalizations l10n, JokerType type) {
  switch (type) {
    case JokerType.sanduhr:
      return l10n.jokerSanduhrDescription;
    case JokerType.vergebung:
      return l10n.jokerVergebungDescription;
    case JokerType.klarheit:
      return l10n.jokerKlarheitDescription;
    case JokerType.bonuszeit:
      return l10n.jokerBonuszeitDescription;
  }
}

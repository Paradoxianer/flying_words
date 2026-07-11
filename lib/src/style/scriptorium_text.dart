// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// Font families bundled in assets/fonts (see pubspec.yaml).
const displayFontFamily = 'Cormorant Garamond';
const bodyFontFamily = 'Source Serif 4';

/// Text roles of the "Scriptorium" design (#39). Colors are intentionally
/// not part of these tokens - they come from [Palette] at the call site.
abstract final class ScriptoriumText {
  /// Big calligraphic titles ("Flying Words", "Gewonnen!").
  static const display = TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 55,
    height: 1.05,
  );

  /// Screen headings and verse references.
  static const heading = TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 30,
  );

  /// Verse references on cards.
  static const verseRef = TextStyle(
    fontFamily: displayFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 24,
  );

  /// The verse text itself - must stay very readable.
  static const verse = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.45,
  );

  /// Regular UI copy.
  static const body = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 16,
  );

  /// Stats, scoreboard entries, emphasized labels.
  static const label = TextStyle(
    fontFamily: bodyFontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );
}

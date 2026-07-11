// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// The "Scriptorium" design palette (see issue #39): the world of old
/// manuscripts - parchment, ink, gold and wax seals - combined with
/// strong game feedback moments.
///
/// Colors here are implemented as getters so that hot reloading works.
class Palette {
  // ----- Core Scriptorium tokens -----

  /// Warm parchment - the main ground of the app.
  Color get parchment => const Color(0xfff2e7cf);

  /// Lighter parchment for the play area and reading surfaces.
  Color get parchmentLight => const Color(0xfff8f0dd);

  /// Darker, aged parchment for cards and panels.
  Color get parchmentDark => const Color(0xffe9dab8);

  /// Writing ink - primary text color.
  Color get inkFullOpacity => const Color(0xff2b2118);

  /// Ink with a touch of transparency for body text.
  Color get ink => const Color(0xee2b2118);

  /// Faded ink for secondary text.
  Color get inkFaded => const Color(0xff5c4a30);

  /// Gold leaf - accents, stars, highlights.
  Color get gold => const Color(0xffa9802a);

  /// Bright gold for shiny moments (earned stars, celebration).
  Color get goldBright => const Color(0xffecc95e);

  /// Sealing wax red - errors and warnings.
  Color get sealRed => const Color(0xff8c2f1b);

  /// Muted olive - success and calm secondary accents.
  Color get olive => const Color(0xff6b6b45);

  Color get trueWhite => const Color(0xffffffff);

  // ----- Wax seal colors (difficulty I/II/III) -----

  Color get sealBronze => const Color(0xff8c5a28);
  Color get sealSilver => const Color(0xff8d959c);
  Color get sealGold => const Color(0xffa9802a);

  // ----- Semantic slots used by the screens -----

  Color get pen => const Color(0xff4a3520);
  Color get darkPen => const Color(0xff2b2118);
  Color get redPen => const Color(0xff8c2f1b);
  Color get backgroundMain => parchment;
  Color get backgroundLevelSelection => parchmentDark;
  Color get backgroundPlaySession => parchmentLight;
  Color get background4 => parchment;
  Color get backgroundSettings => const Color(0xffe7e0c9);
}

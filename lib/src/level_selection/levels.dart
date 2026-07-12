// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flying_words/src/game_internals/lesson.dart';

/// The curated verses, loaded from `assets/verses/curated_<lang>.json` at
/// startup by [loadCuratedVerses]. Empty until the load has run.
List<Lesson> gameLevels = [];

/// Loads the curated verse list matching [locale]'s language from the
/// bundled JSON asset, falling back to German for any language that does
/// not (yet) have its own curated verse content (#2). Kept in a
/// module-level list so the (synchronous) router and screens can use it
/// once it is populated before `runApp`.
///
/// The verse content is loaded once at startup, not re-loaded when the UI
/// language changes afterwards - switching the in-game verse text to a
/// newly chosen language takes a restart, same as a page reload on the web.
Future<void> loadCuratedVerses({Locale locale = const Locale('de')}) async {
  final assetPath = locale.languageCode == 'en'
      ? 'assets/verses/curated_en.json'
      : 'assets/verses/curated_de.json';
  final jsonString = await rootBundle.loadString(assetPath);
  final data = json.decode(jsonString) as Map<String, dynamic>;
  final verses = (data['verses'] as List)
      .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
      .toList();
  gameLevels = verses;
}

// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flying_words/src/game_internals/lesson.dart';

/// The curated verses, loaded from `assets/verses/curated_de.json` at
/// startup by [loadCuratedVerses]. Empty until the load has run.
List<Lesson> gameLevels = [];

/// Loads the curated verse list from the bundled JSON asset. Kept in a
/// module-level list so the (synchronous) router and screens can use it
/// once it is populated before `runApp`.
Future<void> loadCuratedVerses() async {
  final jsonString =
      await rootBundle.loadString('assets/verses/curated_de.json');
  final data = json.decode(jsonString) as Map<String, dynamic>;
  final verses = (data['verses'] as List)
      .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
      .toList();
  gameLevels = verses;
}

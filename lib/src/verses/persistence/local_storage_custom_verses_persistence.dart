// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../game_internals/lesson.dart';
import 'custom_verses_persistence.dart';

/// Persists the player's custom verses with `package:shared_preferences`
/// (localStorage on the web, so it works in the PWA too).
class LocalStorageCustomVersesPersistence implements CustomVersesPersistence {
  static final _log = Logger('LocalStorageCustomVersesPersistence');
  static const _key = 'customVerses';

  @override
  Future<List<Lesson>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    try {
      final list = json.decode(jsonString) as List;
      return list
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.severe('Could not parse custom verses, starting empty', e);
      return [];
    }
  }

  @override
  Future<void> save(List<Lesson> verses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, json.encode([for (final v in verses) v.toJson()]));
  }
}

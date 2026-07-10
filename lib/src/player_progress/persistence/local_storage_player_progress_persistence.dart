// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flying_words/src/player_progress/player_progress.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'player_progress_persistence.dart';

/// An implementation of [PlayerProgressPersistence] that uses
/// `package:shared_preferences`.
class LocalStoragePlayerProgressPersistence extends PlayerProgressPersistence {
  static final _log = Logger('LocalStoragePlayerProgressPersistence');

  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<int> getPlayerHighscore() async {
    final prefs = await instanceFuture;
    return prefs.getInt('playerHighscore') ?? 0;
  }

  @override
  Future<Map<String, VerseProgress>> getPlayerProgress() async {
    final prefs = await instanceFuture;
    final jsonString = prefs.getString('playerProgress');
    if (jsonString == null) {
      return <String, VerseProgress>{};
    }
    try {
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      return decoded.map((verse, verseProgress) => MapEntry(
          verse, VerseProgress.fromJson(verseProgress as Map<String, dynamic>)));
    } catch (e) {
      // Corrupt or incompatible data must not prevent the game from starting.
      _log.severe('Could not parse stored player progress, starting fresh', e);
      return <String, VerseProgress>{};
    }
  }

  @override
  Future<void> savePlayerHighscore(int highScore) async {
    final prefs = await instanceFuture;
    await prefs.setInt('playerHighscore', highScore);
  }

  @override
  Future<void> savePlayerProgress(
      Map<String, VerseProgress> playerProgress) async {
    final prefs = await instanceFuture;
    final encodable = playerProgress
        .map((verse, verseProgress) => MapEntry(verse, verseProgress.toJson()));
    await prefs.setString('playerProgress', json.encode(encodable));
  }
}

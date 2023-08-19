// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';
import 'package:games_services/games_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'player_progress_persistence.dart';

/// An implementation of [PlayerProgressPersistence] that uses
/// `package:shared_preferences`.
class LocalStoragePlayerProgressPersistence extends PlayerProgressPersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<int> getPlayerHighscore() async {
    final prefs = await instanceFuture;
    return prefs.getInt('playerHighscore') ?? 0;
  }

  @override
  Future<Score?> getPlayerScore(String verse, Difficulty forDifficulty) async {
    Score? scr=null;
    final playerProgress = await getPlayerProgress();
    if (playerProgress != null && playerProgress.containsKey(verse)) {
      final verseProgress = playerProgress[verse]!;
      if (verseProgress.containsKey(forDifficulty)) {
        scr =verseProgress[forDifficulty];
      }
    }
    return scr; // Wenn keine passende Wertung gefunden wird
  }


  @override
  Future<Map<String,VerseProgress>> getPlayerProgress() async {
    final prefs = await instanceFuture;
    //TODO implement better way to store every VerseProgress seperatly???
    String? jsonString = prefs.getString("playerProgress");
    if (jsonString ==null)
      return new Map<String,VerseProgress>();
    else {
      Map<String, VerseProgress> data = json.decode(jsonString);
      return data;
    }

  }

  Future<void> savePlayerHighscore(int highScore) async {
    final prefs = await instanceFuture;
    await prefs.setInt('playerHighscore', highScore);
  }

  Future<void> savePlayerProgress(Map<String,VerseProgress> playerProgress) async {
    final prefs = await instanceFuture;
    await prefs.setString('playerProgress', json.encode(playerProgress));
  }

  Future<void> savePlayerScore(String verse, Difficulty forDifficulty, Score score) async{
    //TODO implement or not use??
    /*final prefs = await instanceFuture;
    await prefs.setString('playerProgress', json.encode(playerProgress));*/
  }

}

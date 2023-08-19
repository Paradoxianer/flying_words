// Copyright 2023, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:quiver/collection.dart';

import 'package:flying_words/src/persistence/player_progress_persistence.dart';


//a Wrapper around a Map<Difficulty, Score> to make the Code more readable and
// and  implement some more Features
class VerseProgress extends DelegatingMap<Difficulty,Score>{
  final Map<Difficulty, Score> _progress ={};

  Map<Difficulty,Score> get delegate => _progress;

  bool finished(Difficulty difficulty){
    Score? _tmpScore = this[difficulty];
    if (_tmpScore == null)
      return false;
    else
      return _tmpScore.score > 0;
  }
  
  int fullScore(){
    int _fullScore=0;
    forEach((key, value) {_fullScore+=value.score;});
    return _fullScore;
  } 


}


/// Encapsulates the player's progress.
class PlayerProgress extends ChangeNotifier {
  int _playerScore = 0;

  //String defines a verse the other map is a Map where the Score corresponding to the given difficulty is stored
  Map<String,VerseProgress> _progress = new Map<String,VerseProgress>();
  final PlayerProgressPersistence _store;



  /// Creates an instance of [PlayerProgress] backed by an injected
  /// persistence [store].
  PlayerProgress(PlayerProgressPersistence store) : _store = store;

  /// The highest level that the player has reached so far.
  int get playerScore => _playerScore;

  /// Fetches the latest data from the backing persistence store.
  Future<void> getLatestFromStore() async {
    final score = await _store.getPlayerHighscore();
    if (score > _playerScore) {
      _playerScore = score;
      notifyListeners();
    } else if (score < _playerScore) {
      await _store.savePlayerHighscore(_playerScore);
      await _store.savePlayerProgress(_progress);
    }
  }

  /// Resets the player's progress so it's like if they just started
  /// playing the game for the first time.
  void reset() {
    _playerScore = 0;
    _progress.clear();
    notifyListeners();
    _store.savePlayerHighscore(_playerScore);
    _store.savePlayerProgress(_progress);
  }

  /// only called if you sucessfull finished a Difficutly on a Lesson
  void setScoreforVerse(String verse, Difficulty difficulty, Score score) {
    VerseProgress? verseProgress =_progress[verse];
    if (verseProgress!=null) {
      if (verseProgress[difficulty]!.score > score.score)
        return;
    }
    else{
      
      notifyListeners();
      unawaited(_store.savePlayerHighscore(_playerScore));
      unawaited(_store.savePlayerProgress(_progress));
    }
  }

  Score? getScoreforVerse(String verse, Difficulty difficulty){
    VerseProgress? verseProgress =_progress[verse];
    if (verseProgress!=null)
      return verseProgress[difficulty];
    else
      return null;
  }

  int calculateNewHighScore(String verse, Difficulty difficulty, Score score){
    int _newHighScore = 0;
    _progress.forEach((key, value) {
      if (key.compareTo(verse)){
        //ToDo make a copy of the VerseProgress change the given difficulty and calculate the new fullScore()
      }
      else
        _newHighScore += value.fullScore();
    });
    return _newHighScore;
  }
  
  void checkAchievment(){
    String _achievementID ="";

    if (_progress.isNotEmpty){
      _progress.forEach((key, value) {
          value.forEach((difficulty, score) {
          });
      });
    }
  }

  // TODO: When ready, change these achievement IDs.
  // You configure this in App Store Connect.
  //achievementIdIOS: 'first_win',
  // You get this string when you configure an achievement in Play Console.
  //achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',


}

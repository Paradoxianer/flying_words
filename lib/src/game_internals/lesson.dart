import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flying_words/src/game_internals/level_state.dart';

enum Difficulty{
  slow,
  normal,
  insane,
}

//tells how much time the user have to klick on the word.. until every word disapared
Map<Difficulty, Duration> difficultySpeed = {
  Difficulty.slow: Duration(seconds:3 ),
  Difficulty.normal: Duration(seconds:2 ),
  Difficulty.insane: Duration(seconds: 1,milliseconds: 750 ),
};

Map<Difficulty, int> difficultyWordcount = {
  Difficulty.slow: 3,
  Difficulty.normal: 6,
  Difficulty.insane: 11,
};

Map<Difficulty, Image> difficultyImagePath = {
  Difficulty.slow: Image.asset('assets/images/marker/marker_green.png',repeat: ImageRepeat.repeat,fit: BoxFit.fitHeight),
  Difficulty.normal: Image.asset('assets/images/marker/marker_yellow.png'),
  Difficulty.insane: Image.asset('assets/images/marker/marker_red.png'),
};


class Lesson{
  final int number;
  final String verse;
  List<String> _words =[];
  final String text;
  List<LevelState> levels = [];


  /// The achievement to unlock when the level is finished, if any.
  //TODO move achievment to a sperate class
  final String? achievementIdIOS;

  final String? achievementIdAndroid;

  bool get awardsAchievement => achievementIdAndroid != null;

  Lesson({
    required this.number,
    required this.verse,
    required this.text,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : this._words=text.split(' '), assert(
  (achievementIdAndroid != null && achievementIdIOS != null) ||
      (achievementIdAndroid == null && achievementIdIOS == null),
  'Either both iOS and Android achievement ID must be provided, '
      'or none');

  List<String> get words => _words;

}

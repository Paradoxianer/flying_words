import 'dart:core';
import 'package:flying_words/src/game_internals/level_state.dart';

enum Difficulty{
  slow,
  normal,
  insane,
}

Map<Difficulty, double> difficultySpeed = {
  Difficulty.slow: 0.25,
  Difficulty.normal: 1.0,
  Difficulty.insane: 2.0,
};

Map<Difficulty, int> difficultyWordcount = {
  Difficulty.slow: 3,
  Difficulty.normal: 7,
  Difficulty.insane: 12,
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

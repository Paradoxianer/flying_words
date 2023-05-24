import 'dart:core';
import 'package:flying_words/src/game_internals/level_state.dart';

enum Difficulty{
  slow,
  normal,
  insane,
}
Map<Difficulty, String> difficultyIcons = {
  Difficulty.slow: "assets/images/speedometer/speedometer-slow_gray.png",
  Difficulty.normal: "assets/images/speedometer/speedometer-normal_gray.png",
  Difficulty.insane: "assets/images/speedometer/speedometer-fast_gray.png",
};

Map<Difficulty, double> difficultySpeed = {
  Difficulty.slow: 0.25,
  Difficulty.normal: 1.0,
  Difficulty.insane: 2.0,
};

class Lesson{
  final int number;
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

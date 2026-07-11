import 'dart:core';

import 'bible_reference.dart';

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

class Lesson{
  final int number;

  /// Human-readable reference shown in the UI, e.g. "Johannes 3, 16".
  final String verse;
  final List<String> _words;
  final String text;

  /// Translation-independent reference (book/chapter/verse), or null for
  /// legacy verses that only have a display string and text.
  final BibleReference? reference;

  /// The translation the [text] comes from, e.g. "Menge". "unbestimmt" for
  /// the pre-existing curated verses whose exact translation is unconfirmed.
  final String translation;

  /// True for verses the player added themselves (via the Bible API, #15).
  final bool custom;

  /// The achievement to unlock when the level is finished, if any.
  //TODO move achievment to a sperate class
  final String? achievementIdIOS;

  final String? achievementIdAndroid;

  bool get awardsAchievement => achievementIdAndroid != null;

  Lesson({
    required this.number,
    required this.verse,
    required this.text,
    this.reference,
    this.translation = 'unbestimmt',
    this.custom = false,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : _words=text.split(' '), assert(
  (achievementIdAndroid != null && achievementIdIOS != null) ||
      (achievementIdAndroid == null && achievementIdIOS == null),
  'Either both iOS and Android achievement ID must be provided, '
      'or none');

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        number: json['number'] as int,
        verse: json['display'] as String,
        text: json['text'] as String,
        reference: json['reference'] == null
            ? null
            : BibleReference.fromJson(
                json['reference'] as Map<String, dynamic>),
        translation: json['translation'] as String? ?? 'unbestimmt',
        custom: json['custom'] as bool? ?? false,
      );

  List<String> get words => _words;

}

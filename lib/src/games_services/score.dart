// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:flying_words/src/game_internals/lesson.dart';

import '../level_selection/levels.dart';

Map<Difficulty, int> difficultyScoreFactor = {
  Difficulty.slow: 1,
  Difficulty.normal: 5,
  Difficulty.insane: 20
};

/// Encapsulates a score and the arithmetic to compute it.
class Score {
  final int score;
  final Duration duration;

  /// Number of errors in the run this score came from, or null for
  /// legacy data saved before errors were recorded.
  final int? errors;

  Score({this.score = 0, this.duration = Duration.zero, this.errors});

  factory Score.fromResult(int level, Difficulty difficulty, Duration duration, int errors,
      {bool blindBonus = false}) {
    // The higher the difficulty, the higher the score.
    // The lower the time to beat the level, the higher the score.
    var maxScore = gameLevels[level-1].words.length*difficultySpeed[difficulty]!.inMilliseconds;
    // Same scale as duration.inSeconds*10, but a run under a second must not
    // divide by zero.
    var elapsedTenthsOfSeconds = max(duration.inMilliseconds ~/ 100, 1);
    var score = (difficultyScoreFactor[difficulty]??1)*(maxScore ~/ elapsedTenthsOfSeconds) - (errors*difficultySpeed[difficulty]!.inSeconds*10);
    // Playing with the verse text hidden the whole run pays off (#27).
    if (blindBonus) {
      score = (score * 1.5).round();
    }
    // A won level is always worth at least one point - otherwise it would not
    // count as finished (see VerseProgress.finished).
    if (score < 1) score = 1;
    return Score(score: score, duration: duration, errors: errors);
  }

  factory Score.fromJson(Map<String, dynamic> json) => Score(
        score: json['score'] as int? ?? 0,
        duration: Duration(milliseconds: json['duration'] as int? ?? 0),
        // Older saves don't carry the error count; keep it null then.
        errors: json['errors'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'score': score,
        'duration': duration.inMilliseconds,
        if (errors != null) 'errors': errors,
      };


  String get formattedTime {
    final buf = StringBuffer();
    if (duration.inHours > 0) {
      buf.write('${duration.inHours}');
      buf.write(':');
    }
    final minutes = duration.inMinutes % Duration.minutesPerHour;
    if (minutes > 9) {
      buf.write('$minutes');
    } else {
      buf.write('0');
      buf.write('$minutes');
    }
    buf.write(':');
    buf.write((duration.inSeconds % Duration.secondsPerMinute)
        .toString()
        .padLeft(2, '0'));
    return buf.toString();
  }

  @override
  String toString() => 'Score<$score,$formattedTime>';
}

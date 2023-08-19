// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/game_internals/level_state.dart';

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
  Score({this.score=0,this.duration=Duration.zero});

  factory Score.fromResult(int level, Difficulty difficulty, Duration duration, int errors) {
    // The higher the difficulty, the higher the score.
    // The lower the time to beat the level, the higher the score.
    var maxScore = gameLevels[level-1].words.length*difficultySpeed[difficulty]!.inMilliseconds;
    var score = (difficultyScoreFactor[difficulty]??1)*(maxScore ~/ (duration.inSeconds*10)) - (errors*difficultySpeed[difficulty]!.inSeconds*10);
    return Score(score:score, duration:duration);
  }


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

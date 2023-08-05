// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


import 'package:flying_words/src/game_internals/lesson.dart';

final gameLevels = [
  Lesson(
    number: 1,
    verse: "1. Korinther 12, 6",
    text:   "Alles ist mir erlaubt, aber nicht alles ist nützlich. Alles ist mir erlaubt, aber ich will mich von keinem überwältigen lassen.",
    // TODO: When ready, change these achievement IDs.
    // You configure this in App Store Connect.
    achievementIdIOS: 'first_win',
    // You get this string when you configure an achievement in Play Console.
    achievementIdAndroid: 'NhkIwB69ejkMAOOLDb',
  ),
  Lesson(
    number: 2,
    verse: "Johannes 3, 16",
    text:  "Denn also hat Gott die Welt geliebt, daß er seinen eingeborenen Sohn gab, auf daß jeder, der an ihn glaubt, nicht verloren gehe, sondern ewiges Leben habe."
  ),
 /* Lesson(
    number: 3,
    difficulty: 100,
    achievementIdIOS: 'finished',
    achievementIdAndroid: 'CdfIhE96aspNWLGSQg',
  ),*/
];


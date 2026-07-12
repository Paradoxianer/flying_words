// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Where the game can be played; shared along with a win (#6, #30).
const flyingWordsUrl = 'https://paradoxianer.github.io/flying_words/';

/// Builds the text shared when the player wins (#6). Pure so it can be
/// tested; the actual share sheet is triggered separately.
String winShareText({
  required String verse,
  required int stars,
  required int maxStars,
  required int score,
  bool blindRun = false,
}) {
  final earned = '★' * stars + '☆' * (maxStars - stars);
  final blind = blindRun ? ' 🙈 blind!' : '';
  return 'Ich habe „$verse" bei Flying Words auswendig gelernt! '
      '$earned · $score Punkte$blind\n'
      'Spiel mit: $flyingWordsUrl';
}

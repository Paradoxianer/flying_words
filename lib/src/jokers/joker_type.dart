// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The four Jokers a player can bring into a run (#53). Chosen from the
/// inventory before the round starts (in the level selection) - there is
/// no in-play activation, since there is no time to spare while catching
/// words.
enum JokerType {
  /// "Sanduhr": the words fly noticeably slower for the whole round.
  sanduhr,

  /// "Vergebung": one wrong word in the round doesn't count as an error.
  vergebung,

  /// "Klarheit": about a third of the wrong word options are removed for
  /// the whole round.
  klarheit,

  /// "Bonuszeit": every word stays visible a few seconds longer.
  bonuszeit,
}

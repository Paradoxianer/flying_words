// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The four Jokers a player can use during a run (#53). Each one calls a
/// matching `LevelState.useX()` method that carries out its effect.
enum JokerType {
  /// "Gnade": forgives the next mistake instead of counting it as an error.
  grace,

  /// "Sanduhr": stretches the flight time of the words that follow by 50%.
  sanduhr,

  /// "Tintenlöscher": clears a few wrong words off the screen.
  tintenloescher,

  /// "Federkiel": auto-writes the current word.
  federkiel,
}

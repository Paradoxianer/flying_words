// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../jokers/joker_type.dart';

class LevelState extends ChangeNotifier {
  final Function(LevelState) onWin;
  final length;
  int _wordIndex = 0;
  final Set<int> _errors = <int>{};
  int _streak = 0;

  LevelState({required this.onWin, required this.length});
  //returns the wortindex at wich we are in the game
  int get wordIndex => _wordIndex;
  int get numErrors => _errors.length;
  Set<int> get Errors => _errors;

  /// Consecutive correctly caught words; any error resets it.
  int get streak => _streak;

  bool _paused = false;

  /// While paused the words stop flying, the clock stops and the play
  /// area hides the words (so pausing cannot be used as a free look).
  bool get paused => _paused;

  void setPaused(bool value) {
    if (_paused == value) return;
    _paused = value;
    notifyListeners();
  }

  bool _textHidden = false;
  bool _blindRun = false;

  /// Whether the verse text panel is hidden ("no cheat sheet" training, #27).
  bool get textHidden => _textHidden;

  /// True while the text has been hidden since before the first word was
  /// solved and never shown again - such a run earns the blind bonus.
  bool get blindRun => _blindRun && _textHidden;

  void setTextHidden(bool hidden) {
    if (_textHidden == hidden) return;
    _textHidden = hidden;
    if (hidden) {
      if (_wordIndex == 0) {
        _blindRun = true;
      }
    } else {
      _blindRun = false;
    }
    notifyListeners();
  }

  /// Called when the player catches the right word.
  void registerCatch() {
    _streak++;
    notifyListeners();
  }

  void setWordIndex(int index) {
    _wordIndex = index;
    notifyListeners();
  }

  void nextWordIndex() {
    _wordIndex++;
    notifyListeners();
  }

  // --- Joker effects (#53) --------------------------------------------
  //
  // Jokers are chosen from the inventory before the round starts (level
  // selection, see JokerPicker) and applied once via [applyJokers] - there
  // is no in-play activation, since catching words leaves no time to
  // spare for that. [jokerUsed] feeds the -50% Goldtinte penalty decided
  // in #53/#54 (stars are left untouched).

  bool _jokerUsed = false;

  /// Whether any joker was used this run - halves the Goldtinte earned
  /// (#53/#54), but never affects stars, score or leaderboards.
  bool get jokerUsed => _jokerUsed;

  int _pendingGraceCount = 0;

  double _speedMultiplier = 1.0;

  /// Multiplies the flying words' flight time; "Sanduhr" stretches it by
  /// 50% for the whole round.
  double get speedMultiplier => _speedMultiplier;

  Duration _bonusTimePerWord = Duration.zero;

  /// Extra flight time added to every word; "Bonuszeit" grants a few
  /// seconds of breathing room for the whole round.
  Duration get bonusTimePerWord => _bonusTimePerWord;

  bool _distractionsReduced = false;

  /// "Klarheit": about a third of the wrong word options are left out of
  /// every word draw for the whole round.
  bool get distractionsReduced => _distractionsReduced;

  /// Applies the [jokers] chosen before the round started. Called once,
  /// right after construction.
  void applyJokers(Set<JokerType> jokers) {
    if (jokers.isEmpty) return;
    _jokerUsed = true;
    if (jokers.contains(JokerType.vergebung)) _pendingGraceCount = 1;
    if (jokers.contains(JokerType.sanduhr)) _speedMultiplier = 1.5;
    if (jokers.contains(JokerType.bonuszeit)) {
      _bonusTimePerWord = const Duration(seconds: 3);
    }
    _distractionsReduced = jokers.contains(JokerType.klarheit);
    notifyListeners();
  }

  void addErrorIndex(int index) {
    if (_pendingGraceCount > 0) {
      // Forgiven by "Vergebung": as if the mistake never happened.
      _pendingGraceCount--;
      notifyListeners();
      return;
    }
    _streak = 0;
    //only register first mistake on the word... maybe later find a more fancy way to count multiple erros
    _errors.add(index);
    notifyListeners();
  }

  void evaluate() {
    if (_wordIndex >= length) {
      onWin(this);
    }
  }
}

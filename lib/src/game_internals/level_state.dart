// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [progress], and calls [onWin] when
/// the value of [progress] reaches [goal].
class LevelState extends ChangeNotifier {
  final VoidCallback onWin;
  final length;
  int _wordIndex = 0;
  List<int> _errors = List<int>.empty(growable: true);

  LevelState({required this.onWin, required this.length});

  int get wordIndex => _wordIndex;
  int get numErrors => _errors.length;

  void setWordIndex(int index) {
    _wordIndex = index;
    notifyListeners();
  }

  void nextWordIndex() {
    _wordIndex++;
    notifyListeners();
  }

  void addErrorIndex(int index) {
    //only register first mistake on the word... maybe later find a more fance way to count multiple erros on
    if (!_errors.contains(index)) {
      _errors.add(index);
      notifyListeners();
    }
  }

  void evaluate() {
    if (_wordIndex >= length) {
      onWin();
    }
  }
}

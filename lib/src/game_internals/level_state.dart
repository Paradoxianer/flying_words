// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [progress], and calls [onWin] when
/// the value of [progress] reaches [goal].
class LevelState extends ChangeNotifier {
  final VoidCallback onWin;

  final String text;
  int _wordIndex = 0;
  List<String> _words =[];
  List<int> _errors = List<int>.empty(growable: true);

  LevelState({required this.onWin, required this.text})
  {
    _words = text.split(' ');
  }



  int get wordIndex => _wordIndex;
  List<String> get words => _words;

  void setWordIndex(int index) {
    _wordIndex = index;
    notifyListeners();
  }

  void nextWordIndex() {
    _wordIndex++;
    notifyListeners();
  }

  void addErrorIndex(int index) {
    _errors.add(index);
    notifyListeners();
  }

  void evaluate() {
    if (_wordIndex >= _words.length) {
      _wordIndex=0;
      onWin();
    }
  }
}

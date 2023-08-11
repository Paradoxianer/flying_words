// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';


class LevelState extends ChangeNotifier {
  final VoidCallback onWin;
  final length;
  int _wordIndex = 0;
  Set<int> _errors = Set<int>();

  LevelState({required this.onWin, required this.length});
  //returns the wortindex at wich we are in the game
  int get wordIndex => _wordIndex;
  int get numErrors => _errors.length;
  Set<int> get Errors => _errors;

  void setWordIndex(int index) {
    _wordIndex = index;
    notifyListeners();
  }

  void nextWordIndex() {
    _wordIndex++;
    notifyListeners();
  }

  void addErrorIndex(int index) {
    //only register first mistake on the word... maybe later find a more fancy way to count multiple erros
    if (_errors.add(index)) {
      notifyListeners();
    }
    print(_errors.toString());
  }

  void evaluate() {
    if (_wordIndex >= length) {
      onWin();
    }
  }
}

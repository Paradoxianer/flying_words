// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../game_internals/lesson.dart';
import 'custom_verses_persistence.dart';

/// An in-memory implementation for tests.
class MemoryCustomVersesPersistence implements CustomVersesPersistence {
  List<Lesson> _verses = [];

  @override
  Future<List<Lesson>> load() async => List.of(_verses);

  @override
  Future<void> save(List<Lesson> verses) async => _verses = List.of(verses);
}

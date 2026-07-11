// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../game_internals/lesson.dart';

/// Stores the verses the player added themselves (via the Bible API, #15).
abstract class CustomVersesPersistence {
  Future<List<Lesson>> load();
  Future<void> save(List<Lesson> verses);
}

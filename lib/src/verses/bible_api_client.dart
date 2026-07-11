// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../game_internals/bible_reference.dart';

/// The text of a passage as returned by a Bible source, together with the
/// translation it came from.
class FetchedVerse {
  final String text;
  final String translation;

  const FetchedVerse({required this.text, required this.translation});
}

/// Thrown when a passage could not be fetched (network error, unknown book,
/// empty result). The UI turns this into a readable message.
class VerseFetchException implements Exception {
  final String message;
  const VerseFetchException(this.message);
  @override
  String toString() => 'VerseFetchException: $message';
}

/// Fetches the text of a passage for a given translation. The concrete
/// HTTP implementation against bolls.life lands in the next PR; the data
/// layer depends only on this interface so it can be tested with a fake.
abstract class BibleApiClient {
  /// The default translation code this client uses when none is given
  /// (e.g. "MB" for the Menge Bible on bolls.life).
  String get defaultTranslation;

  Future<FetchedVerse> fetchPassage(BibleReference reference,
      {String? translation});
}

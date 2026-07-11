// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A translation-independent pointer to a passage: book, chapter and a verse
/// range. Storing the reference instead of only the text lets the same
/// "curriculum" work across translations and languages (#2) and lets a Bible
/// API (#15) fetch the matching text later.
///
/// [book] is an OSIS-style code (e.g. "JHN", "1CO", "NUM") so it does not
/// depend on any language.
class BibleReference {
  final String book;
  final int chapter;
  final int verseStart;
  final int verseEnd;

  const BibleReference({
    required this.book,
    required this.chapter,
    required this.verseStart,
    int? verseEnd,
  }) : verseEnd = verseEnd ?? verseStart;

  bool get isRange => verseEnd > verseStart;

  factory BibleReference.fromJson(Map<String, dynamic> json) => BibleReference(
        book: json['book'] as String,
        chapter: json['chapter'] as int,
        verseStart: json['verseStart'] as int,
        verseEnd: json['verseEnd'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'book': book,
        'chapter': chapter,
        'verseStart': verseStart,
        if (isRange) 'verseEnd': verseEnd,
      };

  @override
  String toString() =>
      '$book $chapter:$verseStart${isRange ? '-$verseEnd' : ''}';
}

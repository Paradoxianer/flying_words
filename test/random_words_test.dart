import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/games_services/random_words.dart';

void main() {
  test('bibleWordsForLocale picks the English list for an English locale '
      '(#124: the flying distraction words used to always be German, even '
      'with an English UI/verse)', () {
    expect(bibleWordsForLocale(const Locale('en')), same(bibleWordsEn));
    expect(bibleWordsForLocale(const Locale('en', 'US')), same(bibleWordsEn));
  });

  test('bibleWordsForLocale falls back to German for any other language '
      '(same fallback rule as loadCuratedVerses, #2)', () {
    expect(bibleWordsForLocale(const Locale('de')), same(bibleWords));
    expect(bibleWordsForLocale(const Locale('fr')), same(bibleWords));
  });

  test('the English list is a real, non-empty word bank distinct from the '
      'German one', () {
    expect(bibleWordsEn, isNotEmpty);
    expect(bibleWordsEn, isNot(equals(bibleWords)));
    expect(bibleWordsEn, contains('God'));
    expect(bibleWordsEn, contains('grace'));
  });
}

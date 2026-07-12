import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/bible_reference.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/level_selection/levels.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BibleReference', () {
    test('json round trip, single verse and range', () {
      const single =
          BibleReference(book: 'JHN', chapter: 3, verseStart: 16);
      expect(single.isRange, isFalse);
      expect(single.toString(), 'JHN 3:16');
      final singleBack = BibleReference.fromJson(single.toJson());
      expect(singleBack.verseEnd, 16);

      const range = BibleReference(
          book: 'NUM', chapter: 6, verseStart: 24, verseEnd: 26);
      expect(range.isRange, isTrue);
      expect(range.toString(), 'NUM 6:24-26');
      expect(BibleReference.fromJson(range.toJson()).verseEnd, 26);
    });
  });

  group('Lesson.fromJson', () {
    test('parses reference, translation and text', () {
      final lesson = Lesson.fromJson({
        'number': 2,
        'display': 'Johannes 3, 16',
        'text': 'Denn also hat Gott die Welt geliebt',
        'reference': {'book': 'JHN', 'chapter': 3, 'verseStart': 16},
        'translation': 'Menge',
      });
      expect(lesson.number, 2);
      expect(lesson.verse, 'Johannes 3, 16');
      expect(lesson.reference!.book, 'JHN');
      expect(lesson.translation, 'Menge');
      expect(lesson.words.length, 7);
    });

    test('translation defaults to "unbestimmt"', () {
      final lesson = Lesson.fromJson({
        'number': 1,
        'display': 'x',
        'text': 'a b',
      });
      expect(lesson.translation, 'unbestimmt');
      expect(lesson.reference, isNull);
      expect(lesson.custom, isFalse);
    });
  });

  group('loadCuratedVerses', () {
    test('loads the bundled curated verses with references', () async {
      await loadCuratedVerses();
      expect(gameLevels, isNotEmpty);
      expect(gameLevels.length, greaterThanOrEqualTo(6));
      // Numbers are unique and every verse carries a reference.
      final numbers = gameLevels.map((l) => l.number).toSet();
      expect(numbers.length, gameLevels.length);
      for (final lesson in gameLevels) {
        expect(lesson.reference, isNotNull,
            reason: '${lesson.verse} should have a reference');
        expect(lesson.text.trim(), isNotEmpty);
      }
      // The swapped reference of verse 1 was corrected to 1 Cor 6:12.
      final first = gameLevels.singleWhere((l) => l.number == 1);
      expect(first.reference!.chapter, 6);
      expect(first.reference!.verseStart, 12);
    });

    test('the English curated verses load too, with the WEB translation',
        () async {
      await loadCuratedVerses(locale: const Locale('en'));
      expect(gameLevels, isNotEmpty);
      for (final lesson in gameLevels) {
        expect(lesson.translation, 'WEB');
        expect(lesson.text.trim(), isNotEmpty);
      }
      final john = gameLevels.singleWhere((l) => l.number == 2);
      expect(john.verse, 'John 3:16');
      expect(john.text, contains('eternal life'));
    });

    test('curated verse numbers and references match across languages (#2)',
        () async {
      await loadCuratedVerses();
      final german = {for (final l in gameLevels) l.number: l.reference};

      await loadCuratedVerses(locale: const Locale('en'));
      final english = {for (final l in gameLevels) l.number: l.reference};

      expect(english.keys.toSet(), german.keys.toSet(),
          reason: 'progress must key by number across languages (#2)');
      for (final number in german.keys) {
        expect(english[number].toString(), german[number].toString(),
            reason: 'verse $number should point at the same passage in '
                'both languages');
      }

      // Leave gameLevels in the default language for any test that runs
      // after this one in the same process.
      await loadCuratedVerses();
    });
  });
}

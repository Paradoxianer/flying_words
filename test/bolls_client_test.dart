import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/bible_reference.dart';
import 'package:flying_words/src/verses/bible_api_client.dart';
import 'package:flying_words/src/verses/bolls_bible_api_client.dart';
import 'package:flying_words/src/verses/bolls_books.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// The real bolls.life response for John 3:16 in the Menge Bible (MB),
/// provided from a live call. Note the `<i>(=einzigen)</i>` gloss and the
/// resulting double space.
const _realJohn316 =
    'Denn so sehr hat Gott die Welt geliebt, daß er seinen eingeborenen '
    '<i>(=einzigen)</i>  Sohn hingegeben hat, damit alle, die an ihn '
    'glauben, nicht verloren gehen, sondern ewiges Leben haben.';

void main() {
  group('cleanVerseText (against the real Menge sample)', () {
    test('drops the italic gloss and the double space it leaves', () {
      final cleaned = cleanVerseText(_realJohn316);
      expect(cleaned.contains('<'), isFalse);
      expect(cleaned.contains('(=einzigen)'), isFalse);
      // No empty "words" from collapsed whitespace.
      expect(cleaned.split(' ').where((w) => w.isEmpty), isEmpty);
      expect(cleaned.contains('eingeborenen Sohn'), isTrue);
      expect(cleaned.startsWith('Denn so sehr hat Gott'), isTrue);
      expect(cleaned.endsWith('ewiges Leben haben.'), isTrue);
    });

    test('strips other tags and decodes entities', () {
      expect(cleanVerseText('a <br/> b'), 'a b');
      expect(cleanVerseText('Recht &amp; Gnade'), 'Recht & Gnade');
    });
  });

  group('bollsBookNumbers', () {
    test('John is book 43 (confirmed against the live API)', () {
      expect(bollsBookNumbers['JHN'], 43);
      expect(bollsBookNumbers['NUM'], 4);
      expect(bollsBookNumbers['1CO'], 46);
      expect(bollsBookNumbers.length, 66);
      expect(germanBookNames['JHN'], 'Johannes');
    });
  });

  group('BollsBibleApiClient.fetchPassage', () {
    BollsBibleApiClient clientReturning(
            List<Map<String, dynamic>> chapter, {int status = 200}) =>
        BollsBibleApiClient(
          client: MockClient((request) async =>
              http.Response(json.encode(chapter), status,
                  headers: {'content-type': 'application/json'})),
        );

    test('single verse: cleaned real text is returned', () async {
      final client = clientReturning([
        {'pk': 1, 'verse': 15, 'text': 'davor'},
        {'pk': 2, 'verse': 16, 'text': _realJohn316},
        {'pk': 3, 'verse': 17, 'text': 'danach'},
      ]);
      final result = await client.fetchPassage(
          const BibleReference(book: 'JHN', chapter: 3, verseStart: 16));
      expect(result.translation, 'MB');
      expect(result.text.startsWith('Denn so sehr'), isTrue);
      expect(result.text.contains('davor'), isFalse);
      expect(result.text.contains('<i>'), isFalse);
    });

    test('range: verses are joined in order', () async {
      final client = clientReturning([
        {'pk': 1, 'verse': 24, 'text': 'Der HERR segne dich'},
        {'pk': 2, 'verse': 25, 'text': 'und sei dir gnädig'},
        {'pk': 3, 'verse': 26, 'text': 'und gebe dir Frieden'},
        {'pk': 4, 'verse': 27, 'text': 'ausserhalb'},
      ]);
      final result = await client.fetchPassage(const BibleReference(
          book: 'NUM', chapter: 6, verseStart: 24, verseEnd: 26));
      expect(result.text,
          'Der HERR segne dich und sei dir gnädig und gebe dir Frieden');
    });

    test('unknown book throws before any request', () async {
      final client = BollsBibleApiClient(
          client: MockClient((_) async =>
              throw StateError('should not be called')));
      await expectLater(
        client.fetchPassage(
            const BibleReference(book: 'XYZ', chapter: 1, verseStart: 1)),
        throwsA(isA<VerseFetchException>()),
      );
    });

    test('a non-200 response throws', () async {
      final client = BollsBibleApiClient(
          client: MockClient((_) async => http.Response('nope', 500)));
      await expectLater(
        client.fetchPassage(
            const BibleReference(book: 'JHN', chapter: 3, verseStart: 16)),
        throwsA(isA<VerseFetchException>()),
      );
    });

    test('a missing verse throws', () async {
      final client = clientReturning([
        {'pk': 1, 'verse': 1, 'text': 'nur Vers 1'},
      ]);
      await expectLater(
        client.fetchPassage(
            const BibleReference(book: 'JHN', chapter: 3, verseStart: 16)),
        throwsA(isA<VerseFetchException>()),
      );
    });
  });
}

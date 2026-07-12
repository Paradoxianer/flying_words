import 'package:flutter_test/flutter_test.dart';
import 'package:flying_words/src/game_internals/bible_reference.dart';
import 'package:flying_words/src/game_internals/lesson.dart';
import 'package:flying_words/src/games_services/score.dart';
import 'package:flying_words/src/player_progress/persistence/memory_player_progress_persistence.dart';
import 'package:flying_words/src/player_progress/player_progress.dart';
import 'package:flying_words/src/verses/bible_api_client.dart';
import 'package:flying_words/src/verses/custom_verses_controller.dart';
import 'package:flying_words/src/verses/persistence/memory_custom_verses_persistence.dart';

/// A fake API client so the data layer can be tested without a network.
class FakeBibleApiClient implements BibleApiClient {
  @override
  String get defaultTranslation => 'MB';

  bool fail = false;
  String text = 'ein zwei drei';

  @override
  Future<FetchedVerse> fetchPassage(BibleReference reference,
      {String? translation}) async {
    if (fail) throw const VerseFetchException('kaputt');
    return FetchedVerse(
        text: text, translation: translation ?? defaultTranslation);
  }
}

void main() {
  const ref = BibleReference(book: 'JHN', chapter: 3, verseStart: 16);

  PlayerProgress freshProgress() =>
      PlayerProgress(MemoryOnlyPlayerProgressPersistence());

  CustomVersesController controller(FakeBibleApiClient api) =>
      CustomVersesController(
          store: MemoryCustomVersesPersistence(), api: api);

  group('customVersesUnlocked', () {
    test('locked until every curated verse is finished on seal I', () {
      final progress = freshProgress();
      final curated = ['a', 'b'];
      expect(customVersesUnlocked(curated, progress), isFalse);

      progress.setScoreforVerse('a', Difficulty.slow, Score(score: 10));
      expect(customVersesUnlocked(curated, progress), isFalse);

      progress.setScoreforVerse('b', Difficulty.slow, Score(score: 10));
      expect(customVersesUnlocked(curated, progress), isTrue);
    });

    test('empty curated list is never unlocked', () {
      expect(customVersesUnlocked([], freshProgress()), isFalse);
    });
  });

  group('adding custom verses', () {
    test('fetches the text and stores the verse', () async {
      final api = FakeBibleApiClient()..text = 'Denn also hat Gott';
      final c = controller(api);
      final progress = freshProgress();

      final lesson = await c.addFromReference(
          reference: ref, display: 'Johannes 3, 16', progress: progress);

      expect(lesson.custom, isTrue);
      expect(lesson.text, 'Denn also hat Gott');
      expect(lesson.translation, 'MB');
      expect(c.verses, hasLength(1));
    });

    test('a fetch failure is propagated and nothing is stored', () async {
      final api = FakeBibleApiClient()..fail = true;
      final c = controller(api);
      await expectLater(
        c.addFromReference(
            reference: ref, display: 'x', progress: freshProgress()),
        throwsA(isA<VerseFetchException>()),
      );
      expect(c.verses, isEmpty);
    });

    test('packs of three: no fourth verse until the first three are done',
        () async {
      final api = FakeBibleApiClient();
      final c = controller(api);
      final progress = freshProgress();

      Lesson? first;
      for (var i = 0; i < 3; i++) {
        expect(c.canAddMore(progress), isTrue);
        final lesson = await c.addFromReference(
            reference: ref, display: 'v$i', progress: progress);
        first ??= lesson;
      }
      // Three unfinished custom verses block the fourth.
      expect(c.canAddMore(progress), isFalse);
      expect(
        c.addFromReference(reference: ref, display: 'v3', progress: progress),
        throwsA(isA<StateError>()),
      );

      // Finishing one on seal I frees a slot.
      progress.setScoreforVerse(
          verseProgressKey(first!), Difficulty.slow, Score(score: 10));
      expect(c.canAddMore(progress), isTrue);
    });

    test('custom verse numbers stay clear of curated ones and are unique',
        () async {
      final c = controller(FakeBibleApiClient());
      final progress = freshProgress();
      final a = await c.addFromReference(
          reference: ref, display: 'a', progress: progress);
      final b = await c.addFromReference(
          reference: ref, display: 'b', progress: progress);
      expect(a.number, greaterThanOrEqualTo(1000));
      expect(b.number, greaterThan(a.number));
    });
  });

  test('load and remove round trip through the store', () async {
    final store = MemoryCustomVersesPersistence();
    final api = FakeBibleApiClient();
    final progress = freshProgress();
    final c1 = CustomVersesController(store: store, api: api);
    await c1.addFromReference(
        reference: ref, display: 'keep', progress: progress);
    await c1.addFromReference(
        reference: ref, display: 'drop', progress: progress);
    await c1.remove('drop');

    // A fresh controller sees the persisted state.
    final c2 = CustomVersesController(store: store, api: api);
    await c2.loadFromStore();
    expect(c2.verses.map((l) => l.verse), ['keep']);
  });
}
